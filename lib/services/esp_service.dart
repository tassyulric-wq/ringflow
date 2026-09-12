import 'package:http/http.dart' as http;

class EspService {
  static const String baseUrl = 'http://192.168.4.1';

  // Vérifier la connexion et récupérer l'heure
  static Future<String?> getStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/status'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return response.body; // Retourne l'heure du RTC
      }
    } catch (_) {}
    return null;
  }

  // Lancer un test manuel (ex: /test)
  static Future<bool> triggerTest() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/test'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Synchroniser toutes les alarmes d'un coup (/syncAll?data=...)
  static Future<bool> syncAllAlarms(List<String> alarmStrings) async {
    try {
      final data = alarmStrings.join(',');
      final response = await http
          .get(Uri.parse('$baseUrl/syncAll?data=$data'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Synchroniser l'heure du téléphone vers le RTC (/setrtc)
  static Future<bool> setRtcTime() async {
    try {
      final now = DateTime.now();
      final url =
          '$baseUrl/setrtc?year=${now.year}&month=${now.month}&day=${now.day}&hour=${now.hour}&minute=${now.minute}';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
