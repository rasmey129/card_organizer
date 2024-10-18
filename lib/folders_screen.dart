import 'package:flutter/material.dart';
import 'cards_screen.dart';
import 'database_helper.dart';

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    dbHelper.init().then((_) {
      _loadFolders();
    });
  }

  Future<void> _loadFolders() async {
    final data = await dbHelper.getFolders();
    setState(() {
      folders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Folders')),
      body: folders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return ListTile(
                  title: Text(folder['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardsScreen(folderId: folder['id']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
