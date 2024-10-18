import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "CardManager.db";
  static final _databaseVersion = 1;

  static final folderTable = 'folders';
  static final cardTable = 'cards';

  static final folderId = 'id';
  static final folderName = 'name';
  static final folderTimestamp = 'timestamp';
  static final cardId = 'id';
  static final cardName = 'name';
  static final cardSuit = 'suit';
  static final cardImage = 'image_url';
  static final foreignFolderId = 'folder_id';

  static late Database _database;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $folderTable (
        $folderId INTEGER PRIMARY KEY AUTOINCREMENT,
        $folderName TEXT NOT NULL,
        $folderTimestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $cardTable (
        $cardId INTEGER PRIMARY KEY AUTOINCREMENT,
        $cardName TEXT NOT NULL,
        $cardSuit TEXT NOT NULL,
        $cardImage TEXT,
        $foreignFolderId INTEGER,
        FOREIGN KEY ($foreignFolderId) REFERENCES $folderTable ($folderId)
      )
    ''');

    await _prepopulateData(db);
  }

  Future<void> _prepopulateData(Database db) async {
    // Insert default folders (Hearts, Spades, Clubs, Diamonds)
    List<Map<String, dynamic>> folders = [
      { 'name': 'Hearts', 'timestamp': DateTime.now().toString() },
      { 'name': 'Spades', 'timestamp': DateTime.now().toString() },
      { 'name': 'Clubs', 'timestamp': DateTime.now().toString() },
      { 'name': 'Diamonds', 'timestamp': DateTime.now().toString() }
    ];

    for (var folder in folders) {
      await db.insert(folderTable, folder);
    }

    // Prepopulate cards for each suit
    List<Map<String, dynamic>> cards = [
      { 'name': '2 of Clubs', 'suit': 'Clubs', 'image_url': 'assets/2_of_clubs.png', 'folder_id': null },
      { 'name': '2 of Diamonds', 'suit': 'Diamonds', 'image_url': 'assets/2_of_diamonds.png', 'folder_id': null },
      { 'name': '2 of Hearts', 'suit': 'Hearts', 'image_url': 'assets/2_of_hearts.png', 'folder_id': null },
      { 'name': '2 of Spades', 'suit': 'Spades', 'image_url': 'assets/2_of_spades.png', 'folder_id': null },
      { 'name': '6 of Hearts', 'suit': 'Hearts', 'image_url': 'assets/6_of_hearts.png', 'folder_id': null },
      { 'name': '6 of Spades', 'suit': 'Spades', 'image_url': 'assets/6_of_spades.png', 'folder_id': null },
      { 'name': '6 of Clubs', 'suit': 'Clubs', 'image_url': 'assets/6_of_clubs.png', 'folder_id': null },
      { 'name': '7 of Diamonds', 'suit': 'Diamonds', 'image_url': 'assets/7_of_diamonds.png', 'folder_id': null },
      { 'name': '7 of Clubs', 'suit': 'Clubs', 'image_url': 'assets/7_of_clubs.png', 'folder_id': null },
      { 'name': 'Ace of Clubs', 'suit': 'Clubs', 'image_url': 'assets/ace_of_clubs.png', 'folder_id': null },
      { 'name': 'Ace of Diamonds', 'suit': 'Diamonds', 'image_url': 'assets/ace_of_diamonds.png', 'folder_id': null },
      { 'name': 'Ace of Hearts', 'suit': 'Hearts', 'image_url': 'assets/ace_of_hearts.png', 'folder_id': null },
      { 'name': 'Ace of Spades', 'suit': 'Spades', 'image_url': 'assets/ace_of_spades.png', 'folder_id': null },
      { 'name': 'Jack of Hearts', 'suit': 'Hearts', 'image_url': 'assets/jack_of_hearts.png', 'folder_id': null },
    ];

    for (var card in cards) {
      await db.insert(cardTable, card);
    }

    print("Prepopulated folders and cards.");
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    return await _database.query(folderTable);
  }

  Future<List<Map<String, dynamic>>> getCardsByFolder(int folderId) async {
    return await _database.query(cardTable, where: '$foreignFolderId = ?', whereArgs: [folderId]);
  }

  Future<int> insertCard(Map<String, dynamic> card) async {
    return await _database.insert(cardTable, card);
  }

  Future<int> deleteCard(int cardId) async {
    return await _database.delete(cardTable, where: '$cardId = ?', whereArgs: [cardId]);
  }

  Future<int> updateCard(int cardId, Map<String, dynamic> newCard) async {
    return await _database.update(cardTable, newCard, where: '$cardId = ?', whereArgs: [cardId]);
  }

  Future<List<Map<String, dynamic>>> getAvailableCardsForFolder(int folderId) async {
  final data = await _database.query(
    cardTable,
    where: '$foreignFolderId IS NULL OR $foreignFolderId != ?',
    whereArgs: [folderId],
  );
  
  print("Available cards fetched for folder $folderId: $data");  // Debugging line
  return data;
  }
}
