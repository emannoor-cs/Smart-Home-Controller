// This model represents a single smart device (light, fan, ac)
// It holds the device's name, topic, and current state (ON/OFF)

class DeviceModel {
  final String id;
  final String name;       // Display name: "Living Room Light"
  final String topic;      // MQTT topic: "home/light"
  final String icon;       // Emoji icon for UI
  bool isOn;               // Current state

  DeviceModel({
    required this.id,
    required this.name,
    required this.topic,
    required this.icon,
    this.isOn = false,     // Starts as OFF by default
  });

  // Creates a copy with updated state — important for Riverpod immutability
  DeviceModel copyWith({bool? isOn}) {
    return DeviceModel(
      id: id,
      name: name,
      topic: topic,
      icon: icon,
      isOn: isOn ?? this.isOn,
    );
  }
}