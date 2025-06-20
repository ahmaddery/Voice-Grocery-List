import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_init.dart';

class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseInit.columnId: id,
      DatabaseInit.columnUsername: username,
      DatabaseInit.columnEmail: email,
      DatabaseInit.columnPassword: password,
      DatabaseInit.columnCreatedAt: createdAt,
      DatabaseInit.columnUpdatedAt: updatedAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map[DatabaseInit.columnId],
      username: map[DatabaseInit.columnUsername],
      email: map[DatabaseInit.columnEmail],
      password: map[DatabaseInit.columnPassword],
      createdAt: map[DatabaseInit.columnCreatedAt],
      updatedAt: map[DatabaseInit.columnUpdatedAt],
    );
  }
}

class DatabaseHelper {
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  static Future<int> registerUser(String username, String email, String password) async {
    final db = await DatabaseInit.database;
    
    // Check if username or email already exists
    final existingUser = await db.query(
      DatabaseInit.usersTable,
      where: '${DatabaseInit.columnUsername} = ? OR ${DatabaseInit.columnEmail} = ?',
      whereArgs: [username, email],
    );
    
    if (existingUser.isNotEmpty) {
      throw Exception('Username atau email sudah terdaftar');
    }
    
    final hashedPassword = _hashPassword(password);
    final user = {
      DatabaseInit.columnUsername: username,
      DatabaseInit.columnEmail: email,
      DatabaseInit.columnPassword: hashedPassword,
      DatabaseInit.columnCreatedAt: DateTime.now().toIso8601String(),
      DatabaseInit.columnUpdatedAt: DateTime.now().toIso8601String(),
    };
    
    return await db.insert(DatabaseInit.usersTable, user);
  }

  // Login user
  static Future<User?> loginUser(String username, String password) async {
    final db = await DatabaseInit.database;
    final hashedPassword = _hashPassword(password);
    
    final result = await db.query(
      DatabaseInit.usersTable,
      where: '${DatabaseInit.columnUsername} = ? AND ${DatabaseInit.columnPassword} = ?',
      whereArgs: [username, hashedPassword],
    );
    
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Get user by ID
  static Future<User?> getUserById(int id) async {
    final db = await DatabaseInit.database;
    
    final result = await db.query(
      DatabaseInit.usersTable,
      where: '${DatabaseInit.columnId} = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Get user by username
  static Future<User?> getUserByUsername(String username) async {
    final db = await DatabaseInit.database;
    
    final result = await db.query(
      DatabaseInit.usersTable,
      where: '${DatabaseInit.columnUsername} = ?',
      whereArgs: [username],
    );
    
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Update user
  static Future<int> updateUser(User user) async {
    final db = await DatabaseInit.database;
    
    final updatedUser = user.toMap();
    updatedUser[DatabaseInit.columnUpdatedAt] = DateTime.now().toIso8601String();
    
    return await db.update(
      DatabaseInit.usersTable,
      updatedUser,
      where: '${DatabaseInit.columnId} = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user
  static Future<int> deleteUser(int id) async {
    final db = await DatabaseInit.database;
    
    return await db.delete(
      DatabaseInit.usersTable,
      where: '${DatabaseInit.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Get all users (for admin purposes)
  static Future<List<User>> getAllUsers() async {
    final db = await DatabaseInit.database;
    
    final result = await db.query(DatabaseInit.usersTable);
    
    return result.map((map) => User.fromMap(map)).toList();
  }
}