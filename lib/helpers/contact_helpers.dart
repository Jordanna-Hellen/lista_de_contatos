import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableName = "contacts";
/*final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";*/

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
    }
    return _db;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newVersion) async {
      await db.execute(
          "CREATE TABLE $tableName(id INTEGER PRIMARY KEY, name TEXT, email TEXT, phone TEXT, img TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(tableName, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(tableName,
        columns: ["id", "name", "email", "phone", "img"],
        where: "$id = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(tableName, contact.toMap(),
        where: "id = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $tableName");
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map["id"];
    name = map["name"];
    email = map["email"];
    phone = map["phone"];
    img = map["img"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "name": name,
      "email": email,
      "phone": phone,
      "img": img
    };
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
