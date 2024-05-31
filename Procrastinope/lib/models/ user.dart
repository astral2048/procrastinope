class User {
  final String id;
  final String email;
  final int exp;
  final int level;

  User({
    required this.id,
    required this.email,
    required this.exp,
    required this.level,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      exp: map['exp'],
      level: map['level'],
    );
  }
}