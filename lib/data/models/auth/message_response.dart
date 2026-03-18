class MessageResponse {
  final bool status;
  final String message;

  const MessageResponse({
    required this.status,
    required this.message,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      status: json['status'] == true || json['status'] == 1,
      message: json['message']?.toString() ?? '',
    );
  }
}
