import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
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

  Future<List<RecettesRecord>> getRecipes({page, perPage}) async {
    page = page ?? 1;
    perPage = perPage ?? 50;
    final response = await pb.collection('recettes').getList(page: page, perPage: perPage, expand: "images");
    return response.items.map((e) => RecettesRecord.fromRecordModel(e)).toList();
  }
}


