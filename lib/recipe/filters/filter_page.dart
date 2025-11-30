import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(),
      body: ListView(
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            title: Text('Catégories', style: Theme.of(context).textTheme.titleMedium),
            children: categories.map((category) {
              final isSelected = context.select(
                (FilterCubit cubit) => cubit.state.selectedCategories.contains(category),
              );
              return CheckboxListTile(
                title: Text(category),
                value: isSelected,
                onChanged: (selected) {
                  context.read<FilterCubit>().updateSelectedCategories(category, selected ?? false);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
