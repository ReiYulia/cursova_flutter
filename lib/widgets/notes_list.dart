import 'package:flutter/material.dart';
import '../note.dart';
import '../account.dart';
import '../database_service.dart';
import 'sign_in_screen.dart';

class NotesListPage extends StatefulWidget {
  final String title;
  final Account account;

  const NotesListPage({super.key, required this.title, required this.account});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final DatabaseService dbService = DatabaseService.instance;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await dbService.fetchNotes(widget.account.id!);
    setState(() {
      notes = data;
    });
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFB3E5FC),
          title: const Text('Add New Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  final newNote = Note(
                    accountId: widget.account.id!,
                    title: title,
                    content: content,
                    createdAt: DateTime.now().toIso8601String(),
                    modifiedAt: DateTime.now().toIso8601String(),
                  );

                  await dbService.insertNote(newNote, widget.account.id!);

                  _loadNotes(); // Оновлення списку нотаток
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _handleAccountMenuSelection(String value) async {
    if (value == 'logout') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } else if (value == 'delete_account') {
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: const Text('Are you sure you want to delete your account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await dbService.deleteAccount(widget.account.id!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB3E5FC),
        title: Row(
          children: [
            PopupMenuButton<String>(
              onSelected: _handleAccountMenuSelection,
              icon: const Icon(Icons.account_circle, size: 28),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Log out'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete_account',
                  child: Row(
                    children: const [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete account'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              widget.account.login, // Логін акаунта
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes available'))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child:ListTile(
              title: Text(note.title),
              subtitle: Text('Created: ${note.createdAt.substring(0, 10)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showViewNoteScreen(note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditNoteDialog(note),
                  ),
                ],
              ),
              onLongPress: () => _confirmDelete(note),
            ),

          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditNoteDialog(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  final updatedNote = Note(
                    accountId: widget.account.id!,
                    id: note.id,
                    title: title,
                    content: content,
                    createdAt: note.createdAt,
                    modifiedAt: DateTime.now().toIso8601String(),
                  );
                  await dbService.updateNote(updatedNote);
                  _loadNotes();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Are you sure you want to delete "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await dbService.deleteNote(note.id!);
                _loadNotes();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted note: ${note.title}')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showViewNoteScreen(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('View Note')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Created: ${note.createdAt.substring(0, 10)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Divider(),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
