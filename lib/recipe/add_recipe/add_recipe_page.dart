import 'dart:io';

import 'package:abcuisto/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipePage extends StatelessWidget {
  const AddRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une recette'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.check_rounded)),
          ),
        ],
      ),
      body: CreateRecipeBody(),
    );
  }
}

class CreateRecipeBody extends StatefulWidget {
  const CreateRecipeBody({super.key});

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
    final width = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
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
            child: SizedBox(
              height: 400,
              width: 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photoPaths.isEmpty ? 1 : _photoPaths.length + 1,
                itemBuilder: (context, i) {
                  if (i < _photoPaths.length) {
                    final path = _photoPaths[i];
                    return SizedBox(
                      width: width,
                      child: Image.file(File(path), fit: BoxFit.cover),
                    );
                  } else {
                    return SizedBox(
                      width: width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.no_photography_rounded,
                            size: 70,
                            color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(50),
                          ),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text("Ajouter une photo"),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        ListView(
          children: [
            GestureDetector(
              child: Container(
                height: 350,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
              ),
              onTap: () {
                print("Open image picker");
                // Todo: open image picker
                ImagePicker().pickImage(source: ImageSource.gallery).then((pickedFile) {
                  if (pickedFile != null) {
                    setState(() {
                      _photoPaths.add(pickedFile.path);
                    });
                  }
                });
              },
            ),
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
                            child: RoundedTextField(hintText: 'Préparation', controller: _prepTimeController),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RoundedTextField(hintText: 'Cuisson', controller: _cookTimeController),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      RoundedTextField(hintText: 'Repos', controller: _restTimeController),

                      const SizedBox(height: 16),

                      /// --- VISIBILITY ---
                      const SectionTitle(title: "Visible pour quels groupes ?"),
                      const SizedBox(height: 8),
                      const DropdownPlaceholder(),

                      const SizedBox(height: 16),

                      /// --- CHARACTERISTICS ---
                      const SectionTitle(title: "Caractéristiques"),
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

                      /// --- UTENSILS ---
                      const SectionTitle(title: "Ustensiles"),
                      const SizedBox(height: 8),

                      RoundedTextField(hintText: 'Ex: fouet, casserole...', controller: _utensilsController),

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

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
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
                SizedBox(
                  width: 80,
                  child: RoundedTextField(hintText: "0", controller: ingredient.quantityController),
                ),
                const SizedBox(width: 8),
                const Expanded(child: DropdownPlaceholder()),
                const SizedBox(width: 8),
                Expanded(
                  child: RoundedTextField(hintText: "Ingrédient", controller: ingredient.nameController),
                ),
              ],
            ),
          );
        }),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 12, child: Text(index.toString())),
        const SizedBox(width: 8),
        Expanded(
          child: RoundedTextField(hintText: "Étape $index", controller: controller, maxLines: 3),
        ),
      ],
    );
  }
}
