class Account {
  final int? id; // Унікальний ідентифікатор акаунту
  final String login; // Логін користувача
  final String name; // Ім'я користувача
  final String passwordHash; // Хешований пароль

  Account({
    this.id,
    required this.login,
    required this.name,
    required this.passwordHash,
  });

  /// Перетворення з Map у об'єкт Account
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      login: map['login'],
      name: map['name'],
      passwordHash: map['password_hash'],
    );
  }

  /// Перетворення з Account у Map (для бази даних)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'login': login,
      'name': name,
      'password_hash': passwordHash,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
