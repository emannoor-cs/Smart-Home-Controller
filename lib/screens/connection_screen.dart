import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/mqtt_service.dart';
import 'dashboard_screen.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final mqttServiceProvider = Provider<MqttService>((ref) {
  final service = MqttService();
  ref.onDispose(() => service.dispose());
  return service;
});

enum ConnectionState2 { idle, connecting, connected, failed }

final connectionStateProvider =
    StateProvider<ConnectionState2>((ref) => ConnectionState2.idle);

// ── Screen ───────────────────────────────────────────────────────────────────

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  // ✅ Updated to test.mosquitto.org and port 8081
  final _brokerController = TextEditingController(text: 'test.mosquitto.org');
  final _portController = TextEditingController(text: '8081');
  final _clientIdController = TextEditingController(text: 'flutter-home-001');

  @override
  void dispose() {
    _brokerController.dispose();
    _portController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    ref.read(connectionStateProvider.notifier).state =
        ConnectionState2.connecting;

    final mqttService = ref.read(mqttServiceProvider);

    final success = await mqttService.connect(
      brokerUrl: _brokerController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 8081,
      clientId: _clientIdController.text.trim(),
    );

    if (success) {
      ref.read(connectionStateProvider.notifier).state =
          ConnectionState2.connected;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      ref.read(connectionStateProvider.notifier).state =
          ConnectionState2.failed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connState = ref.watch(connectionStateProvider);
    final isConnecting = connState == ConnectionState2.connecting;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // ← prevents overflow on small screens
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ── Header ───────────────────────────────────────────────────
              const Icon(Icons.home_outlined,
                  size: 56, color: Color(0xFF6C63FF)),
              const SizedBox(height: 16),
              Text('Smart Home',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('Connect to your MQTT broker',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey)),
              const SizedBox(height: 40),

              // ── Broker info banner ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF6C63FF), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using test.mosquitto.org (free public broker)',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF6C63FF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Fields ───────────────────────────────────────────────────
              _buildTextField(
                  _brokerController, 'Broker URL', Icons.dns_outlined),
              const SizedBox(height: 16),
              _buildTextField(_portController, 'Port', Icons.numbers,
                  isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_clientIdController, 'Client ID',
                  Icons.perm_identity_outlined),
              const SizedBox(height: 32),

              // ── Error message ─────────────────────────────────────────────
              if (connState == ConnectionState2.failed)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Connection failed. Check your internet and try again.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Connect button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isConnecting ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isConnecting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('Connecting...',
                                style: TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Text(
                          'Connect',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
