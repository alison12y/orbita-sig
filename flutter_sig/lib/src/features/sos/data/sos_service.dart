import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SOSService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? 'https://backend-sig-l0wo.onrender.com';
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const _storage = FlutterSecureStorage();

  /// Enviar alerta SOS desde el hijo
  static Future<bool> enviarAlertaSOS(int hijoId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        print('❌ No hay token de autenticación');
        return false;
      }

      final uri = Uri.parse('$_baseUrl/hijos/$hijoId/sos');
      print('🚀 Enviando SOS a: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🚨 SOS enviado: ${data['mensaje']}');
        return true;
      } else {
        print('❌ Error al enviar SOS: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error en enviarAlertaSOS: $e');
      return false;
    }
  }

  /// Reproducir sonido de alerta SOS
  static Future<void> reproducirSonidoSOS() async {
    try {
      // Intentar reproducir sonido personalizado si existe, sino solo vibrar
      // await _audioPlayer.play(AssetSource('sounds/sos_alert.mp3'));
      // Por defecto confiamos en la vibración si no hay assets configurados
    } catch (e) {
      print('❌ Error al reproducir sonido: $e');
    }
  }

  /// Vibración de patrón SOS (... --- ...)
  static Future<void> vibrarPatronSOS() async {
    if (await Vibration.hasVibrator() ?? false) {
      // Patrón SOS: corto-corto-corto, largo-largo-largo, corto-corto-corto
      await Vibration.vibrate(
        pattern: [
          0, 200, 100, 200, 100, 200, // ... (SOS start)
          300, 500, 100, 500, 100, 500, // --- (SOS middle)
          300, 200, 100, 200, 100, 200, // ... (SOS end)
        ],
        intensities: [0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255],
      );
    }
  }
}
