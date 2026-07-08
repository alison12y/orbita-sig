import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/registro.dart';
import '../services/secure_storage_service.dart';

/// Cliente HTTP para enviar registros al backend
/// Maneja tanto envíos individuales como batch
class RegistroApi {
  static final RegistroApi _instance = RegistroApi._internal();
  late final String _baseUrl;
  late final SecureStorageService _storage;

  factory RegistroApi() => _instance;
  RegistroApi._internal() {
    _baseUrl = dotenv.env['API_URL'] ?? 'https://backend-sig-l0wo.onrender.com';
    _storage = SecureStorageService.instance;
  }

  /// Obtiene el token JWT del almacenamiento seguro
  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: SecureStorageService.tokenKey);
    } catch (e) {
      print('❌ Error al obtener token: $e');
      return null;
    }
  }

  /// Headers comunes para todas las peticiones
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Envía un registro individual al backend
  /// POST /hijos/:hijoId/registros
  Future<bool> enviarRegistroIndividual(Registro registro) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/hijos/${registro.hijoId}/registros');

      print('📤 Enviando registro individual a: $url');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(registro.toJson()),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout enviando registro individual');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Registro enviado exitosamente: ${response.statusCode}');
        return true;
      } else {
        print('⚠️ Error al enviar registro: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error enviando registro individual: $e');
      return false;
    }
  }

  /// Envía múltiples registros en batch al backend
  /// POST /hijos/:hijoId/registros/sync
  Future<bool> enviarBatch(List<Registro> registros, String hijoId) async {
    if (registros.isEmpty) {
      print('⚠️ No hay registros para enviar');
      return true;
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/hijos/$hijoId/registros/sync');

      print('📤 Enviando batch de ${registros.length} registros a: $url');

      // Preparar payload con array de registros
      final payload = {
        'registros': registros.map((r) => r.toJsonForSync()).toList(),
      };

      // DEBUG: Mostrar el payload exacto que se envía
      print('📦 Payload a enviar:');
      for (var r in registros) {
        print('  - hora: ${r.hora}, fueOffline: ${r.fueOffline}');
      }
      print('📦 JSON final: ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Timeout enviando batch');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Batch enviado exitosamente: ${response.statusCode}');
        print('Response: ${response.body}');
        return true;
      } else {
        print('⚠️ Error al enviar batch: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error enviando batch: $e');
      return false;
    }
  }

  /// Obtiene el historial de registros de un hijo
  /// GET /hijos/:hijoId/registros
  Future<List<Registro>?> obtenerRegistros(
    String hijoId, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = Uri.parse('$_baseUrl/hijos/$hijoId/registros');

      // Agregar parámetros de filtro si se proporcionan
      if (desde != null && hasta != null) {
        url = url.replace(queryParameters: {
          'desde': desde.toIso8601String(),
          'hasta': hasta.toIso8601String(),
        });
      }

      print('📥 Obteniendo registros desde: $url');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout obteniendo registros');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final registros = jsonData
            .map((json) => Registro.fromJson(json as Map<String, dynamic>))
            .toList();
        print('✅ ${registros.length} registros obtenidos');
        return registros;
      } else {
        print('⚠️ Error al obtener registros: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo registros: $e');
      return null;
    }
  }

  /// Obtiene un registro específico
  /// GET /hijos/:hijoId/registros/:id
  Future<Registro?> obtenerRegistro(String hijoId, String registroId) async {
    try {
      final headers = await _getHeaders();
      final url =
          Uri.parse('$_baseUrl/hijos/$hijoId/registros/$registroId');

      print('📥 Obteniendo registro: $url');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout obteniendo registro');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final registro = Registro.fromJson(jsonData);
        print('✅ Registro obtenido');
        return registro;
      } else {
        print('⚠️ Error al obtener registro: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo registro: $e');
      return null;
    }
  }

  /// Actualiza un registro
  /// PUT /hijos/:hijoId/registros/:id
  Future<bool> actualizarRegistro(
    String hijoId,
    String registroId,
    Registro registro,
  ) async {
    try {
      final headers = await _getHeaders();
      final url =
          Uri.parse('$_baseUrl/hijos/$hijoId/registros/$registroId');

      print('📝 Actualizando registro: $url');

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(registro.toJson()),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout actualizando registro');
        },
      );

      if (response.statusCode == 200) {
        print('✅ Registro actualizado');
        return true;
      } else {
        print('⚠️ Error al actualizar registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error actualizando registro: $e');
      return false;
    }
  }

  /// Elimina un registro
  /// DELETE /hijos/:hijoId/registros/:id
  Future<bool> eliminarRegistro(String hijoId, String registroId) async {
    try {
      final headers = await _getHeaders();
      final url =
          Uri.parse('$_baseUrl/hijos/$hijoId/registros/$registroId');

      print('🗑️ Eliminando registro: $url');

      final response = await http.delete(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout eliminando registro');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Registro eliminado');
        return true;
      } else {
        print('⚠️ Error al eliminar registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error eliminando registro: $e');
      return false;
    }
  }

  /// Obtiene estadísticas de registros
  Future<Map<String, dynamic>?> obtenerEstadisticas(String hijoId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/hijos/$hijoId/registros/stats');

      print('📊 Obteniendo estadísticas: $url');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout obteniendo estadísticas');
        },
      );

      if (response.statusCode == 200) {
        final stats = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Estadísticas obtenidas');
        return stats;
      } else {
        print('⚠️ Error al obtener estadísticas: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return null;
    }
  }
}

/// Excepción custom para timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
