import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import 'ingredient_prices_cubit.dart';

class IngredientPricesPage extends StatelessWidget {
  const IngredientPricesPage({super.key});

  Future<void> _edit(BuildContext context, {int? index}) async {
    final cubit = context.read<IngredientPricesCubit>();
    final ingredient = index == null ? null : cubit.state.ingredients[index];
    cubit.startEditing(ingredient);
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _IngredientPriceDialog(index: index, ingredient: ingredient),
      ),
    );
    if (!context.mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prix enregistré.')));
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => IngredientPricesCubit(context.read<AbcuistoRepository>())..load(),
    child: BlocBuilder<IngredientPricesCubit, IngredientPricesState>(
      builder: (context, state) {
        final ready = state.status == IngredientPricesStatus.success && !state.saving;
        return Scaffold(
          appBar: AppBar(title: const Text('Mes prix d’ingrédients')),
          body: RefreshIndicator(
            onRefresh: context.read<IngredientPricesCubit>().load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Renseignez vos prix d’achat en euros, au kilo, au litre ou à la pièce.'),
                const SizedBox(height: 16),
                if (state.status == IngredientPricesStatus.loading)
                  const Center(child: CircularProgressIndicator()),
                if (state.errorMessage != null) ...[
                  Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  TextButton(onPressed: context.read<IngredientPricesCubit>().load, child: const Text('Réessayer')),
                ],
                if (ready && state.ingredients.isEmpty)
                  const Text('Aucun prix renseigné. Ajoutez votre premier ingrédient.'),
                for (var i = 0; i < state.ingredients.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(state.ingredients[i].name ?? 'Ingrédient'),
                    subtitle: Text('${state.ingredients[i].price.toString().replaceAll('.', ',')} € / ${state.ingredients[i].unit ?? 'unité inconnue'}'),
                    trailing: const Icon(Icons.edit_rounded),
                    enabled: ready,
                    onTap: ready ? () => _edit(context, index: i) : null,
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: ready ? () => _edit(context) : null,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ajouter un ingrédient'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _IngredientPriceDialog extends StatefulWidget {
  final int? index;
  final IngredientPriceInput? ingredient;

  const _IngredientPriceDialog({this.index, this.ingredient});

  @override
  State<_IngredientPriceDialog> createState() => _IngredientPriceDialogState();
}

class _IngredientPriceDialogState extends State<_IngredientPriceDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.ingredient?.name);
  late final TextEditingController _price = TextEditingController(
    text: widget.ingredient?.price.toString().replaceAll('.', ',') ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await context.read<IngredientPricesCubit>().save(
      index: widget.index, name: _name.text, price: _price.text,
    );
    if (mounted && saved) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<IngredientPricesCubit, IngredientPricesState>(
    builder: (context, state) {
      final busy = state.saving || state.status == IngredientPricesStatus.loading;
      return PopScope(
        canPop: !busy,
        child: AlertDialog(
          title: Text(widget.index == null ? 'Ajouter un prix' : 'Modifier le prix'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _name,
                  autofocus: true,
                  enabled: !busy,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Ingrédient', hintText: 'Farine'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _price,
                  enabled: !busy,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Prix', suffixText: '€'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: IngredientPricesCubit.units.contains(state.unit) ? state.unit : null,
                  decoration: const InputDecoration(labelText: 'Pour'),
                  items: const [
                    DropdownMenuItem(value: 'kg', child: Text('1 kilo')),
                    DropdownMenuItem(value: 'L', child: Text('1 litre')),
                    DropdownMenuItem(value: 'pièce(s)', child: Text('1 pièce')),
                  ],
                  onChanged: busy ? null : (unit) {
                    if (unit != null) context.read<IngredientPricesCubit>().changeUnit(unit);
                  },
                ),
                if (state.saveError != null) ...[
                  const SizedBox(height: 12),
                  Text(state.saveError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: busy ? null : () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            FilledButton(onPressed: busy ? null : _save, child: Text(busy ? 'Enregistrement…' : 'Enregistrer')),
          ],
        ),
      );
    },
  );
}
