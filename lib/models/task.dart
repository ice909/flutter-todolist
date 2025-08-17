class Task {
  String id;
  String title;
  String content;
  String parentId;
  bool completed;
  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  int priority;
  String? tags;
  int sortOrder;
  bool expanded;

  Task({
    required this.id,
    required this.title,
    required this.content,
    required this.parentId,
    this.completed = false,
    DateTime? createdAt,
    this.updatedAt,
    this.deletedAt,
    this.priority = 0,
    this.tags,
    this.sortOrder = -2000000000000,
    this.expanded = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // 转换为Map，用于数据库存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'completed': completed ? 1 : 0,
      'parentId': parentId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
      'priority': priority,
      'tags': tags,
      'sortOrder': sortOrder,
      'expanded': expanded ? 1 : 0,
    };
  }

  // 从Map创建TodoItem对象
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      parentId: map['parentId'] ?? '',
      completed: map['completed'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      deletedAt: map['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'])
          : null,
      priority: map['priority'] ?? 0,
      tags: map['tags'],
      sortOrder: map['sortOrder'] ?? 0,
      expanded: map['expanded'] == 1,
    );
  }

  // 转换为JSON字符串，用于SharedPreferences存储
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'completed': completed,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'priority': priority,
      'tags': tags,
      'sortOrder': sortOrder,
      'expanded': expanded,
    };
  }

  // 从JSON创建TodoItem对象
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      parentId: json['parentId'] ?? '',
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      priority: json['priority'] ?? 0,
      tags: json['tags'],
      sortOrder: json['sortOrder'] ?? 0,
      expanded: json['expanded'] ?? false,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? content,
    String? parentId,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? priority,
    String? tags,
    int? sortOrder,
    bool? expanded,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      expanded: expanded ?? this.expanded,
    );
  }
}
