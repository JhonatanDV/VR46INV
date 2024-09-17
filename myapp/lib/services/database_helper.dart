import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/sale.dart';
import 'package:intl/intl.dart'; // Asegúrate de importar intl para formatear fechas

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'myapp.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        quantity INTEGER,
        price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        quantitySold INTEGER,
        totalAmount REAL,
        discountPercentage REAL,
        saleDate TEXT,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE sales ADD COLUMN discountPercentage REAL;
      ''');
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Sale>> getSales() async {
    final db = await database;
    final maps = await db.query('sales');
    return List.generate(maps.length, (i) {
      return Sale.fromMap(maps[i]);
    });
  }

  Future<int> insertSale(Sale sale) async {
    final db = await database;
    return await db.insert('sales', sale.toMap());
  }

  Future<int> getProductQuantity(int productId) async {
    final db = await database;
    final result = await db.query(
      'products',
      columns: ['quantity'],
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (result.isNotEmpty) {
      return result.first['quantity'] as int;
    }
    return 0;
  }

  Future<void> deleteAllSales() async {
    final db = await database;
    await db.delete('sales');
  }

  Future<int> updateProductQuantity(int productId, int newQuantity) async {
    final db = await database;
    return await db.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Sale>> getSalesByDate(DateTime selectedDate) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final maps = await db.query(
      'sales',
      where: 'saleDate = ?',
      whereArgs: [formattedDate],
    );
    return List.generate(maps.length, (i) {
      return Sale.fromMap(maps[i]);
    });
  }
}
