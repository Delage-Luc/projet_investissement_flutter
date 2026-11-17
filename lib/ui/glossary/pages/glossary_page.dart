import 'package:flutter/material.dart';
import 'package:projet_investissement_flutter/domain/models/glossary.dart';

/// Lexique consultable hors connexion, avec recherche.
/// Ouvert depuis un écran avec [initialTermId], la notion est dépliée et
/// amenée à l'écran.
class GlossaryPage extends StatefulWidget {
  const GlossaryPage({super.key, this.initialTermId});

  final String? initialTermId;

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  /// Clé globale de la notion demandée, pour la faire défiler jusqu'à l'écran.
  final GlobalKey _targetKey = GlobalKey();
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialTermId != null) {
      // Après le premier rendu, la tuile existe et peut être rendue visible.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _targetKey.currentContext;
        if (target != null && target.mounted) {
          Scrollable.ensureVisible(
            target,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  List<GlossaryEntry> get _entries {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return glossary;
    return glossary
        .where(
          (e) =>
              e.term.toLowerCase().contains(q) ||
              e.definition.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return Scaffold(
      appBar: AppBar(title: const Text('Lexique')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher une notion',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('Aucune notion trouvée.'))
                : SingleChildScrollView(
                    // Hors onglets : on laisse la place de la barre système.
                    padding: EdgeInsets.only(
                      bottom: 24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        for (final e in entries)
                          _GlossaryTile(
                            // L'identité métier garde l'état déplié de chaque
                            // notion quand la recherche filtre la liste.
                            key: ValueKey(e.id),
                            entry: e,
                            targetKey: e.id == widget.initialTermId
                                ? _targetKey
                                : null,
                            initiallyExpanded: e.id == widget.initialTermId,
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GlossaryTile extends StatelessWidget {
  const _GlossaryTile({
    super.key,
    required this.entry,
    required this.initiallyExpanded,
    this.targetKey,
  });

  final GlossaryEntry entry;
  final bool initiallyExpanded;
  final GlobalKey? targetKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: targetKey,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.4),
        title: Text(
          entry.term,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(entry.definition),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calculate_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.example,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
