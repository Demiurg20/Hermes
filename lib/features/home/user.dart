class User {
  final String name;
  final int balance; // Изменили на int по просьбе бэкендера

  User({
    required this.name,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // 1. Извлекаем вложенный объект 'user', где лежит баланс
    final userData = json['user'] as Map<String, dynamic>?;

    return User(
      // 2. Имя берем из корня (firstName), как в твоем ответе из Postman
      name: json['firstName'] ??
          userData?['username'] ??
          userData?['email'] ??
          'User',

      // 3. Баланс берем строго из userData['balance']
      // Используем ( ... as num?).toInt() для максимальной надежности
      balance: (userData?['balance'] as num? ?? 0).toInt(),
    );
  }
}