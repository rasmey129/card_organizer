import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Database name and version
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  // Table and column names for Folders table
  static const folderTable = 'folders';
  static const folderId = '_id';
  static const folderName = 'folderName';
  static const folderTimestamp = 'timestamp';

  // Table and column names for Cards table
  static const cardsTable = 'cards';
  static const cardId = '_id';
  static const cardName = 'name';
  static const cardSuit = 'suit';
  static const cardImageUrl = 'imageUrl';
  static const cardFolderId = 'folderId';

  late Database _db;

  // Initialize the database
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database tables and prepopulate data
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

    // Insert default folder entries
    await _insertDefaultFolders(db);

    // Prepopulate the Cards table with all standard cards
    await _insertStandardCards(db);
  }

  // Insert initial folder data (Hearts, Spades, Diamonds, Clubs) with a timestamp
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

  // Prepopulate the Cards table with all standard cards and their image URLs
  Future<void> _insertStandardCards(Database db) async {
    const suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    const cardNames = [
      'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'
    ];

    for (var suit in suits) {
      for (var i = 0; i < cardNames.length; i++) {
        String cardName = '${cardNames[i]} of $suit';
        String imageUrl = _getCustomImageUrl(suit, cardNames[i]);
        int folderId = suits.indexOf(suit) + 1; // Assuming folder IDs are 1-4 for each suit

        await db.insert(cardsTable, {
          cardName: cardName,
          cardSuit: suit,
          cardImageUrl: imageUrl,
          cardFolderId: folderId,
        });
      }
    }
  }

  // Custom URLs for specific cards
  String _getCustomImageUrl(String suit, String cardName) {
    const customUrls = {
      'Clubs': {
        'Ace': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/English_pattern_ace_of_clubs.svg/1280px-English_pattern_ace_of_clubs.svg.png',
        'King': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/English_pattern_king_of_clubs.svg/1280px-English_pattern_king_of_clubs.svg.png',
        'Jack': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/English_pattern_jack_of_clubs.svg/1280px-English_pattern_jack_of_clubs.svg.png',
      },
      'Diamonds': {
        '4': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/English_pattern_4_of_diamonds.svg/1280px-English_pattern_4_of_diamonds.svg.png',
        '6': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/English_pattern_6_of_diamonds.svg/1280px-English_pattern_6_of_diamonds.svg.png',
        '8': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/English_pattern_8_of_diamonds.svg/1280px-English_pattern_8_of_diamonds.svg.png',
        'Jack': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/English_pattern_jack_of_diamonds.svg/1280px-English_pattern_jack_of_diamonds.svg.png',
      },
      'Hearts': {
        '3': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/English_pattern_3_of_hearts.svg/1280px-English_pattern_3_of_hearts.svg.png',
        '7': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/English_pattern_7_of_hearts.svg/1280px-English_pattern_7_of_hearts.svg.png',
        'Queen': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/English_pattern_queen_of_hearts.svg/1280px-English_pattern_queen_of_hearts.svg.png',
      },
      'Spades': {
        '2': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/English_pattern_2_of_spades.svg/1280px-English_pattern_2_of_spades.svg.png',
        '5': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/English_pattern_5_of_spades.svg/1280px-English_pattern_5_of_spades.svg.png',
        'Jack': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/English_pattern_jack_of_spades.svg/1280px-English_pattern_jack_of_spades.svg.png',
      }
    };

    return customUrls[suit]?[cardName] ?? '';
  }
}