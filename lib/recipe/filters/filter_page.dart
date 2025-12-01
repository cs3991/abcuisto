import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  static const List<String> categories = [
    "Apéritif",
    "Entrée",
    "Plat",
    "Fromage",
    "Dessert",
    "Petit-déjeuner",
    "Boisson",
    "Sauce",
  ];

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController creatorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    creatorController.value = context.select(
      (FilterCubit cubit) => TextEditingValue(
        text: cubit.state.filteredCreatorName ?? '',
        selection: TextSelection.collapsed(offset: cubit.state.filteredCreatorName?.length ?? 0),
      ),
    );
    return Scaffold(
      appBar: SearchAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            SizedBox(height: 16),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text('Catégories', style: Theme.of(context).textTheme.titleMedium),
              children: FilterPage.categories.map((category) {
                final isSelected = context.select(
                  (FilterCubit cubit) => cubit.state.filteredCategories.contains(category),
                );
                return CheckboxListTile(
                  title: Text(category),
                  value: isSelected,
                  onChanged: (selected) {
                    context.read<FilterCubit>().updateFilteredCategories(category, selected ?? false);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Créée par', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: creatorController,
              decoration: InputDecoration(
                hintText: 'Nom du créateur',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              onChanged: (text) {
                context.read<FilterCubit>().updateFilteredCreatorName(text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
