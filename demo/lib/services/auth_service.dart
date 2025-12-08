import 'package:demo/helper/interceptor.dart';
import 'package:demo/models/admin/auth_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final Dio _dio = Dio()..interceptors.add(AuthInterceptor());
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = 'https://api.escuelajs.co/api/v1';
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Obtiene el token de autenticación
  /// Retorna null si el login es exitoso, o un mensaje de error si falla
  static Future<String?> getToken(String email, String password) async {
    try {
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final authModel = AuthModel.fromJson(response.data);

        // Guardar tokens en FlutterSecureStorage
        await _storage.write(key: _tokenKey, value: authModel.accessToken);
        await _storage.write(
          key: _refreshTokenKey,
          value: authModel.refreshToken,
        );

        return null; // Éxito
      } else {
        return 'Error del servidor: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return 'Usuario o contraseña incorrectos';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return 'Tiempo de conexión agotado';
      } else if (e.type == DioExceptionType.connectionError) {
        return 'Error de conexión. Verifica tu internet';
      } else {
        return 'Error de red: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  /// Obtiene el token guardado
  static Future<String?> getSavedToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Verifica si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getSavedToken();
    return token != null && token.isNotEmpty;
  }

  /// Cierra sesión eliminando los tokens
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Obtiene el perfil del usuario autenticado
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await getSavedToken();
      if (token == null) return null;

      final response = await _dio.get(
        '$_baseUrl/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
