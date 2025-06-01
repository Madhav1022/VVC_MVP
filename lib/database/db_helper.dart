import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/contact_model.dart';

class DbHelper {
  static const _dbVersion = 2;

  // SQL for creating the table with all columns
  final String _createTableContact = '''
  CREATE TABLE $tableContact(
    $tblContactColId INTEGER PRIMARY KEY AUTOINCREMENT,
    $tblContactColFirebaseId TEXT,
    $tblContactColName TEXT,
    $tblContactColMobile TEXT,
    $tblContactColEmail TEXT,
    $tblContactColAddress TEXT,
    $tblContactColCompany TEXT,
    $tblContactColDesignation TEXT,
    $tblContactColWebsite TEXT,
    $tblContactColImageLocal TEXT,
    $tblContactColImageUrl TEXT,
    $tblContactColFavorite INTEGER,
    $tblContactColCreatedAt INTEGER
  )''';

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final dbPath = p.join(root, 'contact.db');
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute(_createTableContact);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $tableContact ADD COLUMN $tblContactColFirebaseId TEXT');
          await db.execute(
              'ALTER TABLE $tableContact ADD COLUMN $tblContactColImageLocal TEXT');
          await db.execute(
              'ALTER TABLE $tableContact ADD COLUMN $tblContactColImageUrl TEXT');
          await db.execute(
              'ALTER TABLE $tableContact ADD COLUMN $tblContactColCreatedAt INTEGER');
        }
      },
    );
  }

  /// Inserts a new contact or updates existing one. Returns the local row ID.
  Future<int> insertOrUpdateContact(ContactModel contact) async {
    final db = await _open();
    final map = contact.toMap();
    if (contact.id > 0) {
      await db.update(
        tableContact,
        map,
        where: '$tblContactColId = ?',
        whereArgs: [contact.id],
      );
      return contact.id;
    } else {
      final id = await db.insert(tableContact, map);
      contact.id = id;
      return id;
    }
  }

  /// Updates firebase-specific fields locally.
  Future<int> updateFirebaseFields(
      int localId, {
        required String firebaseId,
        required String imageUrl,
        DateTime? createdAt,
      }) async {
    final db = await _open();
    final m = <String, dynamic>{
      tblContactColFirebaseId: firebaseId,
      tblContactColImageUrl: imageUrl,
    };
    if (createdAt != null) {
      m[tblContactColCreatedAt] = createdAt.millisecondsSinceEpoch;
    }
    return db.update(
      tableContact,
      m,
      where: '$tblContactColId = ?',
      whereArgs: [localId],
    );
  }

  Future<List<ContactModel>> getAllContacts() async {
    final db = await _open();
    final rows = await db.query(tableContact);
    return rows.map(ContactModel.fromMap).toList();
  }

  Future<ContactModel> getContactById(int id) async {
    final db = await _open();
    final rows = await db.query(
      tableContact,
      where: '$tblContactColId = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw Exception('Contact not found');
    return ContactModel.fromMap(rows.first);
  }

  Future<List<ContactModel>> getAllFavoriteContacts() async {
    final db = await _open();
    final rows = await db.query(
      tableContact,
      where: '$tblContactColFavorite = ?',
      whereArgs: [1],
    );
    return rows.map(ContactModel.fromMap).toList();
  }

  Future<int> deleteContact(int id) async {
    final db = await _open();
    return db.delete(
      tableContact,
      where: '$tblContactColId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateFavorite(int id, int value) async {
    final db = await _open();
    return db.update(
      tableContact,
      {tblContactColFavorite: value},
      where: '$tblContactColId = ?',
      whereArgs: [id],
    );
  }
}
