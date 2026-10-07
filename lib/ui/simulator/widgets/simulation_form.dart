import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/projection.dart';
import 'package:projet_investissement_flutter/utils/formatters.dart';
import 'package:projet_investissement_flutter/utils/simulation_validators.dart';

/// Formulaire de paramétrage avec validation à la saisie et à l'envoi.
class SimulationForm extends StatefulWidget {
  const SimulationForm({
    super.key,
    required this.vsCurrency,
    required this.onSubmit,
    required this.onReset,
  });

  final String vsCurrency;
  final ValueChanged<SimulationInput> onSubmit;
  final VoidCallback onReset;

  @override
  State<SimulationForm> createState() => _SimulationFormState();
}

class _SimulationFormState extends State<SimulationForm> {
  static const _defaults = (initial: '1000', monthly: '100', rate: '7', years: '10');

  final _formKey = GlobalKey<FormState>();
  final _initialController = TextEditingController(text: _defaults.initial);
  final _monthlyController = TextEditingController(text: _defaults.monthly);
  final _rateController = TextEditingController(text: _defaults.rate);
  final _yearsController = TextEditingController(text: _defaults.years);

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(SimulationInput(
      initialCapital: SimulationValidators.parseNumber(_initialController.text)!,
      monthlyContribution:
          SimulationValidators.parseNumber(_monthlyController.text)!,
      annualRatePercent: SimulationValidators.parseNumber(_rateController.text)!,
      years: SimulationValidators.parseNumber(_yearsController.text)!.toInt(),
    ));
  }

  void _reset() {
    _initialController.text = _defaults.initial;
    _monthlyController.text = _defaults.monthly;
    _rateController.text = _defaults.rate;
    _yearsController.text = _defaults.years;
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
            validator: SimulationValidators.years,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Simuler'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(onPressed: _reset, child: const Text('Réinitialiser')),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: signed),
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