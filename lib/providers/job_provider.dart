import 'package:flutter/foundation.dart';
import 'package:getplaced/services/api_services.dart';
import 'package:getplaced/services/database_services.dart';
import '../models/job.dart';

enum LoadingStatus { idle, loading, success, error }

class JobProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  
  List<Job> _jobs = [];
  List<Job> _bookmarkedJobs = [];
  
  LoadingStatus _jobsStatus = LoadingStatus.idle;
  LoadingStatus _bookmarksStatus = LoadingStatus.idle;
  
  String _errorMessage = '';
  
  int _currentPage = 1;
  bool _hasMorePages = true;
  
  // Getters
  List<Job> get jobs => _jobs;
  List<Job> get bookmarkedJobs => _bookmarkedJobs;
  LoadingStatus get jobsStatus => _jobsStatus;
  LoadingStatus get bookmarksStatus => _bookmarksStatus;
  String get errorMessage => _errorMessage;
  bool get hasMorePages => _hasMorePages;
  
  // Initialize - load bookmarks from database
  Future<void> init() async {
    await loadBookmarkedJobs();
  }
  
  // Fetch jobs with pagination
  Future<void> fetchJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      _jobs = [];
    }
    
    if (!_hasMorePages && !refresh) return;
    
    if (_currentPage == 1) {
      _jobsStatus = LoadingStatus.loading;
    }
    
    notifyListeners();
    
    try {
      // For demo, using mock data
      final newJobs = await _apiService.getMockJobs(page: _currentPage);
      
      if (newJobs.isEmpty) {
        _hasMorePages = false;
      } else {
        // Check bookmarked status for each job
        for (var job in newJobs) {
          job.isBookmarked = await _dbService.isJobBookmarked(job.id);
        }
        
        if (refresh) {
          _jobs = newJobs;
        } else {
          _jobs.addAll(newJobs);
        }
        
        _currentPage++;
      }
      
      _jobsStatus = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _jobsStatus = LoadingStatus.error;
    }
    
    notifyListeners();
  }
  
  // Load bookmarked jobs from database
  Future<void> loadBookmarkedJobs() async {
    _bookmarksStatus = LoadingStatus.loading;
    notifyListeners();
    
    try {
      _bookmarkedJobs = await _dbService.getBookmarkedJobs();
      _bookmarksStatus = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _bookmarksStatus = LoadingStatus.error;
    }
    
    notifyListeners();
  }
  
  // Toggle bookmark for a job
  Future<void> toggleBookmark(Job job) async {
    try {
      final isBookmarked = await _dbService.toggleBookmark(job);
      
      // Update job in lists
      _updateJobBookmarkStatus(job.id, isBookmarked);
      
      // Reload bookmarked jobs
      await loadBookmarkedJobs();
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Helper to update the bookmark status in the jobs list
  void _updateJobBookmarkStatus(int jobId, bool isBookmarked) {
    // Update in jobs list
    for (int i = 0; i < _jobs.length; i++) {
      if (_jobs[i].id == jobId) {
        _jobs[i].isBookmarked = isBookmarked;
        break;
      }
    }
    
    // Update or remove from bookmarked jobs list
    if (!isBookmarked) {
      _bookmarkedJobs.removeWhere((job) => job.id == jobId);
    }
  }
}