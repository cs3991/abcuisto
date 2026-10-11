import 'package:abcuisto/login/authentication_cubit.dart';
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

  static const List<String> tags = ["Végétarien", "Végan", "Alcoolisé", "Sans gluten", "Thermomix"];

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController creatorController = TextEditingController();
  bool isCreatorSelf = false;
  int totalTimeValue = 24;

  @override
  Widget build(BuildContext context) {
    creatorController.value = context.select(
      (FilterCubit cubit) => TextEditingValue(
        text: cubit.state.filter.creator ?? '',
        selection: TextSelection.collapsed(offset: cubit.state.filter.creator?.length ?? 0),
      ),
    );
    totalTimeValue = context.select((FilterCubit cubit) => cubit.state.filter.totalTime ?? 24);
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
                  (FilterCubit cubit) => cubit.state.filter.categories?.contains(category) ?? false,
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
            Text('Créé par', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            SegmentedButton(
              segments: [
                ButtonSegment<bool>(value: true, label: Text('Moi')),
                ButtonSegment<bool>(value: false, label: Text("Quelqu'un d'autre")),
              ],
              onSelectionChanged: (value) {
                if (value.first) {
                  final authState = context.read<AuthenticationCubit>().state;
                  final username = authState is AuthenticationLoggedIn ? authState.username : '';
                  creatorController.text = username;
                  context.read<FilterCubit>().updateFilteredCreatorName(username);
                } else {
                  creatorController.clear();
                  context.read<FilterCubit>().updateFilteredCreatorName('');
                }
                setState(() {
                  isCreatorSelf = value.first;
                });
              },
              selected: {isCreatorSelf},
            ),
            SizedBox(height: 8),
            TextField(
              controller: creatorController,
              decoration: InputDecoration(
                hintText: "Nom du créateur...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                filled: true,
                enabled: !isCreatorSelf,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              onChanged: (text) {
                context.read<FilterCubit>().updateFilteredCreatorName(text);
              },
            ),
            SizedBox(height: 16),
            BlocBuilder<FilterCubit, FilterState>(
              builder: (context, state) {
                final text = state.filter.totalTime == 24 || state.filter.totalTime == null
                    ? "Pas de limite"
                    : "${state.filter.totalTime}h";
                return Text('Temps total maximum : $text', style: Theme.of(context).textTheme.titleMedium);
              },
            ),
            MaxTimeSlider(totalTimeValue: totalTimeValue),
            SizedBox(height: 16),
            BlocBuilder<FilterCubit, FilterState>(
              builder: (context, state) {
                return ExpansionTile(
                  initiallyExpanded: true,
                  title: Text('Caractéristiques', style: Theme.of(context).textTheme.titleMedium),
                  children: FilterPage.tags.map((tag) {
                    final isSelected = state.filter.tags?.contains(tag) ?? false;
                    return CheckboxListTile(
                      title: Text(tag),
                      value: isSelected,
                      onChanged: (selected) {
                        context.read<FilterCubit>().updateFilteredTags(tag, selected ?? false);
                      },
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            Text('Ingrédients', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Ajouter des ingrédients...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class MaxTimeSlider extends StatefulWidget {
  final int totalTimeValue;

  const MaxTimeSlider({super.key, required this.totalTimeValue});

  @override
  State<MaxTimeSlider> createState() => _MaxTimeSliderState(totalTimeValue: totalTimeValue);
}

class _MaxTimeSliderState extends State<MaxTimeSlider> {
  int totalTimeValue;

  _MaxTimeSliderState({required this.totalTimeValue});

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: totalTimeValue.toDouble(),
      min: 1,
      max: 24,
      onChanged: (value) {
        setState(() {
          totalTimeValue = value.round();
        });
      },
      label: totalTimeValue == 24 ? "Pas de limite" : "${totalTimeValue}h",
      divisions: 23,
      semanticFormatterCallback: (value) => totalTimeValue == 24 ? "Pas de limite" : "${totalTimeValue}h",
      onChangeEnd: (value) {
        totalTimeValue == 24
            ? context.read<FilterCubit>().updateFilteredMaxTime(null)
            : context.read<FilterCubit>().updateFilteredMaxTime(totalTimeValue);
      },
    );
  }
}
