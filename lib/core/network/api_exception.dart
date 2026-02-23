class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return "ApiException($statusCode): $message";
    }
    return "ApiException: $message";
  }

  // Helper factory to parse standard error responses
  factory ApiException.fromJson(Map<String, dynamic> json, int statusCode) {
    String errorMsg = json['message'] ?? 'An unknown error occurred';
    return ApiException(errorMsg, statusCode: statusCode);
  }
}
