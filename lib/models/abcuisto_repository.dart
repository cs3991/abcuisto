import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbcuistoRepository extends ChangeNotifier {
  final String url;
  late final PocketBase pb;
  SharedPreferences? prefs;
  String? fileToken;
  bool initialized = false;

  AbcuistoRepository({required this.url});

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    final store = AsyncAuthStore(
      save: (String data) async => prefs!.setString('pb_auth', data),
      initial: prefs!.getString('pb_auth'),
    );

    pb = PocketBase(url, authStore: store);
    initialized = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    await pb.collection('users').authWithPassword(username, password);
    fileToken = await pb.files.getToken();
    notifyListeners();
  }

  void logout() {
    pb.authStore.clear();
    notifyListeners();
  }

  Future<List<Recipe>> getRecipes({
    int page = 1,
    int perPage = 50,
    String? searchPattern,
    List<String>? categories,
    String? filterCreatorName,
    int? filterMaxHours,
  }) async {
    String filter = '';
    if (searchPattern != null && searchPattern.isNotEmpty) {
      final sanitized = removeDiacritics(
        searchPattern,
      ).toLowerCase().replaceAll(RegExp(r"[^a-zA-Z0-9\s']"), '').trim();
      filter =
          '(nameWithoutDiacritics ?~ "$sanitized" || categoriesIds.ingredientsIds.nameWithoutDiacritics ?~ "$sanitized")';
    }
    if (categories != null && categories.isNotEmpty) {
      final categoryFilters = categories.map((c) => 'categorie ?= "$c"').join(' || ');
      filter = filter.isEmpty ? '($categoryFilters)' : '$filter && ($categoryFilters)';
    }
    if (filterCreatorName != null && filterCreatorName.isNotEmpty) {
      final sanitizedCreator = filterCreatorName.replaceAll('"', r'\"');
      filter = filter.isEmpty
          ? '(createur_pseudo ~ "$sanitizedCreator")'
          : '$filter && (createur_pseudo ~ "$sanitizedCreator")';
    }
    if (filterMaxHours != null && filterMaxHours < 24) {
      final timeFilter = 'tempsTotal < "${filterMaxHours.toString().padLeft(2, '0')}h00"';
      filter = filter.isEmpty ? timeFilter : '$filter && $timeFilter';
    }
    print('Filter: $filter');
    final response = await pb
        .collection('recettes')
        .getList(page: page, perPage: perPage, expand: 'noteId', filter: filter);
    return response.items.map((e) => Recipe.fromRecord(RecettesRecord.fromRecordModel(e), pb)).toList();
  }

  Future<RecipeFull> getRecipe(String id) async {
    final record = await pb
        .collection('recettes')
        .getOne(id, expand: 'categoriesIds.ingredientsIds, noteId, groupsIds');
    return RecipeFull.fromRecord(RecettesRecord.fromRecordModel(record), pb);
  }
}
