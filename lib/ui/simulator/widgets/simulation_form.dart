import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/crypto_asset.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:projet_investissement_flutter/utils/simulation_validators.dart';

/// Formulaire de paramétrage avec validation à la saisie et à l'envoi.
class SimulationForm extends StatefulWidget {
  const SimulationForm({
    super.key,
    required this.vsCurrency,
    required this.assets,
    required this.onSubmit,
    required this.onReset,
    this.isLoading = false,
  });

  final String vsCurrency;
  final List<CryptoAsset> assets;
  final Future<void> Function(SimulationInput) onSubmit;
  final VoidCallback onReset;
  final bool isLoading;

  @override
  State<SimulationForm> createState() => _SimulationFormState();
}

class _SimulationFormState extends State<SimulationForm> {
  static const _defaults = (
    initial: '1000',
    monthly: '100',
    rate: '7',
    years: '1',
  );

  final _formKey = GlobalKey<FormState>();
  final _initialController = TextEditingController(text: _defaults.initial);
  final _monthlyController = TextEditingController(text: _defaults.monthly);
  final _rateController = TextEditingController(text: _defaults.rate);
  final _yearsController = TextEditingController(text: _defaults.years);
  _SimulationMode _mode = _SimulationMode.fixedRate;
  String _fixedRateYears = _defaults.years;
  String? _selectedAssetId;

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final selectedAsset =
        _mode != _SimulationMode.crypto || _selectedAssetId == null
        ? null
        : widget.assets
              .where((asset) => asset.id == _selectedAssetId)
              .firstOrNull;
    await widget.onSubmit(
      SimulationInput(
        initialCapital: SimulationValidators.parseNumber(
          _initialController.text,
        )!,
        monthlyContribution: SimulationValidators.parseNumber(
          _monthlyController.text,
        )!,
        annualRatePercent: _mode == _SimulationMode.fixedRate
            ? SimulationValidators.parseNumber(_rateController.text)!
            : 0,
        years: SimulationValidators.parseNumber(_yearsController.text)!.toInt(),
        cryptoAsset: selectedAsset,
      ),
    );
  }

  void _reset() {
    _initialController.text = _defaults.initial;
    _monthlyController.text = _defaults.monthly;
    _rateController.text = _defaults.rate;
    _yearsController.text = _defaults.years;
    setState(() {
      _mode = _SimulationMode.fixedRate;
      _fixedRateYears = _defaults.years;
      _selectedAssetId = null;
    });
    _formKey.currentState!.reset();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = Formatters.currencySymbol(widget.vsCurrency);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          DropdownButtonFormField<_SimulationMode>(
            initialValue: _mode,
            decoration: const InputDecoration(
              labelText: 'Mode de simulation',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: _SimulationMode.fixedRate,
                child: Text('Rendement annuel fixe'),
              ),
              DropdownMenuItem(
                value: _SimulationMode.crypto,
                child: Text('Crypto (cours historiques)'),
              ),
            ],
            onChanged: widget.isLoading
                ? null
                : (mode) {
                    if (mode == null) return;
                    setState(() {
                      if (mode == _SimulationMode.crypto) {
                        _fixedRateYears = _yearsController.text;
                        _yearsController.text = '1';
                      } else {
                        _yearsController.text = _fixedRateYears;
                      }
                      _mode = mode;
                    });
                  },
          ),
          const SizedBox(height: 12),
          if (_mode == _SimulationMode.crypto) ...[
            DropdownButtonFormField<String>(
              key: ValueKey(
                '${widget.assets.length}:${_selectedAssetId ?? ''}',
              ),
              initialValue:
                  widget.assets.any((asset) => asset.id == _selectedAssetId)
                  ? _selectedAssetId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Crypto à simuler',
                border: OutlineInputBorder(),
              ),
              hint: Text(
                widget.assets.isEmpty
                    ? 'Aucune crypto disponible'
                    : 'Sélectionner une crypto',
              ),
              items: [
                for (final asset in widget.assets)
                  DropdownMenuItem(
                    value: asset.id,
                    child: Text(
                      '${asset.name} (${asset.symbol.toUpperCase()})',
                    ),
                  ),
              ],
              validator: (id) => id == null ? 'Choisis une crypto.' : null,
              onChanged: widget.isLoading
                  ? null
                  : (id) => setState(() => _selectedAssetId = id),
            ),
            const SizedBox(height: 12),
          ],
          _field(
            controller: _initialController,
            label: 'Capital de départ',
            suffix: symbol,
            validator: SimulationValidators.initialCapital,
          ),
          _field(
            controller: _monthlyController,
            label: 'Versement mensuel',
            suffix: '$symbol / mois',
            validator: (v) => SimulationValidators.monthlyContribution(
              v,
              initialValue: _initialController.text,
            ),
          ),
          if (_mode == _SimulationMode.fixedRate)
            _field(
              controller: _rateController,
              label: 'Rendement annuel supposé',
              suffix: '% / an',
              signed: true,
              validator: SimulationValidators.annualRate,
            ),
          _field(
            controller: _yearsController,
            label: 'Durée',
            suffix: 'ans',
            last: true,
            enabled: _mode == _SimulationMode.fixedRate,
            validator: SimulationValidators.years,
          ),
          if (_mode == _SimulationMode.crypto) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Les données de plus d’un an ne sont pas disponibles.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'La plage historique manquante sera complétée puis mise en '
                'cache pour limiter les appels suivants.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.isLoading ? null : _submit,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(widget.isLoading ? 'Chargement…' : 'Simuler'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: widget.isLoading ? null : _reset,
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String? Function(String?) validator,
    bool signed = false,
    bool last = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        enabled: enabled && !widget.isLoading,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: signed,
        ),
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: last ? (_) => _submit() : null,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

enum _SimulationMode { fixedRate, crypto }
