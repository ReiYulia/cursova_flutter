import 'package:flutter/material.dart';
import './signup_screen.dart';
import './notes_list.dart';
import '../account.dart';
import '../database_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseService dbService = DatabaseService.instance;

  String? _validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your login';
    }
    if (value.length < 4) {
      return 'Login must be at least 4 characters long';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 7) {
      return 'Password must be at least 7 characters long';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final login = _loginController.text.trim();
      final password = _passwordController.text.trim();

      // Перевірка логіна і пароля
      final isValid = await dbService.validatePassword(login, password);

      if (isValid) {
        // Отримання акаунту
        final accounts = await dbService.fetchAccounts();
        final user = accounts.firstWhere(
              (account) => account['login'] == login,
        );

        final account = Account(
          id: user['id'] as int,
          login: user['login'] as String,
          name: user['name'] as String,
          passwordHash: user['password_hash'] as String,
        );

        // Перехід до екрану з нотатками
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NotesListPage(
              title: 'Notes',
              account: account,
            ),
          ),
        );
      } else {
        // Невдалий вхід
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return const AlertDialog(
              title: Text('Error'),
              content: Text('Invalid login or password.'),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topCenter, // Початок градієнту (згори)
        end: Alignment.bottomCenter, // Кінець градієнту (внизу)
        colors: [Colors.white, Color(0xFFB3E5FC)], // Градиєнт від білого до голубого
    ),
    ),
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  "Welcome to your Note App",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                "Login:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.pink[50], // Ніжно-рожевий фон поля
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0), // Закруглення
                    borderSide: BorderSide.none, // Прибрати рамку
                  ),
                  hintText: "Your login",
                  hintStyle: TextStyle(
                    color: Colors.grey, // Світло-сірий колір для hintText
                    fontSize: 14, // Розмір шрифту
                  ),
                ),
                validator: _validateLogin,
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Password:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.pink[50], // Ніжно-рожевий фон поля
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0), // Закруглення
                    borderSide: BorderSide.none, // Прибрати рамку
                  ),
                  hintText: "Your password",
                  hintStyle: TextStyle(
                    color: Colors.grey, // Світло-сірий колір для hintText
                    fontSize: 14, // Розмір шрифту
                  ),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // Закруглення кутів
                    ),
                  ),
                  child: const Text("Sign in"),
                ),
              ),

              const SizedBox(height: 16.0),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "No account ? Sign up",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
