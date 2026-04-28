// Main dashboard — shows all devices and logs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_model.dart';
import '../widgets/device_card.dart';
import '../widgets/log_panel.dart';
import 'connection_screen.dart';

// ─── PROVIDERS ───────────────────────────────────────────────────────────────

// Holds the list of all devices
// StateNotifierProvider allows us to modify the list and notify listeners
final devicesProvider =
    StateNotifierProvider<DevicesNotifier, List<DeviceModel>>((ref) {
  return DevicesNotifier();
});

class DevicesNotifier extends StateNotifier<List<DeviceModel>> {
  DevicesNotifier() : super(_defaultDevices());

  // Default 3 devices matching your project spec
  static List<DeviceModel> _defaultDevices() => [
        DeviceModel(
            id: 'light',
            name: 'Living Room Light',
            topic: 'home/light',
            icon: '💡'),
        DeviceModel(
            id: 'fan', name: 'Ceiling Fan', topic: 'home/fan', icon: '🌀'),
        DeviceModel(
            id: 'ac', name: 'Air Conditioner', topic: 'home/ac', icon: '❄️'),
      ];

  // Update a device's state by its topic
  void updateByTopic(String topic, String payload) {
    state = [
      for (final device in state)
        if (device.topic == topic)
          device.copyWith(isOn: payload.toUpperCase() == 'ON')
        else
          device
    ];
  }

  // Toggle device from within the app (publishes + updates UI)
  void toggle(String id) {
    state = [
      for (final device in state)
        if (device.id == id) device.copyWith(isOn: !device.isOn) else device
    ];
  }
}

// ─── LOG PROVIDER ─────────────────────────────────────────────────────────────

// Keeps a list of log strings for the log panel
final logProvider = StateNotifierProvider<LogNotifier, List<String>>((ref) {
  return LogNotifier();
});

class LogNotifier extends StateNotifier<List<String>> {
  LogNotifier() : super([]);

  void add(String message) {
    final timestamp = TimeOfDay.now().format(
        // We'll just use DateTime
        // ignore the above, using DateTime below
        _context);
    state = [
      '[${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}] $message',
      ...state
    ];
    if (state.length > 50) state = state.sublist(0, 50); // Keep last 50 logs
  }

  // ignore: unused_field
  static final _context = null; // Placeholder — see note below
}

// ─── DASHBOARD SCREEN ─────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _setupMqttListener();
  }

  void _setupMqttListener() {
    final mqttService = ref.read(mqttServiceProvider);

    // Subscribe to all device topics
    final devices = ref.read(devicesProvider);
    for (final device in devices) {
      mqttService.subscribe(device.topic);
    }

    // Listen to the message stream and update device states
    mqttService.messageStream.listen((Map<String, String> message) {
      final topic = message.keys.first;
      final payload = message.values.first;

      // Update device state in provider
      ref.read(devicesProvider.notifier).updateByTopic(topic, payload);

      // Add to logs
      ref.read(logProvider.notifier).add('[$topic] → $payload');
    });
  }

  void _onDeviceToggle(DeviceModel device) {
    final mqttService = ref.read(mqttServiceProvider);
    final newState = !device.isOn;

    // Toggle in state
    ref.read(devicesProvider.notifier).toggle(device.id);

    // Publish to broker so other clients also see the change
    final payload = newState ? 'ON' : 'OFF';
    mqttService.publish(device.topic, payload);
    ref
        .read(logProvider.notifier)
        .add('[${device.topic}] → $payload (sent from app)');
  }

  void _disconnect() {
    ref.read(mqttServiceProvider).disconnect();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ConnectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final onCount = devices.where((d) => d.isOn).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: _disconnect,
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar at top
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                const Text('Connected to HiveMQ'),
                const Spacer(),
                Text('$onCount/${devices.length} devices ON',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Device cards grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return DeviceCard(
                  device: devices[index],
                  onToggle: () => _onDeviceToggle(devices[index]),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Log panel at bottom
          const Expanded(child: LogPanel()),
        ],
      ),
    );
  }
}
