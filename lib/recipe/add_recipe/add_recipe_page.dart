import 'dart:io';

import 'package:abcuisto/models/abcuisto_repository.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/add_recipe/add_recipe_cubit.dart';
import 'package:abcuisto/recipe/add_recipe/duration_picker.dart';
import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../recipes_list.dart' show NoImageBuilder;

class AddRecipePage extends StatelessWidget {
  final RecipeFull? initialRecipe;

  const AddRecipePage({super.key, this.initialRecipe});

  @override
  Widget build(BuildContext context) => CreateRecipeBody(initialRecipe: initialRecipe);
}

class CreateRecipeBody extends StatefulWidget {
  final RecipeFull? initialRecipe;

  const CreateRecipeBody({super.key, this.initialRecipe});

  @override
  State<CreateRecipeBody> createState() => _CreateRecipeBodyState();
}

class _CreateRecipeBodyState extends State<CreateRecipeBody> {
  static const _units = ['g', 'kg', 'mg', 'L', 'cL', 'mL', 'pièce(s)', 'cuillère à café', 'cuillère à soupe', 'pincée(s)'];

  final _nameController = TextEditingController();
  Duration _prepTime = Duration.zero;
  Duration _cookTime = Duration.zero;
  Duration _restTime = Duration.zero;
  final _servingsController = TextEditingController();
  final _utensilsController = TextEditingController();
  final List<TextEditingController> _stepControllers = [];
  final List<IngredientCategory> _categories = [];
  final List<XFile> _photoFiles = [];
  final List<String> _documents = [];
  final List<Uri> _existingImages = [];
  final Set<RecipeTag> _selectedTags = {};
  final Set<String> _selectedGroupIds = {};
  RecipeCategory? _selectedCategory;
  RecipeServingType _servingType = RecipeServingType.personnes;

  bool get _isEditing => widget.initialRecipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.initialRecipe;
    _nameController.text = recipe?.name ?? '';
    _prepTime = recipe?.prepTime ?? Duration.zero;
    _cookTime = recipe?.cookTime ?? Duration.zero;
    _restTime = recipe?.restTime ?? Duration.zero;
    _servingsController.text = recipe?.forNumber?.toString() ?? '';
    _utensilsController.text = recipe?.cookware.join(', ') ?? '';
    _selectedCategory = recipe?.category;
    final normalizedServingType = recipe?.typeNumber?.displayName;
    _servingType = normalizedServingType == 'pieces' || normalizedServingType == 'pièces' ? RecipeServingType.pieces : RecipeServingType.personnes;
    _selectedTags.addAll(_tagsFor(recipe?.tags ?? const []));
    _selectedGroupIds.addAll(recipe?.groups.map((group) => group.id).whereType<String>() ?? const []);
    _documents.addAll(recipe?.documents ?? const []);
    _existingImages.addAll(recipe?.images ?? const []);

    for (final instruction in recipe?.instructions ?? const <String>[]) {
      _stepControllers.add(TextEditingController(text: instruction));
    }
    if (_stepControllers.isEmpty) _stepControllers.add(TextEditingController());

