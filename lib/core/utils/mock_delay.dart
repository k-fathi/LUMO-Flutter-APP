class MockDelay {
  const MockDelay._();

  /// Short delay (500ms) for quick operations
  static Future<void> short() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Medium delay (1s) for normal operations
  static Future<void> medium() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Long delay (2s) for slow operations
  static Future<void> long() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Custom delay
  static Future<void> custom(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Random delay between min and max
  static Future<void> random({
    Duration min = const Duration(milliseconds: 500),
    Duration max = const Duration(seconds: 2),
  }) async {
    final minMs = min.inMilliseconds;
    final maxMs = max.inMilliseconds;
    final randomMs = minMs + (DateTime.now().millisecondsSinceEpoch % (maxMs - minMs));
    await Future.delayed(Duration(milliseconds: randomMs));
  }
}