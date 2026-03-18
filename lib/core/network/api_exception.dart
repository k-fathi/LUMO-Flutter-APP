class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  // Helper factory to parse standard error responses
  factory ApiException.fromJson(Map<String, dynamic> json, int statusCode) {
    String errorMsg = json['message'] ?? 'An unknown error occurred';

    // Handle Laravel-style validation errors (JSON: { message: "...", errors: { field: ["msg1", "msg2"] } })
    if (json.containsKey('errors') && json['errors'] is Map) {
      final Map<String, dynamic> errors = json['errors'];
      final List<String> errorList = [];

      errors.forEach((key, value) {
        if (value is List) {
          errorList.addAll(value.map((e) => e.toString()));
        } else if (value is String) {
          errorList.add(value);
        }
      });

      if (errorList.isNotEmpty) {
        errorMsg = errorList.join('\n');
      }
    }

    return ApiException(errorMsg, statusCode: statusCode);
  }
}
