import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet_investissement_flutter/domain/models/glossary.dart';
import 'package:projet_investissement_flutter/routing/routes.dart';

/// Lien discret vers la définition d'une notion du lexique.
class LearnMoreLink extends StatelessWidget {
  const LearnMoreLink({super.key, required this.termId});

  final String termId;

  @override
  Widget build(BuildContext context) {
    final entry = glossaryEntry(termId);
    if (entry == null) return const SizedBox.shrink();
    return TextButton.icon(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: () => context.push(Routes.glossary(term: termId)),
      icon: const Icon(Icons.menu_book_outlined, size: 16),
      label: Text('Lexique : ${entry.term}'),
    );
  }
}
