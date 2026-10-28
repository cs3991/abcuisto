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
  @override
  void initState() {
    super.initState();
    context.read<AddRecipeCubit>().initialize(widget.initialRecipe);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddRecipeCubit>();
    return BlocConsumer<AddRecipeCubit, AddRecipeState>(
      listener: (context, state) async {
        if (state.status == AddRecipeStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
        } else if (state.status == AddRecipeStatus.success) {
          context.read<FilterCubit>().update();
          context.read<AddRecipeCubit>().initialize(null);
          final recipeId = state.modifiedRecipe!.id;
          var message = recipeId.isEmpty ? 'Recette créée.' : 'Recette modifiée.';
          if (recipeId.isNotEmpty) {
            try {
              await context.read<RecipeCubit>().refreshRecipe(recipeId: recipeId);
            } catch (error) {
              message = 'Recette enregistrée, mais impossible de la recharger : $error';
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
              }
              rethrow;
            }
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final modifiedRecipe = state.modifiedRecipe!;
        final groups = <String, RecipeGroup>{
          for (final group in context.read<AbcuistoRepository>().user?.groups ?? const <RecipeGroup>[])
            if (group.id != null) group.id!: group,
          for (final group in widget.initialRecipe?.groups ?? const <RecipeGroup>[])
            if (group.id != null) group.id!: group,
        }.values.where((group) => !group.isPublic);
        final loading = state.status == AddRecipeStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: Text(modifiedRecipe.id.isNotEmpty ? 'Modifier la recette' : 'Créer une recette'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  tooltip: 'Enregistrer',
                  onPressed: loading ? null : cubit.save,
                  icon: loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
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
                  onReplace: (index, file) => cubit.replacePhoto(index, Uri.file(file.path)),
                  onRemove: cubit.removePhoto,
                ),
              ),
              TransparentPointer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 350),
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
                      _RecipeField(
                        label: 'Nom de la recette',
                        value: modifiedRecipe.name,
                        onChanged: (value) => cubit.modify(modifiedRecipe.copyWith(name: value)),
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Catégorie de la recette'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RecipeCategory>(
                        initialValue: modifiedRecipe.category,
                        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Choisir une catégorie'),
                        items: RecipeCategory.values.map((category) => DropdownMenuItem(value: category, child: Text(category.displayName))).toList(),
                        onChanged: (category) => cubit.modify(modifiedRecipe.copyWith(category: category)),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        runSpacing: 8,
                        children: [
                          DurationPicker(
                            label: 'Préparation',
                            initialDuration: modifiedRecipe.prepTime,
                            onDurationChanged: (duration) => cubit.modify(modifiedRecipe.copyWith(prepTime: duration)),
                          ),
                          const SizedBox(width: 8),
                          DurationPicker(
                            label: 'Cuisson',
                            initialDuration: modifiedRecipe.cookTime,
                            onDurationChanged: (duration) => cubit.modify(modifiedRecipe.copyWith(cookTime: duration)),
                          ),
                          const SizedBox(width: 8),
                          DurationPicker(
                            label: 'Repos',
                            initialDuration: modifiedRecipe.restTime,
                            onDurationChanged: (duration) => cubit.modify(modifiedRecipe.copyWith(restTime: duration)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SectionTitle(title: 'Visibilité de la recette'),
                      Material(
                        type: MaterialType.transparency,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.public),
                          title: const Text('Public'),
                          subtitle: const Text('Visible par tout le monde, quels que soient les groupes sélectionnés.'),
                          value: modifiedRecipe.groups.any((group) => group.isPublic),
                          onChanged: loading ? null : cubit.setPublic,
                        ),
                      ),
                      if (groups.isNotEmpty) ...[
                        const Divider(),
                        const SectionTitle(title: 'Partager avec des groupes'),
                        const SizedBox(height: 8),
                        Text(modifiedRecipe.groups.any((group) => group.isPublic)
                            ? 'La recette est publique : ces groupes ne limitent pas sa visibilité.'
                            : 'La recette est visible uniquement par les groupes sélectionnés.'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: groups.map((group) {
                            final id = group.id!;
                            return FilterChip(
                              label: Text(group.name ?? 'Groupe'),
                              selected: modifiedRecipe.groups.any((selected) => selected.id == id),
                              onSelected: loading ? null : (selected) => cubit.selectGroup(group, selected),
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
                              modifiedRecipe.copyWith(tags: [...modifiedRecipe.tags.where((value) => value != tag), if (selected) tag]),
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
                              value: modifiedRecipe.forNumber?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => cubit.modify(modifiedRecipe.copyWith(forNumber: int.tryParse(value.trim()) ?? 0)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<RecipeServingType>(
                              initialValue: modifiedRecipe.typeNumber ?? RecipeServingType.personnes,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: RecipeServingType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.label))).toList(),
                              onChanged: (type) {
                                if (type != null) cubit.modify(modifiedRecipe.copyWith(typeNumber: type));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Ingrédients'),
                      const SizedBox(height: 8),
                      for (var i = 0; i < modifiedRecipe.ingredientCategories.length; i++)
                        IngredientCategoryWidget(
                          key: ValueKey(modifiedRecipe.ingredientCategories[i].index),
                          category: modifiedRecipe.ingredientCategories[i],
                          categoryIndex: i,
                        ),
                      TextButton.icon(
                        onPressed: cubit.addCategory,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter une catégorie d'ingrédients"),
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Étapes'),
                      const SizedBox(height: 8),
                      ..._buildSteps(modifiedRecipe, cubit),
                      TextButton.icon(onPressed: cubit.addStep, icon: const Icon(Icons.add), label: const Text('Ajouter une étape')),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Ustensiles'),
                      const SizedBox(height: 8),
                      _RecipeField(
                        label: 'Ex: fouet, casserole...',
                        value: modifiedRecipe.cookware.join(', '),
                        onChanged: (value) => cubit.modify(
                          modifiedRecipe.copyWith(cookware: value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList()),
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

  List<Widget> _buildSteps(RecipeFull modifiedRecipe, AddRecipeCubit cubit) => List.generate(modifiedRecipe.instructions.length, (index) {
    return Padding(
      key: ValueKey('step-${modifiedRecipe.instructions.length}-$index'),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StepField(index: index + 1, value: modifiedRecipe.instructions[index], onChanged: (value) => cubit.changeStep(index, value)),
          ),
          if (modifiedRecipe.instructions.length > 1)
            IconButton(tooltip: 'Supprimer l’étape', onPressed: () => cubit.removeStep(index), icon: const Icon(Icons.delete_outline)),
        ],
      ),
    );
  });
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class IngredientCategoryWidget extends StatelessWidget {
  final RecipeIngredientCategory category;
  final int categoryIndex;
  static const units = ['g', 'kg', 'mg', 'L', 'cL', 'mL', 'pièce(s)', 'cuillère à café', 'cuillère à soupe', 'pincée(s)'];

  const IngredientCategoryWidget({super.key, required this.category, required this.categoryIndex});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddRecipeCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _RecipeField(
                label: 'Nom de la catégorie',
                value: category.name,
                onChanged: (value) => cubit.changeCategory(categoryIndex, category.copyWith(name: value)),
              ),
            ),
            IconButton(
              tooltip: 'Supprimer la catégorie',
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => cubit.removeCategory(categoryIndex),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...category.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          final availableUnits = units.contains(ingredient.type) ? units : [ingredient.type, ...units];
          return Padding(
            key: ValueKey(ingredient.index),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                SizedBox(
                  width: 78,
                  child: _RecipeField(
                    label: 'Qté',
                    value: ingredient.quantity?.toString() ?? '',
                    onChanged: (value) => cubit.changeQuantity(categoryIndex, index, value),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 112,
                  child: DropdownButtonFormField<String>(
                    initialValue: ingredient.type,
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
                      if (unit != null) cubit.changeIngredient(categoryIndex, index, ingredient.copyWith(type: unit));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RecipeField(
                    label: 'Ingrédient',
                    value: ingredient.name,
                    onChanged: (value) => cubit.changeIngredient(categoryIndex, index, ingredient.copyWith(name: value)),
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer l’ingrédient',
                  onPressed: () => cubit.removeIngredient(categoryIndex, index),
                  icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => cubit.addIngredient(categoryIndex),
            icon: const Icon(Icons.add),
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

  const StepField({super.key, required this.index, required this.value, required this.onChanged});

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
            child: _RecipeField(label: 'Étape $index', value: value, onChanged: onChanged, maxLines: 3),
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
  final int maxLines;

  const _RecipeField({required this.label, required this.value, required this.onChanged, this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value,
    onChanged: onChanged,
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: label,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
    ),
  );
}

class _ImageCarousel extends StatefulWidget {
  final List<Uri> images;
  final ValueChanged<XFile> onAdd;
  final void Function(int index, XFile file) onReplace;
  final ValueChanged<int> onRemove;

  const _ImageCarousel({required this.images, required this.onAdd, required this.onReplace, required this.onRemove});

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
                final uri = widget.images[index];
                return uri.scheme == 'file'
                    ? Image.file(
                        File(uri.toFilePath()),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const NoImageBuilder(height: 400),
                      )
                    : Image.network(
                        uri.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const NoImageBuilder(height: 400),
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
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null && mounted) widget.onAdd(file);
              }),
              const SizedBox(width: 8),
              _buildButton(Icons.edit_rounded, 'Modifier', () async {
                if (_itemCount == 0) return;
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null && mounted && _itemCount > 0) widget.onReplace(_currentIndex, file);
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
