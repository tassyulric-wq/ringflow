class Alarm {
  String time; // ex: "07:00"
  int bips; // ex: 1
  String label; // ex: "Début des cours"
  bool isActive;

  Alarm({
    required this.time,
    required this.bips,
    required this.label,
    this.isActive = true,
  });

  // Convertit l'alarme au format attendu par l'ESP8266 (ex: "07:00|1")
  String toEspFormat() => '$time|$bips';
}
