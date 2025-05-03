import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/job.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'jobs_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }
  
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY,
        title TEXT,
        companyName TEXT,
        salary TEXT,
        place TEXT,
        whatsappNo TEXT,
        otherDetails TEXT,
        isPremium INTEGER,
        isBookmarked INTEGER,
        creatives TEXT
      )
    ''');
  }
  
  // Insert or update a bookmarked job
  Future<void> saveBookmarkedJob(Job job) async {
    final db = await database;
    
    await db.insert(
      'jobs',
      job.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Remove a job from bookmarks
  Future<void> removeBookmarkedJob(int jobId) async {
    final db = await database;
    
    await db.delete(
      'jobs',
      where: 'id = ?',
      whereArgs: [jobId],
    );
  }
  
  // Get all bookmarked jobs
  Future<List<Job>> getBookmarkedJobs() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'jobs',
      where: 'isBookmarked = ?',
      whereArgs: [1],
    );
    
    return List.generate(maps.length, (i) {
      return Job.fromMap(maps[i]);
    });
  }
  
  // Check if a job is bookmarked
  Future<bool> isJobBookmarked(int jobId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.query(
      'jobs',
      where: 'id = ? AND isBookmarked = ?',
      whereArgs: [jobId, 1],
    );
    
    return result.isNotEmpty;
  }
  
  // Toggle bookmark status
  Future<bool> toggleBookmark(Job job) async {
    final isBookmarked = await isJobBookmarked(job.id);
    
    if (isBookmarked) {
      await removeBookmarkedJob(job.id);
      return false;
    } else {
      final updatedJob = Job(
        id: job.id,
        title: job.title,
        companyName: job.companyName,
        salary: job.salary,
        place: job.place,
        whatsappNo: job.whatsappNo,
        otherDetails: job.otherDetails,
        isPremium: job.isPremium,
        creatives: job.creatives,
        isBookmarked: true,
      );
      await saveBookmarkedJob(updatedJob);
      return true;
    }
  }
}