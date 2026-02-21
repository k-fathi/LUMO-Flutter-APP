import 'package:flutter/material.dart';

mixin ScrollBehaviorMixin {
  // Scroll controller
  final ScrollController scrollController = ScrollController();

  // Check if at top
  bool get isAtTop {
    if (!scrollController.hasClients) return true;
    return scrollController.offset <= 0;
  }

  // Check if at bottom
  bool get isAtBottom {
    if (!scrollController.hasClients) return false;
    return scrollController.offset >= scrollController.position.maxScrollExtent;
  }

  // Scroll to top
  void scrollToTop({Duration duration = const Duration(milliseconds: 300)}) {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  // Scroll to bottom
  void scrollToBottom({Duration duration = const Duration(milliseconds: 300)}) {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  // Scroll to position
  void scrollToPosition(
      double position, {
        Duration duration = const Duration(milliseconds: 300),
      }) {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      position,
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  // Jump to top (instant)
  void jumpToTop() {
    if (!scrollController.hasClients) return;
    scrollController.jumpTo(0);
  }

  // Jump to bottom (instant)
  void jumpToBottom() {
    if (!scrollController.hasClients) return;
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  // Add scroll listener
  void addScrollListener(VoidCallback listener) {
    scrollController.addListener(listener);
  }

  // Remove scroll listener
  void removeScrollListener(VoidCallback listener) {
    scrollController.removeListener(listener);
  }

  // Dispose scroll controller
  void disposeScrollController() {
    scrollController.dispose();
  }
}