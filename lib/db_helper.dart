import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  //instance of DatabaseHelper.
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  //getter to get the database instance.
  Future<Database> get database async {
    //if the database already exists, return it.
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  //initializes the database.
  Future<Database> _initDb() async {
    //get the path to the documents directory.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //creates the database file path.
    String path = join(documentsDirectory.path, 'food_ordering.db');
    //opens the database.
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  //creates all of the database tables.
  Future<void> _onCreate(Database db, int version) async {
    //generates the food_items table.
    await db.execute('''
    CREATE TABLE food_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      cost REAL NOT NULL
    )
    ''');

    //generates the orders table.
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      total_cost REAL NOT NULL,
      items TEXT NOT NULL
    )
    ''');

    //inserts the 20 sample foods
    await db.insert('food_items', {'name': 'Pizza', 'cost': 8.00});
    await db.insert('food_items', {'name': 'Burger', 'cost': 5.00});
    await db.insert('food_items', {'name': 'Poutine', 'cost': 7.00});
    await db.insert('food_items', {'name': 'Salad', 'cost': 4.00});
    await db.insert('food_items', {'name': 'Sushi', 'cost': 10.00});
    await db.insert('food_items', {'name': 'Momos', 'cost': 6.00});
    await db.insert('food_items', {'name': 'Sandwich', 'cost': 3.00});
    await db.insert('food_items', {'name': 'Fries', 'cost': 2.50});
    await db.insert('food_items', {'name': 'Ice Cream', 'cost': 2.00});
    await db.insert('food_items', {'name': 'Steak', 'cost': 15.00});
    await db.insert('food_items', {'name': 'Chicken Wings', 'cost': 8.50});
    await db.insert('food_items', {'name': 'Ramen', 'cost': 9.00});
    await db.insert('food_items', {'name': 'Bubble Tea', 'cost': 3.50});
    await db.insert('food_items', {'name': 'Nachos', 'cost': 6.50});
    await db.insert('food_items', {'name': 'Pancakes', 'cost': 4.50});
    await db.insert('food_items', {'name': 'Shawarma', 'cost': 12.00});
    await db.insert('food_items', {'name': 'Ice Cream Cake', 'cost': 14.00});
    await db.insert('food_items', {'name': 'Pasta', 'cost': 5.00});
    await db.insert('food_items', {'name': 'Strawberry Pie', 'cost': 3.00});
    await db.insert('food_items', {'name': 'Grilled Cheese Sandwich', 'cost': 4.00});
  }

  //inserts a food item into the database.
  Future<int> insertFoodItem(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('food_items', row);
  }

  //queries all of the food items existing in the database.
  Future<List<Map<String, dynamic>>> queryAllFoodItems() async {
    Database db = await database;
    return await db.query('food_items');
  }

  //updates a food item existing in the database.
  Future<int> updateFoodItem(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('food_items', row, where: 'id = ?', whereArgs: [id]);
  }

  //deletes a food item from the existing database.
  Future<int> deleteFoodItem(int id) async {
    Database db = await database;
    return await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  //does the function of inserting an order into the database.
  Future<int> insertOrder(Map<String, dynamic> order) async {
    Database db = await database;
    return await db.insert('orders', order);
  }

  //does the function of querying an existing order by date, from the database.
  Future<Map<String, dynamic>?> queryOrderByDate(String date) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'orders',
      where: 'date = ?',
      whereArgs: [date],
    );
    return results.isNotEmpty ? results.first : null;
  }

  //does the job of updating an order existing in the database.
  Future<int> updateOrder(Map<String, dynamic> row, int id) async {
    Database db = await database;
    return await db.update('orders', row, where: 'id = ?', whereArgs: [id]);
  }
}
