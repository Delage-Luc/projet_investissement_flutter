/// Périodes proposées sur la fiche d'un actif.
enum ChartPeriod {
  month(30, '30 j'),
  quarter(90, '90 j'),
  year(365, '1 an');

  const ChartPeriod(this.days, this.label);

  final int days;
  final String label;
}
