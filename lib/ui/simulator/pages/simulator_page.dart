import 'package:flutter/material.dart';

/// Écran provisoire du simulateur DCA.
class SimulatorPage extends StatelessWidget {
  const SimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulateur')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Bientôt : simulateur DCA paramétrique et simulateur '
            '« et si j\'avais investi… » sur données historiques.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
