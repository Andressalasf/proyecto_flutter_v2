import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiService {

  final String url = 'http://localhost:3000/api/v1';
  final Dio _dio = Dio();

  // Crear un producto
  Future<String> createProduct(Product product) async {
    try {
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await _dio.post('$url/products', data: product.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        return 'Producto creado exitosamente';
      } else {
        return 'Error del servidor: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData['message'] != null) {
          return responseData['message'];
        }
        return 'Datos inválidos. Verifica la información ingresada.';
      }

      // Otros errores
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Tiempo de conexión agotado. Verifica tu conexión a internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return 'El servidor tardó demasiado en responder.';
      } else if (e.type == DioExceptionType.connectionError) {
        return 'Error de conexión. Verifica tu internet y la URL del servidor.';
      } else if (e.response?.statusCode == 404) {
        return 'Servidor no encontrado. Verifica la URL.';
      } else if (e.response?.statusCode == 500) {
        return 'Error interno del servidor. Intenta más tarde.';
      } else {
        return e.message ?? 'Error inesperado';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // Obtener todos los productos
  Future<List<Product>> getProducts() async {
    try {
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await _dio.get('$url/products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        if (data.isEmpty) {
          throw Exception('No hay productos registrados');
        }

        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Tiempo de conexión agotado. Verifica tu internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('El servidor tardó demasiado en responder.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Error de conexión. Verifica tu internet y la URL.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Servidor no encontrado. Verifica la URL.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Error interno del servidor. Intenta más tarde.');
      } else {
        throw Exception('Error de red: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
