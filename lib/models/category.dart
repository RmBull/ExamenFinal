class Category {
  final int id;
  final String name;
  final String state;

  const Category({
    required this.id,
    required this.name,
    required this.state,
  });

  bool get isActive => state.toLowerCase() == 'activa';

  Category copyWith({
    int? id,
    String? name,
    String? state,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final id = json['category_id'] ?? json['id'];
    return Category(
      id: id is int ? id : int.tryParse('$id') ?? 0,
      name: (json['category_name'] ?? '').toString(),
      state: (json['category_state'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toEditPayload() {
    return {
      'category_id': id,
      'category_name': name,
      'category_state': state,
    };
  }
}
