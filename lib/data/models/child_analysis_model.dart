import '../../core/enums/child_state.dart';

class ChildAnalysisModel {
  final String id;
  final String parentId;
  final String parentName;
  final String childName;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String? notes;
  final ChildState currentState;
  final List<AnalysisStateModel> states;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChildAnalysisModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.childName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    this.notes,
    required this.currentState,
    required this.states,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory ChildAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ChildAnalysisModel(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      parentName: json['parent_name'] as String,
      childName: json['child_name'] as String,
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      currentState: ChildState.fromString(json['current_state'] as String),
      states: (json['states'] as List<dynamic>)
          .map((e) => AnalysisStateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'parent_name': parentName,
      'child_name': childName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'date': date.toIso8601String(),
      'notes': notes,
      'current_state': currentState.name,
      'states': states.map((s) => s.toJson()).toList(),
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method
  ChildAnalysisModel copyWith({
    String? id,
    String? parentId,
    String? parentName,
    String? childName,
    String? doctorId,
    String? doctorName,
    DateTime? date,
    String? notes,
    ChildState? currentState,
    List<AnalysisStateModel>? states,
    String? attachmentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildAnalysisModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      childName: childName ?? this.childName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      currentState: currentState ?? this.currentState,
      states: states ?? this.states,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  int get currentStateIndex => states.indexWhere((s) => s.state == currentState);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildAnalysisModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChildAnalysisModel(id: $id, child: $childName, state: ${currentState.name})';
  }
}

class AnalysisStateModel {
  final ChildState state;
  final String label;
  final String? description;
  final bool isCurrent;

  const AnalysisStateModel({
    required this.state,
    required this.label,
    this.description,
    this.isCurrent = false,
  });

  // Factory constructor from JSON
  factory AnalysisStateModel.fromJson(Map<String, dynamic> json) {
    return AnalysisStateModel(
      state: ChildState.fromString(json['state'] as String),
      label: json['label'] as String,
      description: json['description'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'state': state.name,
      'label': label,
      'description': description,
      'is_current': isCurrent,
    };
  }

  // CopyWith method
  AnalysisStateModel copyWith({
    ChildState? state,
    String? label,
    String? description,
    bool? isCurrent,
  }) {
    return AnalysisStateModel(
      state: state ?? this.state,
      label: label ?? this.label,
      description: description ?? this.description,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  String toString() {
    return 'AnalysisStateModel(state: ${state.name}, isCurrent: $isCurrent)';
  }
}