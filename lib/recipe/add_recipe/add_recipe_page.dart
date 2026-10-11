import 'dart:io';

import 'package:abcuisto/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_pointer/transparent_pointer.dart';

import '../../models/recipe.dart';
import '../recipes_list.dart' show NoImageBuilder;

class AddRecipePage extends StatelessWidget {
  final RecipeFull? initialRecipe;

  const AddRecipePage({super.key, this.initialRecipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(initialRecipe == null ? 'Créer une recette' : 'Modifier la recette'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.check_rounded)),
          ),
        ],
      ),
      body: CreateRecipeBody(initialRecipe: initialRecipe),
    );
  }
}

class CreateRecipeBody extends StatefulWidget {
  final RecipeFull? initialRecipe;

  const CreateRecipeBody({super.key, this.initialRecipe});

  @override
  State<CreateRecipeBody> createState() => _CreateRecipeBodyState();
}

class _CreateRecipeBodyState extends State<CreateRecipeBody> {
  // --- Controllers ---
  final _nameController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _restTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _utensilsController = TextEditingController();
  var _photoPaths = <String>[];

  // Dynamic lists
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  final List<IngredientCategory> _categories = [IngredientCategory()];

  @override
  void dispose() {
    _nameController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _restTimeController.dispose();
    _servingsController.dispose();
    _utensilsController.dispose();

    for (var c in _stepControllers) {
      c.dispose();
    }
    for (var cat in _categories) {
      cat.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.initialRecipe;
    _nameController.text = recipe?.name ?? '';
    _prepTimeController.text = recipe?.prepTimeFormatted ?? '';
    _cookTimeController.text = recipe?.cookTimeFormatted ?? '';
    _restTimeController.text = recipe?.restTimeFormatted ?? '';
    _servingsController.text = '';
    _utensilsController.text = recipe?.cookware.join(', ') ?? '';

    final width = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _ImageCarousel(imagePaths: _photoPaths),
        TransparentPointer(
          child: ListView(
            children: [
              Container(height: 350, width: MediaQuery.of(context).size.width, color: Colors.transparent),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        /// --- NAME ---
                        RoundedTextField(hintText: 'Nom de la recette', controller: _nameController),

                        const SizedBox(height: 16),

                        /// --- CATEGORY ---
                        const SectionTitle(title: "Catégorie de la recette"),
                        const SizedBox(height: 8),
                        const DropdownPlaceholder(),

                        const SizedBox(height: 16),

                        /// --- TIMES ---
                        Row(
                          children: [
                            Expanded(
                              child: RoundedTextField(
                                hintText: 'Temps de préparation',
                                controller: _prepTimeController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RoundedTextField(
                                hintText: 'Temps de cuisson',
                                controller: _cookTimeController,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RoundedTextField(
                                hintText: 'Temps de repos',
                                controller: _restTimeController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Container()),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// --- VISIBILITY ---
                        const SectionTitle(title: "Visible pour quels groupes ?"),
                        const SizedBox(height: 8),
                        RoundedTextField(hintText: '', controller: _restTimeController),
                        const SizedBox(height: 16),

                        /// --- CHARACTERISTICS ---
                        const SectionTitle(title: "Tags"),
                        const SizedBox(height: 8),
                        const DropdownPlaceholder(),

                        const SizedBox(height: 16),

                        /// --- SERVINGS ---
                        Row(
                          children: [
                            Expanded(
                              child: RoundedTextField(
                                hintText: 'Pour combien ?',
                                controller: _servingsController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(child: DropdownPlaceholder()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// --- INGREDIENTS ---
                        const SectionTitle(title: "Ingrédients"),
                        const SizedBox(height: 8),

                        ..._categories.map((cat) => IngredientCategoryWidget(category: cat)),

                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text("Ajouter une catégorie d'ingrédients"),
                        ),

                        const SizedBox(height: 24),

                        /// --- STEPS ---
                        const SectionTitle(title: "Étapes"),
                        const SizedBox(height: 8),

                        ..._buildSteps(),

                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text("Ajouter une étape"),
                        ),

                        const SizedBox(height: 24),

                        /// --- UTENSILS ---
                        const SectionTitle(title: "Ustensiles"),
                        const SizedBox(height: 8),

                        RoundedTextField(
                          hintText: 'Ex: fouet, casserole...',
                          controller: _utensilsController,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSteps() {
    return List.generate(_stepControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: StepField(index: index + 1, controller: _stepControllers[index]),
      );
    });
  }
}

/// ---------------------------
/// MODELS (controllers only)
/// ---------------------------

class IngredientCategory {
  final TextEditingController nameController = TextEditingController();
  final List<IngredientLine> ingredients = [IngredientLine()];

  void dispose() {
    nameController.dispose();
    for (var i in ingredients) {
      i.dispose();
    }
  }
}

class IngredientLine {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String? unit;

  void dispose() {
    quantityController.dispose();
    nameController.dispose();
  }
}

/// ---------------------------
/// WIDGETS
/// ---------------------------

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class DropdownPlaceholder extends StatelessWidget {
  const DropdownPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Icon(Icons.arrow_drop_down),
    );
  }
}

class IngredientCategoryWidget extends StatelessWidget {
  final IngredientCategory category;

  const IngredientCategoryWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedTextField(hintText: "Nom de la catégorie", controller: category.nameController),
        const SizedBox(height: 8),

        ...category.ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: RoundedTextField(hintText: "Qté", controller: ingredient.quantityController),
                ),
                const SizedBox(width: 8),
                const Expanded(child: DropdownPlaceholder()),
                const SizedBox(width: 8),
                Expanded(
                  child: RoundedTextField(hintText: "Ingrédient", controller: ingredient.nameController),
                ),
                IconButton(
                  icon: Icon(Icons.delete_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),
          );
        }),
        // Center(
        //   child: IconButton(
        //     onPressed: () {},
        //     icon: Icon(Icons.add_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
        //   ),
        // ),
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
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary, // border color
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index}',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text('Étape ${index}', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        const SizedBox(width: 8),
        Padding(
          padding: EdgeInsets.only(left: (22 - 2) / 2, top: 6, bottom: 6),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: RoundedTextField(hintText: "Étape $index", controller: controller, maxLines: 3),
            ),
          ),
        ),
        // Expanded(
        //   child: RoundedTextField(hintText: "Étape $index", controller: controller, maxLines: 3),
        // ),
      ],
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imagePaths;

  const _ImageCarousel({required this.imagePaths});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final ImagePicker _picker = ImagePicker();

  final PageController _controller = PageController();
  int _currentIndex = 0;

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
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imagePaths.isEmpty ? 1 : widget.imagePaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, i) {
                if (widget.imagePaths.isEmpty) {
                  return NoImageBuilder(height: 400);
                }
                return Image.file(
                  File(widget.imagePaths[i].toString()),
                  fit: BoxFit.cover,
                  // errorBuilder: (_, __, ___) => NoImageBuilder(height: 400),
                );
              },
            ),
          ),
        ),

        // Buttons to add, edit, or remove images
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(Icons.add_rounded, 'Ajouter', () {
                _picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
                  if (pickedFile != null && mounted) {
                    setState(() {
                      final insertIndex = widget.imagePaths.isEmpty ? 0 : _currentIndex + 1;
                      widget.imagePaths.insert(insertIndex, pickedFile.path);
                      _currentIndex = insertIndex;
                      _controller.animateToPage(
                        _currentIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  }
                });
              }),
              const SizedBox(width: 8),
              _buildButton(Icons.edit_rounded, 'Modifier', () {
                if (widget.imagePaths.isNotEmpty) {
                  _picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
                    if (pickedFile != null) {
                      setState(() {
                        widget.imagePaths[_currentIndex] = pickedFile.path;
                      });
                    }
                  });
                }
              }),
              const SizedBox(width: 8),
              _buildButton(Icons.delete_rounded, 'Supprimer', () {
                if (widget.imagePaths.isNotEmpty) {
                  setState(() {
                    widget.imagePaths.removeAt(_currentIndex);
                    if (_currentIndex >= widget.imagePaths.length) {
                      _currentIndex = widget.imagePaths.length - 1;
                    }
                    _controller.animateToPage(
                      _currentIndex,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              }),
            ],
          ),
        ),

        // Indicators
        Positioned(
          top: 335,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imagePaths.length, (i) {
              return Container(
                width: _currentIndex == i ? 16 : 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _currentIndex == i
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
    );
  }
}
