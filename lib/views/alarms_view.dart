import 'package:flutter/material.dart';
import '../models/alarm.mod.dart';
import '../services/esp_service.dart';

class AlarmsView extends StatefulWidget {
  const AlarmsView({super.key});

  @override
  State<AlarmsView> createState() => _AlarmsViewState();
}

class _AlarmsViewState extends State<AlarmsView> {
  // Liste locale des alarmes (tu pourras plus tard les charger ou les sauvegarder)
  final List<Alarm> _alarms = [
    Alarm(time: "07:00", bips: 1, label: "Début des cours"),
    Alarm(time: "10:30", bips: 2, label: "Récréation"),
    Alarm(time: "12:00", bips: 3, label: "Fin des cours (matin)"),
  ];

  bool _isSyncing = false;

  // Fonction pour envoyer toutes les alarmes actives à l'ESP8266
  Future<void> _syncAlarmsToEsp() async {
    setState(() => _isSyncing = true);

    // On ne prend que les alarmes activées
    List<String> activeAlarmStrings = _alarms
        .where((a) => a.isActive)
        .map((a) => a.toEspFormat())
        .toList();

    bool success = await EspService.syncAllAlarms(activeAlarmStrings);
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Alarmes synchronisées avec la sirène !'
                : 'Erreur lors de la synchronisation',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Ouvrir une modale pour ajouter une nouvelle alarme
  void _showAddAlarmDialog() {
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedBips = 1;
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          title: const Text('Ajouter une alarme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Heure'),
                trailing: Text(
                  selectedTime.format(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setDialogState(() => selectedTime = time);
                  }
                },
              ),
              DropdownButtonFormField<int>(
                value: selectedBips,
                dropdownColor: const Color(0xFF161B22),
                decoration: const InputDecoration(labelText: 'Nombre de bips'),
                items: [1, 2, 3].map((bips) {
                  return DropdownMenuItem(
                    value: bips,
                    child: Text('$bips bips'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedBips = val);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label (ex: Récréation)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                final formattedTime =
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                setState(() {
                  _alarms.add(
                    Alarm(
                      time: formattedTime,
                      bips: selectedBips,
                      label: labelController.text.isEmpty
                          ? 'Sonnerie'
                          : labelController.text,
                    ),
                  );
                });
                Navigator.pop(context);
                // Synchronisation automatique vers l'ESP après l'ajout
                _syncAlarmsToEsp();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes alarmes'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blueAccent,
                    ),
                  )
                : const Icon(Icons.sync, color: Colors.blueAccent),
            tooltip: 'Synchroniser avec l\'ESP',
            onPressed: _isSyncing ? null : _syncAlarmsToEsp,
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: Colors.blueAccent,
              size: 28,
            ),
            onPressed: _showAddAlarmDialog,
          ),
        ],
      ),
      body: _alarms.isEmpty
          ? const Center(
              child: Text(
                'Aucune alarme enregistrée',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                alarm.time,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${alarm.bips} ${alarm.bips > 1 ? 'bips' : 'bip'}',
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            alarm.label,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: alarm.isActive,
                        activeColor: Colors.blueAccent,
                        onChanged: (val) {
                          setState(() {
                            alarm.isActive = val;
                          });
                          _syncAlarmsToEsp();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
