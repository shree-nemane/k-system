import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/logger_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  final _streamController = StreamController<dynamic>.broadcast();
  Timer? _reconnectTimer;
  bool _isConnected = false;
  String _currentTopic = 'global';

  Stream<dynamic> get stream => _streamController.stream;
  bool get isConnected => _isConnected;

  void connect({String topic = 'global'}) {
    _currentTopic = topic;
    _reconnectTimer?.cancel();
    
    if (_isConnected && _channel != null) return;
    
    final rawBaseUrl = dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:8000');
    // Ensure no trailing slash on base before appending path
    final baseUrl = rawBaseUrl.endsWith('/') 
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1) 
        : rawBaseUrl;
        
    final wsUrl = '${baseUrl.replaceFirst('http', 'ws')}/ws/crowd?topic=$topic';

    Log.info('Connecting to WebSocket: $wsUrl');

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        connectTimeout: const Duration(seconds: 10),
      );
      
      _channel!.stream.listen(
        (message) {
          if (!_isConnected) {
            Log.info('WebSocket connection established');
            _isConnected = true;
          }
          try {
            _streamController.add(jsonDecode(message));
          } catch (e) {
            Log.error('Malformed WebSocket message', e);
          }
        },
        onDone: () {
          Log.warning('WebSocket connection closed by server');
          _isConnected = false;
          _reconnect();
        },
        onError: (error) {
          Log.error('WebSocket connection error', error);
          _isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      Log.error('Synchronous WebSocket connection error', e);
      _isConnected = false;
      _reconnect();
    }
  }

  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      Log.info('Attempting reconnect for topic: $_currentTopic');
      connect(topic: _currentTopic);
    });
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _streamController.close();
  }
}
