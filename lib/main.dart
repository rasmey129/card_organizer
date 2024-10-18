import 'package:flutter/material.dart';
import 'databaseHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.init();  

  runApp(MyApp(databaseHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  MyApp({required this.databaseHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Folder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FolderListScreen(databaseHelper: databaseHelper),
    );
  }
}

class FolderListScreen extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  FolderListScreen({required this.databaseHelper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: databaseHelper.getFoldersWithCardCounts(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No folders available"));
          } else {
            final folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return ListTile(
                  title: Text(folder['folderName']),
                  subtitle: Text('Cards: ${folder['cardCount']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardsScreen(
                          folderId: folder['_id'],
                          folderName: folder['folderName'],
                          databaseHelper: databaseHelper,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CardsScreen extends StatelessWidget {
  final int folderId;
  final String folderName;
  final DatabaseHelper databaseHelper;

  CardsScreen({
    required this.folderId,
    required this.folderName,
    required this.databaseHelper,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cards in $folderName"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: databaseHelper.getCardsForFolder(folderId), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No cards available"));
          } else {
            // Display the cards list
            final cards = snapshot.data!;
            return ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return ListTile(
                  title: Text(card['name']),
                  subtitle: Text(card['suit']),
                  leading: card['imageUrl'] != null && card['imageUrl'].isNotEmpty
                      ? Image.network(card['imageUrl'])
                      : Icon(Icons.card_membership),
                );
              },
            );
          }
        },
      ),
    );
  }
}
