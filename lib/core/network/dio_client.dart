import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import 'api_exception.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.responseType = ResponseType.json
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Retrieve token and inject into headers
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            String errorMessage = 'No Internet Connection. Please try again.';
            if (e.response != null) {
              final data = e.response!.data;
              if (data is Map<String, dynamic>) {
                errorMessage = data['message'] ?? errorMessage;
              } else {
                errorMessage = 'Server Error: ${e.response!.statusCode}';
              }
            } else if (e.type == DioExceptionType.connectionTimeout) {
              errorMessage =
                  'Connection Timeout. Server took too long to respond.';
            }

            final customError = DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: ApiException(errorMessage,
                  statusCode: e.response?.statusCode),
            );

            return handler.next(customError);
          },
        ),
      );
  }

  // Get Method
  Future<Response> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(e.message ?? 'Unknown error');
    }
  }

  // Post Method
  Future<Response> post(String url, {dynamic data}) async {
    try {
      final response = await _dio.post(url, data: data);
      return response;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(e.message ?? 'Unknown error');
    }
  }

  // Put Method
  Future<Response> put(String url, {dynamic data}) async {
    try {
      final response = await _dio.put(url, data: data);
      return response;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(e.message ?? 'Unknown error');
    }
  }

  // Delete Method
  Future<Response> delete(String url,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(e.message ?? 'Unknown error');
    }
  }
}
