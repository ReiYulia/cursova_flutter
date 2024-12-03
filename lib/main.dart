import 'package:flutter/material.dart';
import 'widgets/notes_list.dart';
import './account.dart';
import 'widgets/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink.shade100),
        useMaterial3: true,
      ),
      //home: NotesListPage(title: 'Notes', account: account,),
      home: SignInScreen(),
    );
  }
}
