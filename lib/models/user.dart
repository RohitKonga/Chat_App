class UserModel {
  final String email;
  final String id;
  final String name;

  const UserModel({required this.email, required this.name, required this.id});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(email: 'email', name: 'name', id: 'id');

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'id': id,
      };
}
