import 'package:flutter/material.dart';

/// Longueur maximale du nom d'une simulation.
const int maxSimulationNameLength = 40;

/// Validation du nom (convention `TextFormField.validator`).
String? validateSimulationName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Donne un nom à ta simulation.';
  if (name.length > maxSimulationNameLength) {
    return '$maxSimulationNameLength caractères maximum.';
  }
  return null;
}

/// Demande un nom ; renvoie le nom validé, ou null si l'utilisateur annule.
Future<String?> showSaveSimulationDialog(
  BuildContext context, {
  required String suggestedName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _SaveSimulationDialog(suggestedName: suggestedName),
  );
}

class _SaveSimulationDialog extends StatefulWidget {
  const _SaveSimulationDialog({required this.suggestedName});

  final String suggestedName;

  @override
  State<_SaveSimulationDialog> createState() => _SaveSimulationDialogState();
}

class _SaveSimulationDialogState extends State<_SaveSimulationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.suggestedName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sauvegarder la simulation'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: maxSimulationNameLength,
          validator: validateSimulationName,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Sauvegarder')),
      ],
    );
  }
}
