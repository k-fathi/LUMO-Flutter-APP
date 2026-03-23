import 'package:flutter/material.dart';

class EmotionData {
  final String id;
  final String emoji;
  final String label;
  final double percentage; // 0.0 to 1.0
  final Color color;

  EmotionData(this.id, this.emoji, this.label, this.percentage, this.color);

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    return EmotionData(
      json['id'] as String,
      json['emoji'] as String,
      json['label'] as String,
      (json['percentage'] as num).toDouble(),
      Color(int.parse(json['color'].toString().replaceFirst('#', '0xFF'))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emoji': emoji,
      'label': label,
      'percentage': percentage,
      'color': '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    };
  }
}

class SessionAnalysisModel {
  final String id;
  final String title;
  final String summary;
  final String duration;
  final String engagementLevel;
  final List<String> recommendations;
  final List<EmotionData> emotionDistribution;
  final double focusedPercentage;
  final double notFocusedPercentage;

  SessionAnalysisModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.duration,
    required this.engagementLevel,
    required this.recommendations,
    required this.emotionDistribution,
    required this.focusedPercentage,
    required this.notFocusedPercentage,
  });

  factory SessionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SessionAnalysisModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      duration: json['duration'] as String,
      engagementLevel: json['engagement_level'] as String,
      recommendations: List<String>.from(json['recommendations'] as List),
      emotionDistribution: (json['emotion_distribution'] as List)
          .map((e) => EmotionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      focusedPercentage: (json['focused_percentage'] as num).toDouble(),
      notFocusedPercentage: (json['not_focused_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'duration': duration,
      'engagement_level': engagementLevel,
      'recommendations': recommendations,
      'emotion_distribution': emotionDistribution.map((e) => e.toJson()).toList(),
      'focused_percentage': focusedPercentage,
      'not_focused_percentage': notFocusedPercentage,
    };
  }
}
