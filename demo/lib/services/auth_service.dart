import 'package:demo/helper/interceptor.dart';
import 'package:demo/models/admin/auth_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final Dio _dio = Dio()..interceptors.add(AuthInterceptor());
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Obtiener el token de autenticacion
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

        
        await _storage.write(key: _tokenKey, value: authModel.accessToken);
        await _storage.write(
          key: _refreshTokenKey,
          value: authModel.refreshToken,
        );

        return null; 
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

  /// Obtener el token guardado
  static Future<String?> getSavedToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Verificar si el usuario esta autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getSavedToken();
    return token != null && token.isNotEmpty;
  }

  /// Cerrar sesión
  static Future<String?> logout() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      
      if (refreshToken != null) {
        await _dio.post(
          '$_baseUrl/auth/logout',
          data: {'refreshToken': refreshToken},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );
      }
      
      // Eliminar tokens localmente
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      
      return null; 
    } catch (e) {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      return null;
    }
  }

  /// Obtener el perfil del usuario autenticado
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
