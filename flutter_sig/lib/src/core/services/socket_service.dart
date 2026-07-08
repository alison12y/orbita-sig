import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;
  final _locationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _panicController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _statusController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get locationStream => _locationController.stream;
  Stream<Map<String, dynamic>> get panicStream => _panicController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    final baseUrl = dotenv.env['SOCKET_URL'] ?? dotenv.env['API_URL'] ?? 'https://backend-sig-l0wo.onrender.com';
    print('🔌 Connecting to Socket.IO at $baseUrl');

    // Siempre desconectar el socket anterior antes de crear uno nuevo
    // Esto asegura que usemos el token correcto del usuario actual
    if (_socket != null) {
      print('🔄 Disconnecting previous socket to reconnect with new token');
      _socket!.disconnect();
      _socket!.dispose();
      _socket!.destroy();
      _socket = null;
    }

    // Usar forceNew para forzar una nueva conexión completamente
    // y enviar el token tanto en headers como en auth
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setAuth({'token': token}) // También enviar en auth
          .enableForceNew() // Forzar nueva conexión
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected successfully: ${_socket?.id}');
    });

    _socket!.onConnectError((data) {
      print('❌ Socket connection error: $data');
    });

    _socket!.onError((data) {
      print('❌ Socket error: $data');
    });

    _socket!.onDisconnect((_) {
      print('⚠️ Socket disconnected');
    });

    _socket!.on('locationUpdated', (data) {
      print('📍 Location update received via socket: $data');
      _locationController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('joined', (data) {
      print('🚪 Joined room: $data');
    });

    _socket!.on('left', (data) {
      print('🚪 Left room: $data');
    });

    _socket!.on('childStatusChanged', (data) {
      print('👶 Child status changed: $data');
      _statusController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('locationRequested', (data) {
      print('📍 Location requested by parent: $data');
    });

    _socket!.on('panicAlert', (data) {
      print('🚨 Panic alert received: $data');
      _panicController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('error', (data) {
      print('❌ Server error: $data');
    });
  }

  void joinChildRoom(String childId) {
    if (_socket != null && _socket!.connected) {
      print('📤 Emitting joinChildRoom for $childId');
      _socket!.emit('joinChildRoom', {'childId': childId});
    } else {
      print('❌ Cannot join room: Socket not connected');
    }
  }

  void leaveChildRoom(String childId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leaveChildRoom', {'childId': childId});
    }
  }

  // Method for child to emit location (childId se obtiene del JWT en el backend)
  void emitLocationUpdate(
    double lat,
    double lng,
    double battery,
    String status, {
    String device = 'Unknown',
  }) {
    if (_socket != null && _socket!.connected) {
      print('📤 Emitting updateLocation: $lat, $lng (device: $device)');
      _socket!.emit('updateLocation', {
        'lat': lat,
        'lng': lng,
        'battery': battery,
        'status': status,
        'device': device,
      });
    } else {
      print('❌ Cannot emit location: Socket not connected');
    }
  }

  // Method for child to notify they are online
  void emitChildOnline() {
    if (_socket != null && _socket!.connected) {
      print('📤 Emitting childOnline');
      _socket!.emit('childOnline', {});
    }
  }

  // Method for child to notify they are going offline
  void emitChildOffline() {
    if (_socket != null && _socket!.connected) {
      print('📤 Emitting childOffline');
      _socket!.emit('childOffline', {});
    }
  }

  // Method for child to send panic alert (childId se obtiene del JWT en el backend)
  void emitPanicAlert(double lat, double lng) {
    if (_socket != null && _socket!.connected) {
      print('🚨 Emitting panicAlert');
      _socket!.emit('panicAlert', {
        'lat': lat,
        'lng': lng,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      print('❌ Cannot emit panic alert: Socket not connected');
    }
  }

  // Method for parent to request child location
  void requestChildLocation(String childId) {
    if (_socket != null && _socket!.connected) {
      print('📤 Requesting location for child $childId');
      _socket!.emit('requestLocation', {'childId': childId});
    }
  }

  void disconnect() {
    print('🔌 Disconnecting socket...');
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  void dispose() {
    _locationController.close();
    _panicController.close();
    _statusController.close();
    disconnect();
  }
}
