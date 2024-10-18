import 'package:flutter/material.dart';
import 'database_helper.dart';

class AvailableCardsScreen extends StatefulWidget {
  final int folderId;
  final Function(Map<String, dynamic> card) onCardSelected;

  AvailableCardsScreen({required this.folderId, required this.onCardSelected});

  @override
  _AvailableCardsScreenState createState() => _AvailableCardsScreenState();
}

class _AvailableCardsScreenState extends State<AvailableCardsScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> availableCards = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableCards();
  }

  Future<void> _loadAvailableCards() async {
    // Fetch cards that are not already in the folder
    final data = await dbHelper.getAvailableCardsForFolder(widget.folderId);
    setState(() {
      availableCards = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Card to Add')),
      body: availableCards.isEmpty
          ? Center(child: Text('No cards available'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Show 3 cards per row
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7,
              ),
              itemCount: availableCards.length,
              itemBuilder: (context, index) {
                final card = availableCards[index];
                return GestureDetector(
                  onTap: () => widget.onCardSelected(card),
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            card['image_url'],
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(card['name'], style: TextStyle(fontSize: 16)),
                        Text(card['suit'], style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
