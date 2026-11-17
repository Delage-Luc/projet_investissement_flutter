/// Une notion du lexique, avec un exemple chiffré.
class GlossaryEntry {
  const GlossaryEntry({
    required this.id,
    required this.term,
    required this.definition,
    required this.example,
  });

  /// Identifiant stable, utilisé dans les liens (`/glossary?term=id`).
  final String id;
  final String term;
  final String definition;
  final String example;
}

/// Identifiants des notions référencées depuis les écrans.
class GlossaryTerms {
  const GlossaryTerms._();

  static const String performance = 'performance';
  static const String gain = 'plus-value';
  static const String volatility = 'volatilite';
  static const String drawdown = 'drawdown';
  static const String dca = 'dca';
  static const String lumpSum = 'investissement-unique';
  static const String compound = 'interets-composes';
  static const String score = 'score';
  static const String diversification = 'diversification';
  static const String marketCap = 'capitalisation';
  static const String crypto = 'crypto';
  static const String currency = 'devise';
}

/// Lexique de l'application, du plus fondamental au plus spécifique.
const List<GlossaryEntry> glossary = [
  GlossaryEntry(
    id: GlossaryTerms.performance,
    term: 'Performance',
    definition:
        'Variation de la valeur d\'un investissement entre deux dates, '
        'en pourcentage : (valeur finale − valeur initiale) ÷ valeur '
        'initiale × 100.',
    example:
        '100 € qui deviennent 120 € : performance de +20 %. '
        '100 € qui deviennent 80 € : −20 %.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.gain,
    term: 'Plus-value / moins-value',
    definition:
        'Gain (ou perte) en euros : valeur actuelle − montant investi. '
        'Tant que l\'on n\'a pas vendu, elle est dite « latente » : elle peut '
        'encore changer.',
    example:
        '1 000 € investis valant aujourd\'hui 1 180 € : plus-value '
        'latente de 180 €.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.volatility,
    term: 'Volatilité',
    definition:
        'Mesure de l\'ampleur des variations du prix. On calcule '
        'l\'écart-type des variations quotidiennes, puis on l\'annualise '
        '(× √365). Plus elle est élevée, plus le prix est imprévisible : '
        'un rendement potentiel élevé va souvent avec un risque élevé.',
    example:
        'Un grand indice d\'actions a souvent une volatilité de 15 à 20 % '
        'par an ; beaucoup de cryptos dépassent 60 %.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.drawdown,
    term: 'Baisse maximale (drawdown)',
    definition:
        'Plus forte chute observée entre un sommet et le point le plus '
        'bas qui le suit. Elle répond à la question : « quel est le pire '
        'moment qu\'aurait vécu un investisseur ? »',
    example:
        '100 → 125 → 90 → 105 : le sommet est 125, le creux 90, soit '
        '(90 − 125) ÷ 125 = −28 %.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.dca,
    term: 'DCA (investissement programmé)',
    definition:
        'Dollar-Cost Averaging : investir la même somme à intervalles '
        'réguliers, quel que soit le prix. On achète plus d\'unités quand le '
        'prix est bas et moins quand il est haut, ce qui lisse le prix '
        'moyen d\'achat.',
    example:
        '100 € par mois : à 50 € l\'unité on en achète 2, à 100 € une '
        'seule. Prix moyen payé : 66,67 €, et non 75 €.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.lumpSum,
    term: 'Investissement en une fois',
    definition:
        'Placer toute la somme dès le départ. Si le marché monte, '
        'c\'est en général plus rentable que le DCA (l\'argent travaille plus '
        'longtemps) ; s\'il baisse juste après, la perte est plus forte. Le '
        'DCA réduit le risque de « mal tomber ».',
    example:
        '1 200 € investis d\'un coup en janvier, contre 100 € par mois '
        'pendant un an.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.compound,
    term: 'Intérêts composés',
    definition:
        'Les gains produisent à leur tour des gains : capital final = '
        'capital initial × (1 + taux)^années. L\'effet devient très '
        'visible sur de longues durées.',
    example:
        '1 000 € à 5 % par an : 1 050 € après 1 an, 1 629 € après '
        '10 ans, 4 322 € après 30 ans.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.score,
    term: 'Score de l\'application',
    definition:
        'Note sur 100 qui résume la performance, la stabilité et la '
        'résistance aux baisses observées sur la période. Chaque critère est '
        'ramené entre 0 et 100, puis pondéré (40 %, 30 %, 30 %). Il décrit '
        'le passé et ne prédit rien.',
    example:
        'Performance 50/100, stabilité 20/100, résistance 60/100 → '
        '50 × 0,4 + 20 × 0,3 + 60 × 0,3 = 44/100.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.diversification,
    term: 'Diversification',
    definition:
        'Répartir son argent entre plusieurs actifs pour qu\'une '
        'mauvaise surprise sur l\'un ne ruine pas l\'ensemble. Attention : '
        'les cryptos ont tendance à monter et baisser ensemble, en posséder '
        'plusieurs diversifie peu.',
    example:
        '1 000 € répartis sur 10 actifs : si l\'un perd 50 %, le '
        'portefeuille ne perd que 5 %.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.marketCap,
    term: 'Capitalisation',
    definition:
        'Valeur totale d\'un actif : prix d\'une unité × nombre '
        'd\'unités en circulation. Elle sert à classer les cryptos par taille.',
    example:
        '19 millions de bitcoins à 60 000 € : capitalisation de '
        '1 140 milliards d\'euros.',
  ),
  GlossaryEntry(
    id: GlossaryTerms.crypto,
    term: 'Cryptomonnaie',
    definition:
        'Actif numérique enregistré sur une blockchain. Son prix '
        'dépend uniquement de l\'offre et de la demande : il n\'y a ni '
        'dividende ni garantie, d\'où de fortes variations.',
    example: 'Bitcoin, Ethereum, Solana…',
  ),
  GlossaryEntry(
    id: GlossaryTerms.currency,
    term: 'Devise d\'affichage',
    definition:
        'Les prix peuvent être affichés en euros ou en dollars. Pour un '
        'investisseur européen, la performance en euros dépend aussi du taux '
        'de change EUR/USD.',
    example:
        'Une crypto stable en dollars peut gagner en euros si le dollar '
        'se renforce face à l\'euro.',
  ),
];

/// Retrouve une notion par son identifiant.
GlossaryEntry? glossaryEntry(String id) {
  for (final e in glossary) {
    if (e.id == id) return e;
  }
  return null;
}
