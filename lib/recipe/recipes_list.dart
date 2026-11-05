import 'dart:ui' as ui;

import 'favorite_button.dart';
import 'package:abcuisto/login/authentication_cubit.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/add_recipe/add_recipe_page.dart';
import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/recipe/recipe_details.dart';
import 'package:abcuisto/recipe/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' show ClientException;

import 'filters/filter_page.dart';

class RecipePage extends StatefulWidget {
  RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(),
      body: RecipesList(),
      floatingActionButton: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationLoggedIn) {
            return FloatingActionButton(
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              foregroundColor: Theme
                  .of(context)
                  .colorScheme
                  .onPrimary,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddRecipePage()));
              },
              child: const Icon(Icons.add_rounded),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}


class RecipesList extends StatefulWidget {
  const RecipesList({super.key});

  @override
  State<RecipesList> createState() => _RecipesListState();
}

class _RecipesListState extends State<RecipesList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) {
        final groupNames = {
          for (final group in context.read<FilterCubit>().availableGroups) group.id: group.name ?? 'Groupe',
        };
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: Text('Filtres'),
                          onSelected: (_) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FilterPage()));
                          },
                        ),
                        const SizedBox(width: 8),
                        if (state.favoritesOnly)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              avatar: const Icon(Icons.favorite_rounded),
                              label: const Text('Favoris uniquement'),
                              deleteIcon: const Icon(Icons.close_rounded),
                              onDeleted: () => context.read<FilterCubit>().updateFavoritesOnly(false),
                            ),
                          ),
                        ...(state.filter.ingredients ?? []).map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text("Avec : $ingredient"),
                              deleteIcon: const Icon(Icons.close_rounded),
                              onDeleted: () {
                                context.read<FilterCubit>().removeFilteredIngredient(ingredient);
                              },
                            ),
                          ),
                        ),
                        ...(state.filter.categories ?? []).map(
                              (category) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text(category),
                              onDeleted: () {
                                context.read<FilterCubit>().updateFilteredCategories(category, false);
                              },
                            ),
                          ),
                        ),
                        ...state.filter.creator != null && state.filter.creator!.isNotEmpty
                            ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text('Créé par ${state.filter.creator}'),
                              onDeleted: () {
                                context.read<FilterCubit>().updateFilteredCreatorName(null);
                              },
                            ),
                          ),
                        ]
                            : [],
                        ...state.filter.totalTime != null && state.filter.totalTime! < 24
                            ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text('Moins de ${state.filter.totalTime}h'),
                              onDeleted: () {
                                context.read<FilterCubit>().updateFilteredMaxTime(null);
                              },
                            ),
                          ),
                        ]
                            : [],
                        ...(state.filter.tags ?? []).map(
                              (tag) =>
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: InputChip(
                                  label: Text(tag.displayName),
                                  onDeleted: () {
                                    context.read<FilterCubit>().updateFilteredTags(tag, false);
                                  },
                                ),
                              ),
                        ),
                        ...(state.filter.groups ?? []).map(
                          (groupId) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text(groupNames[groupId] ?? 'Groupe'),
                              deleteIcon: const Icon(Icons.close_rounded),
                              onDeleted: () {
                                context.read<FilterCubit>().updateFilteredGroup(groupId, false);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: context.read<FilterCubit>().refresh,
                    child: PagedListView<int, Recipe>(
                      key: ObjectKey(state.filter),
                      physics: const AlwaysScrollableScrollPhysics(),
                      state: state.pagingState,
                      fetchNextPage: context.read<FilterCubit>().fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        noItemsFoundIndicatorBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aucune recette trouvée',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Essayez un autre mot-clé ou retirez quelques filtres pour trouver votre prochaine recette.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        firstPageErrorIndicatorBuilder: (context) {
                          final state = context
                              .read<FilterCubit>()
                              .state;
                          final isConnectionError = state.pagingState.error is ClientException;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isConnectionError ? Icons.signal_wifi_connected_no_internet_4_rounded : Icons.error_outline_rounded,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(100),
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                  child: Text(
                                    isConnectionError
                                        ? "Connexion au serveur impossible.\nVérifiez la connexion internet."
                                        : "Impossible de charger les recettes.\nRéessayez dans quelques instants.",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => context.read<FilterCubit>().fetchNextPage(),
                                  child: Text("Réessayer"),
                                ),
                              ],
                            );
                        },
                        itemBuilder: (context, item, index) => Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: RecipeCard(recipe: item),
                            ),
                          ),
                        ),
                      ),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecipeCard extends StatefulWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  Color? _averageColor;
  String? _imageUrl;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  Recipe get recipe => widget.recipe;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadImageColor();
  }

  @override
  void didUpdateWidget(covariant RecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadImageColor();
  }

  void _loadImageColor() {
    final url = recipe.documents.firstOrNull?.toString();
    if (url == _imageUrl) return;
    _removeImageListener();
    _imageUrl = url;
    _averageColor = null;
    if (url == null) return;

    // A small decode keeps this purely visual calculation inexpensive.
    final stream = ResizeImage(NetworkImage(url), width: 16, height: 16)
        .resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        _readImageColor(info, url);
      },
      onError: (Object error, StackTrace? stackTrace) {
        stream.removeListener(listener);
        // The photo's errorBuilder supplies the visible fallback.
      },
    );
    _imageStream = stream;
    _imageListener = listener;
    stream.addListener(listener);
  }

  Future<void> _readImageColor(ImageInfo info, String url) async {
    try {
      final data = await info.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null || !mounted || _imageUrl != url) return;
      var red = 0.0;
      var green = 0.0;
      var blue = 0.0;
      var weight = 0.0;
      for (var i = 0; i < data.lengthInBytes; i += 4) {
        final alpha = data.getUint8(i + 3) / 255;
        red += data.getUint8(i) * alpha;
        green += data.getUint8(i + 1) * alpha;
        blue += data.getUint8(i + 2) * alpha;
        weight += alpha;
      }
      if (weight == 0) return;
      setState(() {
        _averageColor = Color.fromARGB(
          255,
          (red / weight).round(),
          (green / weight).round(),
          (blue / weight).round(),
        );
      });
    } finally {
      info.dispose();
    }
  }

  void _removeImageListener() {
    final listener = _imageListener;
    if (listener != null) _imageStream?.removeListener(listener);
    _imageStream = null;
    _imageListener = null;
  }

  @override
  void dispose() {
    _removeImageListener();
    super.dispose();
  }

  Widget _photo(double height) => recipe.documents.isNotEmpty
      ? Image.network(
          recipe.documents.first.toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, _, _) => NoImageBuilder(height: height),
        )
      : NoImageBuilder(height: height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = _averageColor ?? colors.secondaryContainer;
    final foreground = ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxWidth > 600 ? 190.0 : 160.0) +
            MediaQuery.textScalerOf(context).scale(80) - 80;
        return Card(
          margin: EdgeInsets.zero,
          elevation: 1,
          shadowColor: colors.shadow.withValues(alpha: 0.12),
          color: background,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth * 0.5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRect(
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4, tileMode: TileMode.clamp),
                          child: _photo(height),
                        ),
                      ),
                      ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0, 0.45, 0.82, 1],
                          colors: [Colors.white, Colors.white, Colors.transparent, Colors.transparent],
                        ).createShader(bounds),
                        child: _photo(height),
                      ),
                      // Cover the image edge with the exact card color instead
                      // of relying on a transparency mask at the layer boundary.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0, 0.48, 0.94, 1],
                            colors: [
                              background.withValues(alpha: 0),
                              background.withValues(alpha: 0),
                              background,
                              background,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * 0.40,
                  top: 4,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(color: foreground),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              if (recipe.totalTimeFormatted case final duration?)
                                Text(
                                  duration,
                                  style: theme.textTheme.labelLarge?.copyWith(color: foreground.withValues(alpha: 0.8)),
                                ),
                              RatingStars(note: recipe.note, size: 20, color: foreground),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      splashColor: foreground.withValues(alpha: 0.16),
                      highlightColor: foreground.withValues(alpha: 0.08),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              context.read<RecipeCubit>().focusRecipe(recipe);
                              return RecipeDetailsPage();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        child: SizedBox.square(
                          dimension: 36,
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8, tileMode: TileMode.clamp),
                              child: const ColoredBox(color: Color(0x00000000)),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: FavoriteButton(recipeId: recipe.id, foregroundColor: foreground),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NoImageBuilder extends StatelessWidget {
  const NoImageBuilder({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: 400,
      child: Icon(
        Icons.no_photography_rounded,
        size: 70,
        color: Theme
            .of(context)
            .colorScheme
            .onSecondaryContainer
            .withAlpha(50),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final double? note;
  final double size;
  final Color? color;

  const RatingStars({super.key, required this.note, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.orange.withValues(alpha: 0.5);
    return note != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Icon(
                index < note! ? Icons.star_rounded : Icons.star_border_rounded,
                color: starColor,
                size: size,
              ),
            ),
          )
        : Text('Aucune note', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color));
  }
}
