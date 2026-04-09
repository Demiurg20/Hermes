class User {
  final String name;
  final double balance;

  User({
    required this.name,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['user'] ?? json;

    return User(
      name: data['first_name'] ??
          data['name'] ??
          data['username'] ??
          'User',

      balance: data['balance'] ??
          data['money'] ??
          0,
    );
  }
}