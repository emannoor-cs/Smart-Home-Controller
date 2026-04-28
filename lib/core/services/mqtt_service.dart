import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttService {
  MqttBrowserClient? _client;

  final _messageController = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get messageStream => _messageController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<bool> connect({
    required String brokerUrl,
    required int port,
    required String clientId,
  }) async {
    _client = MqttBrowserClient('wss://test.mosquitto.org/mqtt', clientId);
    _client!.port = 8081;
    _client!.logging(on: true);
    _client!.keepAlivePeriod = 30;
    _client!.connectTimeoutPeriod = 5000;
    _client!.onConnected = () => print('Connected!');
    _client!.onDisconnected = () => print('Disconnected!');
    _client!.onAutoReconnected = () => print('Auto-reconnected!');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      print('🔌 Attempting connection to test.mosquitto.org:8081...');
      await _client!.connect();
    } catch (e) {
      print('ERROR: $e');
      _client!.disconnect();
      return false;
    }

    if (isConnected) {
      _listenToMessages();
      return true;
    }

    print(' Status: ${_client!.connectionStatus}');
    return false;
  }

  void _listenToMessages() {
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        final topic = message.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
            (message.payload as MqttPublishMessage).payload.message);
        print('[$topic] → $payload');
        _messageController.add({topic: payload});
      }
    });
  }

  void subscribe(String topic) {
    if (isConnected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
      print('Subscribed: $topic');
    }
  }

  void publish(String topic, String payload) {
    if (!isConnected) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 Published: [$topic] → $payload');
  }

  void disconnect() => _client?.disconnect();

  void dispose() {
    _messageController.close();
    _client?.disconnect();
  }
}
