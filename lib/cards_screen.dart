import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'available_cards_screen.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;

  CardsScreen({required this.folderId});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final data = await dbHelper.getCardsByFolder(widget.folderId);
    setState(() {
      cards = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cards')),
      body: cards.isEmpty
          ? Center(child: Text('No cards available'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,              // 2 cards per row
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.7,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return _buildCard(card);
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAvailableCards(),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          SizedBox(
            height: 150, // Constrain the image height
            child: Image.asset(
              card['image_url'],
              fit: BoxFit.contain, // Scale the image to fit within bounds
            ),
          ),
          SizedBox(height: 10), // Space between image and text
          Text(card['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(card['suit'], style: TextStyle(fontSize: 16, color: Colors.grey)),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteCard(card['id']),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvailableCards() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableCardsScreen(
          folderId: widget.folderId,
          onCardSelected: (selectedCard) {
            _addCardToFolder(selectedCard);
          },
        ),
      ),
    );
  }

  Future<void> _deleteCard(int cardId) async {
    await dbHelper.deleteCard(cardId);
    _loadCards(); // Refresh cards
  }

  Future<void> _addCardToFolder(Map<String, dynamic> selectedCard) async {
    // Assign the selected card to the current folder
    selectedCard['folder_id'] = widget.folderId;
    await dbHelper.updateCard(selectedCard['id'], selectedCard);
    _loadCards();
    Navigator.pop(context); // Close the available cards screen
  }
}
