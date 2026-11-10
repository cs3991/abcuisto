import 'dart:io';

import 'package:abcuisto/models/abcuisto_repository.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/add_recipe/add_recipe_cubit.dart';
import 'package:abcuisto/recipe/add_recipe/duration_picker.dart';
import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_pointer/transparent_pointer.dart';

import '../recipes_list.dart' show NoImageBuilder;

class AddRecipePage extends StatefulWidget {
  final RecipeFull? initialRecipe;

  const AddRecipePage({super.key, this.initialRecipe});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final List<FocusNode> _stepFocusNodes = [];

  @override
  void initState() {
    super.initState();
    context.read<AddRecipeCubit>().initialize(widget.initialRecipe);
    _stepFocusNodes.addAll(
      List.generate(
        context
            .read<AddRecipeCubit>()
            .state
            .modifiedRecipe!
            .instructions
            .length,
        (_) => FocusNode(),
      ),
    );
  }

  @override
  void dispose() {
    for (final node in _stepFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddRecipeCubit>();
    return BlocConsumer<AddRecipeCubit, AddRecipeState>(
      listener: (context, state) async {
        if (state.status == AddRecipeStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        } else if (state.status == AddRecipeStatus.success) {
          context.read<FilterCubit>().update();
          context.read<AddRecipeCubit>().initialize(null);
          final recipeId = state.modifiedRecipe!.id;
          var message = recipeId.isEmpty
              ? 'Recette créée.'
              : 'Recette modifiée.';
          if (recipeId.isNotEmpty) {
            final recipeCubit = context.read<RecipeCubit>();
            await recipeCubit.refreshRecipe(recipeId: recipeId);
            if (!context.mounted) return;
            final recipeState = recipeCubit.state;
            if (recipeState is RecipeError) {
              message = 'Recette enregistrée. ${recipeState.message}';
            }
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final modifiedRecipe = state.modifiedRecipe!;
        final groups = <String, RecipeGroup>{
          for (final group
              in context.read<AbcuistoRepository>().user?.groups ??
                  const <RecipeGroup>[])
            if (group.id != null) group.id!: group,
          for (final group
              in widget.initialRecipe?.groups ?? const <RecipeGroup>[])
            if (group.id != null) group.id!: group,
        }.values.where((group) => !group.isPublic);
        final loading = state.status == AddRecipeStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              modifiedRecipe.id.isNotEmpty
                  ? 'Modifier la recette'
                  : 'Créer une recette',
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  tooltip: 'Enregistrer',
                  onPressed: loading ? null : cubit.save,
                  icon: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                ),
              ),
            ],
          ),
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: _ImageCarousel(
                  images: modifiedRecipe.documents,
                  onAdd: (file) => cubit.addPhoto(Uri.file(file.path)),
                  onReplace: (index, file) =>
                      cubit.replacePhoto(index, Uri.file(file.path)),
                  onRemove: cubit.removePhoto,
                ),
              ),
              TransparentPointer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 350),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            _RecipeField(
                              label: 'Nom de la recette',
                              value: modifiedRecipe.name,
                              onChanged: (value) => cubit.modify(
                                modifiedRecipe.copyWith(name: value),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const SectionTitle(
                              title: 'Catégorie de la recette',
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<RecipeCategory>(
                              initialValue: modifiedRecipe.category,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Choisir une catégorie',
                              ),
                              items: RecipeCategory.values
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category.displayName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (category) => cubit.modify(
                                modifiedRecipe.copyWith(category: category),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.spaceAround,
                              runSpacing: 8,
                              children: [
                                DurationPicker(
                                  label: 'Préparation',
                                  initialDuration: modifiedRecipe.prepTime,
                                  onDurationChanged: (duration) => cubit.modify(
                                    modifiedRecipe.copyWith(prepTime: duration),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DurationPicker(
                                  label: 'Cuisson',
                                  initialDuration: modifiedRecipe.cookTime,
                                  onDurationChanged: (duration) => cubit.modify(
                                    modifiedRecipe.copyWith(cookTime: duration),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DurationPicker(
                                  label: 'Repos',
                                  initialDuration: modifiedRecipe.restTime,
                                  onDurationChanged: (duration) => cubit.modify(
                                    modifiedRecipe.copyWith(restTime: duration),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const SectionTitle(
                              title: 'Visibilité de la recette',
                            ),
                            Material(
                              type: MaterialType.transparency,
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                secondary: const Icon(Icons.public),
                                title: const Text('Public'),
                                subtitle: const Text(
                                  'Visible par tout le monde, quels que soient les groupes sélectionnés.',
                                ),
                                value: modifiedRecipe.groups.any(
                                  (group) => group.isPublic,
                                ),
                                onChanged: loading ? null : cubit.setPublic,
                              ),
                            ),
                            if (groups.isNotEmpty) ...[
                              const Divider(),
                              const SectionTitle(
                                title: 'Partager avec des groupes',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                modifiedRecipe.groups.any(
                                      (group) => group.isPublic,
                                    )
                                    ? 'La recette est publique : ces groupes ne limitent pas sa visibilité.'
                                    : 'La recette est visible uniquement par les groupes sélectionnés.',
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: groups.map((group) {
                                  final id = group.id!;
                                  return FilterChip(
                                    label: Text(group.name ?? 'Groupe'),
                                    selected: modifiedRecipe.groups.any(
                                      (selected) => selected.id == id,
                                    ),
                                    onSelected: loading
                                        ? null
                                        : (selected) => cubit.selectGroup(
                                            group,
                                            selected,
                                          ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 16),
                            const SectionTitle(title: 'Tags'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: RecipeTag.values.map((tag) {
                                return FilterChip(
                                  label: Text(tag.displayName),
                                  selected: modifiedRecipe.tags.contains(tag),
                                  onSelected: (selected) => cubit.modify(
                                    modifiedRecipe.copyWith(
                                      tags: [
                                        ...modifiedRecipe.tags.where(
                                          (value) => value != tag,
                                        ),
                                        if (selected) tag,
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _RecipeField(
                                    label: 'Pour combien ?',
                                    value:
                                        modifiedRecipe.forNumber?.toString() ??
                                        '',
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => cubit.modify(
                                      modifiedRecipe.copyWith(
                                        forNumber:
                                            int.tryParse(value.trim()) ?? 0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child:
                                      DropdownButtonFormField<
                                        RecipeServingType
                                      >(
                                        initialValue:
                                            modifiedRecipe.typeNumber ??
                                            RecipeServingType.personnes,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        items: RecipeServingType.values
                                            .map(
                                              (type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(type.label),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (type) {
                                          if (type != null)
                                            cubit.modify(
                                              modifiedRecipe.copyWith(
                                                typeNumber: type,
                                              ),
                                            );
                                        },
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const SectionTitle(title: 'Ingrédients'),
                            const SizedBox(height: 8),
                            for (
                              var i = 0;
                              i < modifiedRecipe.ingredientCategories.length;
                              i++
                            )
                              IngredientCategoryWidget(
                                key: ValueKey(
                                  modifiedRecipe.ingredientCategories[i].index,
                                ),
                                category:
                                    modifiedRecipe.ingredientCategories[i],
                                categoryIndex: i,
                                showCategory:
                                    modifiedRecipe.ingredientCategories.length >
                                    1,
                              ),
                            TextButton.icon(
                              onPressed: cubit.addCategory,
                              icon: Icon(
                                modifiedRecipe.ingredientCategories.length > 1
                                    ? Icons.add_rounded
                                    : Icons.folder_open_rounded,
                              ),
                              label: Text(
                                modifiedRecipe.ingredientCategories.length > 1
                                    ? "Ajouter une catégorie d'ingrédients"
                                    : 'Organiser les ingrédients en catégories',
                              ),
                            ),
                            const SizedBox(height: 24),
                            const SectionTitle(title: 'Étapes'),
                            const SizedBox(height: 8),
                            ..._buildSteps(modifiedRecipe, cubit),
                            TextButton.icon(
                              onPressed: () {
                                if (loading) return;
                                final node = FocusNode();
                                _stepFocusNodes.add(node);
                                cubit.addStep();
                                node.requestFocus();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Ajouter une étape'),
                            ),
                            const SizedBox(height: 24),
                            const SectionTitle(title: 'Ustensiles'),
                            const SizedBox(height: 8),
                            _RecipeField(
                              label: 'Ex: fouet, casserole...',
                              value: modifiedRecipe.cookware.join(', '),
                              textInputAction: TextInputAction.done,
                              onChanged: (value) => cubit.modify(
                                modifiedRecipe.copyWith(
                                  cookware: value
                                      .split(',')
                                      .map((item) => item.trim())
                                      .where((item) => item.isNotEmpty)
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSteps(RecipeFull modifiedRecipe, AddRecipeCubit cubit) =>
      List.generate(modifiedRecipe.instructions.length, (index) {
        return Padding(
          key: ValueKey(_stepFocusNodes[index]),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: StepField(
                  index: index + 1,
                  value: modifiedRecipe.instructions[index],
                  focusNode: _stepFocusNodes[index],
                  onChanged: (value) => cubit.changeStep(index, value),
                ),
              ),
              if (modifiedRecipe.instructions.length > 1)
                IconButton(
                  tooltip: 'Supprimer l’étape',
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (cubit.state.status == AddRecipeStatus.loading) return;
                    _stepFocusNodes.removeAt(index).dispose();
                    cubit.removeStep(index);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
        );
      });
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class IngredientCategoryWidget extends StatefulWidget {
  final RecipeIngredientCategory category;
  final int categoryIndex;
  final bool showCategory;
  static const units = [
    '',
    'g',
    'kg',
    'mg',
    'L',
    'cL',
    'mL',
    'pièce(s)',
    'cuillère à café',
    'cuillère à soupe',
    'pincée(s)',
  ];

  const IngredientCategoryWidget({
    super.key,
    required this.category,
    required this.categoryIndex,
    required this.showCategory,
  });

  @override
  State<IngredientCategoryWidget> createState() =>
      _IngredientCategoryWidgetState();
}

class _IngredientCategoryWidgetState extends State<IngredientCategoryWidget> {
  final Map<int, FocusNode> _nameFocusNodes = {};

  @override
  void dispose() {
    for (final node in _nameFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddRecipeCubit>();
    final category = widget.category;
    final categoryIndex = widget.categoryIndex;
    final units = IngredientCategoryWidget.units;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showCategory) ...[
          Row(
            children: [
              Expanded(
                child: _RecipeField(
                  label: 'Nom de la catégorie',
                  value: category.name,
                  onChanged: (value) => cubit.changeCategory(
                    categoryIndex,
                    category.copyWith(name: value),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Supprimer la catégorie',
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => cubit.removeCategory(categoryIndex),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) =>
              cubit.reorderIngredient(categoryIndex, oldIndex, newIndex),
          children: category.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final availableUnits = units.contains(ingredient.type)
                ? units
                : [ingredient.type, ...units];
            return Padding(
              key: ValueKey(ingredient.index),
              padding: const EdgeInsets.only(bottom: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 500;
                  final nameField = _RecipeField(
                    label: 'Ingrédient',
                    value: ingredient.name,
                    focusNode: _nameFocusNodes.putIfAbsent(
                      ingredient.index,
                      () => FocusNode(),
                    ),
                    onChanged: (value) => cubit.changeIngredient(
                      categoryIndex,
                      index,
                      ingredient.copyWith(name: value),
                    ),
                  );
                  final quantityField = _RecipeField(
                    key: ValueKey(ingredient.type.isEmpty),
                    label: 'Qté',
                    value: ingredient.type.isEmpty
                        ? ''
                        : ingredient.quantity?.toString() ?? '',
                    enabled: ingredient.type.isNotEmpty,
                    onChanged: (value) =>
                        cubit.changeQuantity(categoryIndex, index, value),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  );
                  final unitField = DropdownButtonFormField<String>(
                    initialValue: ingredient.type,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    selectedItemBuilder: (context) => availableUnits
                        .map(
                          (unit) => Text(unit, overflow: TextOverflow.ellipsis),
                        )
                        .toList(),
                    items: availableUnits
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(
                              unit.isEmpty ? 'Sans unité' : unit,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (unit) {
                      if (unit != null)
                        cubit.changeIngredientUnit(categoryIndex, index, unit);
                    },
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        enabled:
                            category.ingredients.length > 1 &&
                            cubit.state.status != AddRecipeStatus.loading,
                        child: const Tooltip(
                          message: 'Déplacer l’ingrédient',
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.drag_handle_rounded, size: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: compact
                            ? Column(
                                children: [
                                  nameField,
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(child: quantityField),
                                      const SizedBox(width: 8),
                                      Expanded(flex: 2, child: unitField),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  SizedBox(width: 78, child: quantityField),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 180, child: unitField),
                                  const SizedBox(width: 8),
                                  Expanded(child: nameField),
                                ],
                              ),
                      ),
                      IconButton(
                        tooltip: 'Supprimer l’ingrédient',
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () =>
                            cubit.removeIngredient(categoryIndex, index),
                        icon: Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              if (cubit.state.status == AddRecipeStatus.loading) return;
              cubit.addIngredient(categoryIndex);
              final ingredient = cubit
                  .state
                  .modifiedRecipe!
                  .ingredientCategories[categoryIndex]
                  .ingredients
                  .last;
              _nameFocusNodes
                  .putIfAbsent(ingredient.index, () => FocusNode())
                  .requestFocus();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter un ingrédient'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class StepField extends StatelessWidget {
  final int index;
  final String value;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  const StepField({
    super.key,
    required this.index,
    required this.value,
    required this.onChanged,
    this.focusNode,
  });

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
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Étape $index',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 8),
            child: _RecipeField(
              label: 'Étape $index',
              value: value,
              onChanged: onChanged,
              maxLines: null,
              focusNode: focusNode,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final FocusNode? focusNode;
  final bool enabled;
  final TextInputAction textInputAction;

  const _RecipeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.focusNode,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
  });

  void _focusNextField() {
    final current = FocusManager.instance.primaryFocus;
    final scope = current?.nearestScope;
    if (current == null || scope == null) return;
    if (textInputAction == TextInputAction.done) {
      current.unfocus();
      return;
    }
    final fields = ReadingOrderTraversalPolicy.sort(
      scope.traversalDescendants.where(
        (node) =>
            node.context?.findAncestorWidgetOfExactType<EditableText>() != null,
      ),
    ).toList();
    final index = fields.indexOf(current);
    if (index >= 0 && index + 1 < fields.length) {
      FocusTraversalPolicy.defaultTraversalRequestFocusCallback(
        fields[index + 1],
      );
    } else {
      current.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value,
    focusNode: focusNode,
    enabled: enabled,
    onChanged: onChanged,
    keyboardType: keyboardType,
    textCapitalization: keyboardType == null
        ? TextCapitalization.sentences
        : TextCapitalization.none,
    autocorrect: keyboardType == null,
    enableSuggestions: keyboardType == null,
    textInputAction: textInputAction,
    onEditingComplete: _focusNextField,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: label,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _ImageCarousel extends StatefulWidget {
  final List<Uri> images;
  final ValueChanged<XFile> onAdd;
  final void Function(int index, XFile file) onReplace;
  final ValueChanged<int> onRemove;

  const _ImageCarousel({
    required this.images,
    required this.onAdd,
    required this.onReplace,
    required this.onRemove,
  });

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final ImagePicker _picker = ImagePicker();
  final PageController _controller = PageController();
  int _currentIndex = 0;

  int get _itemCount => widget.images.length;

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
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(1, 1),
                blurRadius: 5,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: PageView.builder(
              controller: _controller,
              itemCount: _itemCount == 0 ? 1 : _itemCount,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                if (_itemCount == 0) return const NoImageBuilder(height: 400);
                final uri = widget.images[index];
                return uri.scheme == 'file'
                    ? Image.file(
                        File(uri.toFilePath()),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const NoImageBuilder(height: 400),
                      )
                    : Image.network(
                        uri.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const NoImageBuilder(height: 400),
                      );
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
                final file = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (file != null && mounted) widget.onAdd(file);
              }),
              const SizedBox(width: 8),
              _buildButton(Icons.edit_rounded, 'Modifier', () async {
                if (_itemCount == 0) return;
                final file = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (file != null && mounted && _itemCount > 0)
                  widget.onReplace(_currentIndex, file);
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
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
