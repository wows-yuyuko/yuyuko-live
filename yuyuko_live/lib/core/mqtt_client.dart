import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';
import 'package:yuyuko_live/core/util/gzip.dart';

const String _serverUrl = 'mq.wows.shinoaki.com';
const int _tcpPort = 1883;
// const int _wsPort = 8083;
const String _account = 'wows-poll';
const String _password = 'wows-poll';

typedef MessageCallback = void Function(String);

/// Push tempArenaInfo.json to the server with clientId as the topic.
/// Subscribe to the topic to receive the encoded json string.
class WWSClient {
  final _logger = Logger('WWSClient');
  MqttClient? _client;

  WWSClient({
    required this.clientID,
    required this.userID,
  });

  final String clientID;
  final String userID;

  bool _hasSubscribed = false;

  Future<bool> initialise() async {
    final client = MqttServerClient.withPort(_serverUrl, clientID, _tcpPort);
    client.keepAlivePeriod = 60;
    // client.logging(on: true);
    final message = MqttConnectMessage()
        .authenticateAs(_account, _password)
        .withClientIdentifier(clientID)
        .startClean();
    client.connectionMessage = message;
    try {
      await client.connect();
    } on Exception catch (e) {
      _logger.severe('EXCEPTION: $e');
      client.disconnect();
      return false;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      _client = client;
      return true;
    } else {
      client.disconnect();
      return false;
    }
  }

  Future<bool> disconnect() async {
    if (_client == null) return false;
    try {
      _client?.disconnect();
    } on Exception catch (e) {
      _logger.severe('EXCEPTION: $e');
      return false;
    }
    return true;
  }

  Future<bool> _checkConnection() async {
    if (_client == null) {
      return await initialise();
    } else {
      return _client?.connectionStatus?.state == MqttConnectionState.connected;
    }
  }

  Future<bool> _subscribe(String topic, MessageCallback callback) async {
    if (_hasSubscribed) {
      assert(false, 'Already subscribed, only one subscription is allowed');
      return false;
    }

    if (!await _checkConnection()) {
      return false;
    }

    if (_client == null) {
      assert(false, 'The client should be valid here');
      return false;
    }

    _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> message) {
      final MqttPublishMessage received =
          message.first.payload as MqttPublishMessage;
      final payload = received.payload.message;

      final decoded = GZipHelper.decodeBytes(payload);
      if (decoded == null) {
        assert(false, 'The decoded stringis invalid');
        return;
      }

      callback(decoded);
    });

    _client?.subscribe(topic, MqttQos.exactlyOnce);
    _hasSubscribed = true;
    return true;
  }

  Future<void> _publish(String topic, String value) async {
    if (!await _checkConnection()) return;
    final encoded = GZipHelper.encodeBytes(value);
    if (encoded == null) {
      assert(false, 'The encoded string is invalid');
      return;
    }

    // convert to buffer, don't use String here
    final payload = Uint8Buffer();
    payload.addAll(encoded);
    _client?.publishMessage(topic, MqttQos.atLeastOnce, payload);
  }
}
