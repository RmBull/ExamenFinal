class Supplier {
  final int id;
  final String name;
  final String lastName;
  final String mail;
  final String state;

  const Supplier({
    required this.id,
    required this.name,
    required this.lastName,
    required this.mail,
    required this.state,
  });

  bool get isActive => state.toLowerCase() == 'activo';

  Supplier copyWith({
    int? id,
    String? name,
    String? lastName,
    String? mail,
    String? state,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      mail: mail ?? this.mail,
      state: state ?? this.state,
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    final id = json['provider_id'] ?? json['providerid'] ?? json['id'];
    return Supplier(
      id: id is int ? id : int.tryParse('$id') ?? 0,
      name: (json['provider_name'] ?? '').toString(),
      lastName: (json['provider_last_name'] ?? '').toString(),
      mail: (json['provider_mail'] ?? '').toString(),
      state: (json['provider_state'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toEditPayload() {
    return {
      'provider_id': id,
      'provider_name': name,
      'provider_last_name': lastName,
      'provider_mail': mail,
      'provider_state': state,
    };
  }
}
