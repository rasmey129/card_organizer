import 'package:flutter/material.dart';
import 'databaseHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.init();  // Ensure the database is initialized

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
        future: databaseHelper.getFoldersWithCardCounts(), // Fetch folders from DB
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No folders available"));
          } else {
            // Display the folder list
            final folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return ListTile(
                  title: Text(folder['folderName']),
                  subtitle: Text('Cards: ${folder['cardCount']}'),
                  onTap: () {
                    // Navigate to the cards list screen
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
      body: SafeArea(  // Ensure the content is within the safe area
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: databaseHelper.getCardsForFolder(folderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No cards available"));
            } else {
              final cards = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0), // Add some padding for spacing
                    child: ElevatedButton(
                      onPressed: () => _showAddCardDialog(context),
                      child: Text("Add Card"),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Show a dialog to add a new card
  void _showAddCardDialog(BuildContext context) {
    final nameController = TextEditingController();
    final suitController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Card Name"),
              ),
              TextField(
                controller: suitController,
                decoration: InputDecoration(labelText: "Suit"),
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: "Image URL (optional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final suit = suitController.text;
                final imageUrl = imageUrlController.text;

                // Add card to the folder
                if (name.isNotEmpty && suit.isNotEmpty) { // Basic validation
                  databaseHelper.addCardToFolder(name, suit, imageUrl, folderId);
                }
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Add Card"),
            ),
          ],
        );
      },
    );
  }
}