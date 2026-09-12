import 'package:flutter/material.dart';
import '../services/esp_service.dart';

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  bool _isLoading = false;

  Future<void> _lancerTest() async {
    setState(() => _isLoading = true);
    bool success = await EspService.triggerTest();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Signal de test envoyé à la sirène !'
                : 'Échec de la connexion à l\'ESP8266',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test manuel'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _lancerTest,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.2),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.blueAccent,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 60,
                          color: Colors.blueAccent,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'LANCER UNE SONNERIE',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            const Text(
              'Appuyez pour tester le relais',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
