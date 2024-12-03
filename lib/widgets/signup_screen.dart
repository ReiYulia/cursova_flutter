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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Google-flutter-logo.svg/1024px-Google-flutter-logo.svg.png",
                  width: 300,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                "Login:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signIn,
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
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
