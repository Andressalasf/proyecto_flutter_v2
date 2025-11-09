import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiService {
  final Dio _dio;
  
  static const String baseUrl = 'http://localhost:8080';
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    validateStatus: (status) => status! < 500,
  )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Crear un producto
  Future<ApiResponse<Product>> createProduct(Product product) async {
    try {
      final response = await _dio.post(
        '/products',
        data: product.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdProduct = Product.fromJson(response.data);
        return ApiResponse.success(createdProduct);
      } else {
        return ApiResponse.error(
          'Error al crear el producto. Código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error inesperado: ${e.toString()}');
    }
  }

  // Obtener todos los productos
  Future<ApiResponse<List<Product>>> getProducts({int limit = 50}) async {
    try {
      final response = await _dio.get('/products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse.success(products);
      } else {
        return ApiResponse.error(
          'Error al obtener productos. Código: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error inesperado: ${e.toString()}');
    }
  }

  // Manejo de errores de Dio
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Error: Tiempo de conexión agotado. Verifica tu conexión a internet.';
      case DioExceptionType.sendTimeout:
        return 'Error: Tiempo de envío agotado. Intenta nuevamente.';
      case DioExceptionType.receiveTimeout:
        return 'Error: Tiempo de recepción agotado. El servidor no responde.';
      case DioExceptionType.badResponse:
        return 'Error del servidor: ${error.response?.statusCode}. ${error.response?.statusMessage ?? "Sin mensaje"}';
      case DioExceptionType.cancel:
        return 'Error: La petición fue cancelada.';
      case DioExceptionType.connectionError:
        return 'Error de conexión: No se pudo conectar al servidor. Verifica la URL y tu conexión a internet.';
      case DioExceptionType.badCertificate:
        return 'Error: Certificado SSL inválido.';
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'Error: No hay conexión a internet o la URL no existe.';
        }
        return 'Error desconocido: ${error.message ?? "Sin detalles"}';
    }
  }
}

// Clase para manejar respuestas de la API
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse._({this.data, this.error, required this.isSuccess});

  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse._(error: error, isSuccess: false);
  }
}
