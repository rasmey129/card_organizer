import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const folderTable = 'folders';
  static const folderId = '_id';
  static const folderName = 'folderName';
  static const folderTimestamp = 'timestamp';

  static const cardsTable = 'cards';
  static const cardId = '_id';
  static const cardName = 'name';
  static const cardSuit = 'suit';
  static const cardImageUrl = 'imageUrl';
  static const cardFolderId = 'folderId';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Creating Folders table
    await db.execute(
      'CREATE TABLE $folderTable ('
      '$folderId INTEGER PRIMARY KEY, '
      '$folderName TEXT NOT NULL, '
      '$folderTimestamp TEXT NOT NULL'
      ')'
    );

    // Creating Cards table
    await db.execute(
      'CREATE TABLE $cardsTable ('
      '$cardId INTEGER PRIMARY KEY, '
      '$cardName TEXT NOT NULL, '
      '$cardSuit TEXT NOT NULL, '
      '$cardImageUrl TEXT, '
      '$cardFolderId INTEGER, '
      'FOREIGN KEY ($cardFolderId) REFERENCES $folderTable ($folderId)'
      ')'
    );

    await _insertDefaultFolders(db);
  }

  Future<void> _insertDefaultFolders(Database db) async {
    final folders = [
      {'name': 'Hearts', 'timestamp': DateTime.now().toIso8601String()},
      {'name': 'Spades', 'timestamp': DateTime.now().toIso8601String()},
      {'name': 'Diamonds', 'timestamp': DateTime.now().toIso8601String()},
      {'name': 'Clubs', 'timestamp': DateTime.now().toIso8601String()},
    ];

    for (var folder in folders) {
      await db.insert(folderTable, {
        folderName: folder['name'],
        folderTimestamp: folder['timestamp'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getFoldersWithCardCounts() async {
    final List<Map<String, dynamic>> result = await _db.rawQuery('''
      SELECT f.*, COUNT(c.$cardId) as cardCount 
      FROM $folderTable f 
      LEFT JOIN $cardsTable c ON f.$folderId = c.$cardFolderId 
      GROUP BY f.$folderId
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCardsForFolder(int folderId) async {
    return await _db.query(cardsTable, where: '$cardFolderId = ?', whereArgs: [folderId]);
  }

  Future<int> deleteCard(int cardId) async {
    return await _db.delete(cardsTable, where: '$cardId = ?', whereArgs: [cardId]);
  }

  Future<String?> addCardToFolder(String name, String suit, String imageUrl, int folderId) async {
    await _db.insert(cardsTable, {
      cardName: name,
      cardSuit: suit,
      cardImageUrl: imageUrl,
      cardFolderId: folderId,
    });
    return null; 
  }
}
