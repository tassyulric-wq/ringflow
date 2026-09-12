import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/esp_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isLoading = false;

  // Synchroniser l'heure du téléphone vers le RTC de l'ESP
  Future<void> _syncRtcTime() async {
    setState(() => _isLoading = true);
    bool success = await EspService.setRtcTime();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Heure du téléphone poussée vers l\'ESP avec succès !'
                : 'Échec de la synchronisation RTC',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Effacer la mémoire EEPROM des alarmes (/clear)
  Future<void> _clearEspAlarms() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Réinitialiser la mémoire'),
        content: const Text(
          'Voulez-vous vraiment effacer toutes les alarmes stockées dans l\'EEPROM de l\'ESP8266 ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Effacer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      bool success = false;
      try {
        final response = await http
            .get(Uri.parse('${EspService.baseUrl}/clear'))
            .timeout(const Duration(seconds: 3));
        success = response.statusCode == 200;
      } catch (_) {}
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Mémoire de l\'ESP effacée avec succès !'
                  : 'Échec de la réinitialisation',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'GESTION MATÉRIEL',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.sync_alt,
                          color: Colors.blueAccent,
                        ),
                        title: const Text('Synchroniser l\'heure (RTC)'),
                        subtitle: const Text(
                          'Met à jour l\'horloge interne de la sirène',
                        ),
                        onTap: _syncRtcTime,
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_sweep,
                          color: Colors.redAccent,
                        ),
                        title: const Text('Effacer les alarmes (EEPROM)'),
                        subtitle: const Text(
                          'Vide toutes les programmations de l\'ESP',
                        ),
                        onTap: _clearEspAlarms,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'À PROPOS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.grey),
                    title: Text('RingFlow IoT Controller'),
                    subtitle: Text('Version 1.0.0 • Connexion Wi-Fi Direct'),
                  ),
                ),
              ],
            ),
    );
  }
}
