import 'dart:async';
import 'package:flutter/material.dart';
import '../services/esp_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isConnected = false;
  String _espTime = "--:--:--";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Vérifie le statut et l'heure toutes les 3 secondes
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final time = await EspService.getStatus();
    if (mounted) {
      setState(() {
        if (time != null) {
          _isConnected = true;
          _espTime = time;
        } else {
          _isConnected = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RingFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              backgroundColor: _isConnected
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              label: Text(
                _isConnected ? 'Connecté' : 'Déconnecté',
                style: TextStyle(
                  color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                ),
              ),
              side: BorderSide(color: _isConnected ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_isConnected ? Colors.blueAccent : Colors.grey)
                          .withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isConnected ? Colors.blueAccent : Colors.grey)
                                  .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      size: 50,
                      color: _isConnected ? Colors.blueAccent : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isConnected ? 'SYSTÈME ACTIF' : 'SYSTÈME DÉCONNECTÉ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: _isConnected ? Colors.white : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConnected
                        ? 'RingFlow est relié à la sirène'
                        : 'Vérifiez le Wi-Fi (RingFlow)',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Heure actuelle (RTC)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _espTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.access_time,
                    size: 40,
                    color: Colors.blueAccent.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