    for (final category in recipe?.ingredientCategories ?? const <RecipeIngredientCategory>[]) {
      _categories.add(
        IngredientCategory(
          id: category.id,
          name: category.name,
          index: category.index,
          ingredients: category.ingredients
              .map(
                (ingredient) => IngredientLine(
                  id: ingredient.id,
                  name: ingredient.name,
                  quantity: ingredient.quantity?.toString() ?? '',
                  unit: ingredient.type,
                  index: ingredient.index,
                ),
              )
              .toList(),
        ),
      );
    }
    if (_categories.isEmpty) _categories.add(IngredientCategory());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    _utensilsController.dispose();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    for (final category in _categories) {
      category.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AbcuistoRepository>();
    final groupsById = <String, RecipeGroup>{
      for (final group in repository.user?.groups ?? const <RecipeGroup>[])
        if (group.id != null) group.id!: group,
      for (final group in widget.initialRecipe?.groups ?? const <RecipeGroup>[])
        if (group.id != null) group.id!: group,
    };
    final availableGroups = groupsById.values.toList();

    return BlocConsumer<AddRecipeCubit, AddRecipeState>(
      listener: (context, state) async {
        if (state is AddRecipeError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AddRecipeSuccess) {
          var successMessage = state.updated ? 'Recette modifiée.' : 'Recette créée.';
          if (state.updated && widget.initialRecipe != null) {
            try {
              await context.read<RecipeCubit>().refreshRecipe(recipeId: widget.initialRecipe!.id);
            } catch (error) {
              successMessage = 'Recette enregistrée, mais impossible de la recharger : $error';
            }
          } else {
            context.read<FilterCubit>().update();
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is AddRecipeLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Modifier la recette' : 'Créer une recette'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  tooltip: 'Enregistrer',
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_rounded),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ImageCarousel(
                images: _existingImages,
                photoFiles: _photoFiles,
                onAdd: (file) => setState(() => _photoFiles.add(file)),
                onReplace: (index, file) {
                  setState(() {
                    if (index < _documents.length) {
                      _documents.removeAt(index);
                      _existingImages.removeAt(index);
                      _photoFiles.add(file);
                    } else {
                      _photoFiles[index - _documents.length] = file;
                    }
                  });
                },
                onRemove: (index) {
                  setState(() {
                    if (index < _documents.length) {
                      _documents.removeAt(index);
                      _existingImages.removeAt(index);
                    } else {
                      _photoFiles.removeAt(index - _documents.length);
                    }
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      RoundedTextField(hintText: 'Nom de la recette', controller: _nameController),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Catégorie de la recette'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RecipeCategory>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Choisir une catégorie'),
                        items: RecipeCategory.values
                            .map((category) => DropdownMenuItem(value: category, child: Text(category.displayName)))
                            .toList(),
                        onChanged: (category) => setState(() => _selectedCategory = category),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          DurationPicker(
                            label: 'Préparation',
                            initialDuration: widget.initialRecipe?.prepTime,
                            onDurationChanged: (duration) {
                              _prepTime = duration;
                            },
                          ),
                          const SizedBox(width: 8),
                          // Expanded(child: RoundedTextField(hintText: 'Temps de cuisson', controller: _cookTimeController)),
                          DurationPicker(
                            label: 'Cuisson',
                            initialDuration: widget.initialRecipe?.cookTime,
                            onDurationChanged: (duration) => _cookTime = duration,
                          ),
                          const SizedBox(width: 8),
                          DurationPicker(
                            label: 'Repos',
                            initialDuration: widget.initialRecipe?.restTime,
                            onDurationChanged: (duration) => _restTime = duration,
                          ),
                        ],
                      ),
                      // const SizedBox(height: 8),
                      // RoundedTextField(hintText: 'Temps de repos', controller: _restTimeController),
                      if (availableGroups.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const SectionTitle(title: 'Visible pour quels groupes ?'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: availableGroups.map((group) {
                            final id = group.id!;
                            return FilterChip(
                              label: Text(group.name ?? 'Groupe'),
                              selected: _selectedGroupIds.contains(id),
                              onSelected: (selected) => setState(() {
                                if (selected) {
                                  _selectedGroupIds.add(id);
                                } else {
                                  _selectedGroupIds.remove(id);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Tags'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: RecipeTag.values.map((tag) {
                          return FilterChip(
                            label: Text(tag.label),
                            selected: _selectedTags.contains(tag),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RoundedTextField(hintText: 'Pour combien ?', controller: _servingsController, keyboardType: TextInputType.number),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<RecipeServingType>(
                              initialValue: _servingType,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: RecipeServingType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.label))).toList(),
                              onChanged: (type) {
                                if (type != null) setState(() => _servingType = type);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Ingrédients'),
                      const SizedBox(height: 8),
                      ..._categories.map(
                        (category) => IngredientCategoryWidget(
                          category: category,
                          units: _units,
                          onAddIngredient: () => setState(() => category.ingredients.add(IngredientLine())),
                          onRemoveCategory: () => setState(() {
                            if (_categories.length > 1) {
                              _categories.remove(category);
                              category.dispose();
                            }
                          }),
                          onRemoveIngredient: (ingredient) => setState(() {
                            if (category.ingredients.length > 1) {
                              category.ingredients.remove(ingredient);
                              ingredient.dispose();
                            }
                          }),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() => _categories.add(IngredientCategory())),
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter une catégorie d'ingrédients"),
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Étapes'),
                      const SizedBox(height: 8),
                      ..._buildSteps(),
                      TextButton.icon(
                        onPressed: () => setState(() => _stepControllers.add(TextEditingController())),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une étape'),
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Ustensiles'),
                      const SizedBox(height: 8),
                      RoundedTextField(hintText: 'Ex: fouet, casserole...', controller: _utensilsController),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSteps() => List.generate(_stepControllers.length, (index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StepField(index: index + 1, controller: _stepControllers[index]),
          ),
          if (_stepControllers.length > 1)
            IconButton(
              tooltip: 'Supprimer l’étape',
              onPressed: () => setState(() {
                _stepControllers.removeAt(index).dispose();
              }),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  });

  void _submit() {
    final name = _nameController.text.trim();
    final servings = int.tryParse(_servingsController.text.trim());
    if (name.isEmpty) {
      _showError('Le nom de la recette est obligatoire.');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Choisissez une catégorie.');
      return;
    }
    if (servings == null || servings <= 0) {
      _showError('Indiquez un nombre de portions valide.');
      return;
    }
    final categories = <ApiRecipeCategoryInput>[];
    for (var categoryIndex = 0; categoryIndex < _categories.length; categoryIndex++) {
      final category = _categories[categoryIndex];
      final ingredients = <ApiRecipeIngredientInput>[];
      for (var ingredientIndex = 0; ingredientIndex < category.ingredients.length; ingredientIndex++) {
        final ingredient = category.ingredients[ingredientIndex];
        final ingredientName = ingredient.nameController.text.trim();
        if (ingredientName.isEmpty) continue;
        final quantity = _parseQuantity(ingredient.quantityController.text);
        if (quantity == null) {
          _showError('La quantité de « $ingredientName » doit être un nombre valide.');
          return;
        }
        ingredients.add(
          ApiRecipeIngredientInput(name: ingredientName, type: ingredient.unit, number: _formatQuantity(quantity), index: ingredientIndex),
        );
      }
      if (ingredients.isNotEmpty) {
        categories.add(
          ApiRecipeCategoryInput(
            name: category.nameController.text.trim().isEmpty ? 'Ingrédients' : category.nameController.text.trim(),
            index: categoryIndex,
            ingredients: ingredients,
          ),
        );
      }
    }

    final groupsById = <String, RecipeGroup>{
      for (final group in context.read<AbcuistoRepository>().user?.groups ?? const <RecipeGroup>[])
        if (group.id != null) group.id!: group,
      for (final group in widget.initialRecipe?.groups ?? const <RecipeGroup>[])
        if (group.id != null) group.id!: group,
    };
    final groups = _selectedGroupIds
        .map((id) => groupsById[id])
        .whereType<RecipeGroup>()
        .map(
          (group) => ApiGroupInput(
            id: group.id,
            name: group.name,
            owner: group.owner,
            canEdit: group.canEdit,
            link: group.link,
            newOwner: group.newOwner,
            memberId: group.memberId,
            memberUserName: group.memberUserName,
            members: group.members,
          ),
        )
        .toList();
    final steps = _stepControllers.map((controller) => controller.text.trim()).where((step) => step.isNotEmpty).toList();
    final utensilsText = _utensilsController.text.trim();
    final utensils = utensilsText.isEmpty ? <String>[] : <String>[utensilsText];

    final cubit = context.read<AddRecipeCubit>();
    final recipe = widget.initialRecipe;
    if (recipe == null) {
      cubit.createRecipe(
        name: name,
        category: _selectedCategory!,
        preparationTime: _prepTime.inMinutes.toString(),
        cookingTime: _cookTime.inMinutes.toString(),
        waitingTime: _restTime.inMinutes.toString(),
        steps: steps,
        utensils: utensils,
        servings: servings,
        servingType: _servingType,
        tags: _selectedTags.toList(),
        groups: groups,
        ingredientsCategories: categories,
        images: List.of(_photoFiles),
      );
    } else {
      cubit.updateRecipe(
        recipe: recipe,
        name: name,
        category: _selectedCategory!,
        preparationTime: _prepTime.inMinutes.toString(),
        cookingTime: _cookTime.inMinutes.toString(),
        waitingTime: _restTime.inMinutes.toString(),
        steps: steps,
        utensils: utensils,
        servings: servings,
        servingType: _servingType,
        tags: _selectedTags.toList(),
        groups: groups,
        ingredientsCategories: categories,
        documents: List.of(_documents),
        images: List.of(_photoFiles),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static double? _parseQuantity(String raw) {
    final value = raw.trim().replaceAll(',', '.');
    if (value.isEmpty) return 0;
    final fraction = RegExp(r'^(\d+)\s*/\s*(\d+)$').firstMatch(value);
    if (fraction != null) {
      final numerator = double.tryParse(fraction.group(1)!);
      final denominator = double.tryParse(fraction.group(2)!);
      if (numerator == null || denominator == null || denominator == 0) return null;
      return numerator / denominator;
    }
    return double.tryParse(value);
  }

  static String _formatQuantity(double quantity) {
    if (quantity == quantity.truncateToDouble()) return quantity.toInt().toString();
    return quantity.toString();
  }

  // static RecipeCategory? _categoryFor(RecipeCategory? category) {
  //   if (category == null) return null;
  //   for (final value in RecipeCategory.values) {
  //     if (value.displayValue.toLowerCase() == category.label.toLowerCase()) return value;
  //   }
  //   return null;
  // }

  static List<RecipeTag> _tagsFor(List<RecipeTag> tags) {
    final normalized = tags.toSet();
    return RecipeTag.values.where((tag) => normalized.contains(tag)).toList();
  }



}

class IngredientCategory {
  final String? id;
  final int index;
  final TextEditingController nameController;
  final List<IngredientLine> ingredients;

  IngredientCategory({this.id, this.index = 0, String name = '', List<IngredientLine>? ingredients})
    : nameController = TextEditingController(text: name),
      ingredients = ingredients ?? [IngredientLine()];

  void dispose() {
    nameController.dispose();
    for (final ingredient in ingredients) {
      ingredient.dispose();
    }
  }
}

class IngredientLine {
  final String? id;
  final int index;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  String unit;

  IngredientLine({this.id, this.index = 0, String quantity = '', String name = '', this.unit = 'g'})
    : quantityController = TextEditingController(text: quantity),
      nameController = TextEditingController(text: name);

  void dispose() {
    quantityController.dispose();
    nameController.dispose();
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class IngredientCategoryWidget extends StatelessWidget {
  final IngredientCategory category;
  final List<String> units;
  final VoidCallback onAddIngredient;
  final VoidCallback onRemoveCategory;
  final ValueChanged<IngredientLine> onRemoveIngredient;

  const IngredientCategoryWidget({
    super.key,
    required this.category,
    required this.units,
    required this.onAddIngredient,
    required this.onRemoveCategory,
    required this.onRemoveIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RoundedTextField(hintText: 'Nom de la catégorie', controller: category.nameController),
            ),
            IconButton(tooltip: 'Supprimer la catégorie', onPressed: onRemoveCategory, icon: const Icon(Icons.delete_outline)),
          ],
        ),
        const SizedBox(height: 8),
        ...category.ingredients.map((ingredient) {
          final availableUnits = units.contains(ingredient.unit) ? units : [ingredient.unit, ...units];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                SizedBox(
                  width: 78,
                  child: RoundedTextField(
                    hintText: 'Qté',
                    controller: ingredient.quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 112,
                  child: DropdownButtonFormField<String>(
                    initialValue: ingredient.unit,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: availableUnits
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: SizedBox(width: 50, child: Text(unit.isEmpty ? 'Unité' : unit, overflow: TextOverflow.fade)),
                          ),
                        )
                        .toList(),
                    onChanged: (unit) {
                      if (unit != null) ingredient.unit = unit;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RoundedTextField(hintText: 'Ingrédient', controller: ingredient.nameController),
                ),
                IconButton(
                  tooltip: 'Supprimer l’ingrédient',
                  onPressed: () => onRemoveIngredient(ingredient),
                  icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(onPressed: onAddIngredient, icon: const Icon(Icons.add), label: const Text('Ajouter un ingrédient')),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class StepField extends StatelessWidget {
  final int index;
  final TextEditingController controller;

  const StepField({super.key, required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
              child: Center(
                child: Text('$index', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ),
            const SizedBox(width: 10),
            Text('Étape $index', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
            ),
            padding: const EdgeInsets.only(left: 8),
            child: RoundedTextField(hintText: 'Étape $index', controller: controller, maxLines: 3),
          ),
        ),
      ],
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<Uri> images;
  final List<XFile> photoFiles;
  final ValueChanged<XFile> onAdd;
  final void Function(int index, XFile file) onReplace;
  final ValueChanged<int> onRemove;

  const _ImageCarousel({required this.images, required this.photoFiles, required this.onAdd, required this.onReplace, required this.onRemove});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final ImagePicker _picker = ImagePicker();
  final PageController _controller = PageController();
  int _currentIndex = 0;

  int get _itemCount => widget.images.length + widget.photoFiles.length;

  @override
  void didUpdateWidget(covariant _ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex >= _itemCount) {
      _currentIndex = _itemCount == 0 ? 0 : _itemCount - 1;
      if (_controller.hasClients) _controller.jumpToPage(_currentIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: 400,
          width: width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            boxShadow: [BoxShadow(offset: const Offset(1, 1), blurRadius: 5, color: Colors.black.withValues(alpha: 0.25))],
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: PageView.builder(
              controller: _controller,
              itemCount: _itemCount == 0 ? 1 : _itemCount,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                if (_itemCount == 0) return const NoImageBuilder(height: 400);
                if (index < widget.images.length) {
                  return Image.network(
                    widget.images[index].toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const NoImageBuilder(height: 400),
                  );
                }
                return Image.file(File(widget.photoFiles[index - widget.images.length].path), fit: BoxFit.cover);
              },
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(Icons.add_rounded, 'Ajouter', () async {
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null && mounted) widget.onAdd(file);
              }),
              const SizedBox(width: 8),
              _buildButton(Icons.edit_rounded, 'Modifier', () async {
                if (_itemCount == 0) return;
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null && mounted) widget.onReplace(_currentIndex, file);
              }),
              const SizedBox(width: 8),
              _buildButton(Icons.delete_rounded, 'Supprimer', () {
                if (_itemCount > 0) widget.onRemove(_currentIndex);
              }),
            ],
          ),
        ),
        if (_itemCount > 1)
          Positioned(
            top: 335,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_itemCount, (index) {
                return Container(
                  width: _currentIndex == index ? 16 : 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16)),
      child: TextButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
    );
  }
}
