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
  List<Job> _filteredJobs = [];
  
  LoadingStatus _jobsStatus = LoadingStatus.idle;
  LoadingStatus _bookmarksStatus = LoadingStatus.idle;
  LoadingStatus _searchStatus = LoadingStatus.idle;
  
  String _errorMessage = '';
  String _currentSearchQuery = '';
  String _currentCategory = '';
  String _currentLocation = '';
  double _minSalary = 0;
  double _maxSalary = 100000;
  
  int _currentPage = 1;
  bool _hasMorePages = true;
  
  // Getters
  List<Job> get jobs => _filteredJobs.isNotEmpty ? _filteredJobs : _jobs;
  List<Job> get bookmarkedJobs => _bookmarkedJobs;
  LoadingStatus get jobsStatus => _jobsStatus;
  LoadingStatus get bookmarksStatus => _bookmarksStatus;
  LoadingStatus get searchStatus => _searchStatus;
  String get errorMessage => _errorMessage;
  bool get hasMorePages => _hasMorePages;
  bool get isSearchActive => _currentSearchQuery.isNotEmpty || 
                            _currentCategory.isNotEmpty || 
                            _currentLocation.isNotEmpty ||
                            _minSalary > 0 || 
                            _maxSalary < 100000;
  
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
      _filteredJobs = [];
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
        
        // Apply current filters if any
        if (isSearchActive) {
          _applyFilters();
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
  
  // Search jobs functionality
  Future<void> searchJobs(String query) async {
    _searchStatus = LoadingStatus.loading;
    _currentSearchQuery = query.toLowerCase().trim();
    notifyListeners();
    
    try {
      await _applyFilters();
      _searchStatus = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _searchStatus = LoadingStatus.error;
    }
    
    notifyListeners();
  }
  
  // Filter jobs by category
  Future<void> filterByCategory(String category) async {
    _searchStatus = LoadingStatus.loading;
    _currentCategory = category.toLowerCase().trim();
    notifyListeners();
    
    try {
      await _applyFilters();
      _searchStatus = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _searchStatus = LoadingStatus.error;
    }
    
    notifyListeners();
  }
  
  // Filter jobs by location
  Future<void> filterByLocation(String location) async {
    _searchStatus = LoadingStatus.loading;
    _currentLocation = location.toLowerCase().trim();
    notifyListeners();
    
    try {
      await _applyFilters();
      _searchStatus = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _searchStatus = LoadingStatus.error;
    }
    
    notifyListeners();
  }
  
  // Filter jobs by salary range
  Future<void> filterBySalaryRange(double min, double max) async {
    _searchStatus = LoadingStatus.loading;
    _minSalary = min;
    _maxSalary = max;
    notifyListeners();
    
    try {
      await _applyFilters();
      _searchStatus = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _searchStatus = LoadingStatus.error;
    }
    
    notifyListeners();
  }
  
  // Reset all filters
  Future<void> resetFilters() async {
    _currentSearchQuery = '';
    _currentCategory = '';
    _currentLocation = '';
    _minSalary = 0;
    _maxSalary = 100000;
    _filteredJobs = [];
    notifyListeners();
  }
  
  // Apply all active filters
  Future<void> _applyFilters() async {
    if (!isSearchActive) {
      _filteredJobs = [];
      return;
    }
    
    _filteredJobs = _jobs.where((job) {
      bool matchesQuery = true;
      bool matchesCategory = true;
      bool matchesLocation = true;
      bool matchesSalary = true;
      
      // Filter by search query
      if (_currentSearchQuery.isNotEmpty) {
        matchesQuery = job.title.toLowerCase().contains(_currentSearchQuery) ||
                      (job.companyName?.toLowerCase().contains(_currentSearchQuery) ?? false) ||
                      (job.otherDetails?.toLowerCase().contains(_currentSearchQuery) ?? false);
      }
      
      // // Filter by category
      // if (_currentCategory.isNotEmpty) {
      //   matchesCategory = job.category?.toLowerCase() == _currentCategory;
      // }
      
      // Filter by location
      if (_currentLocation.isNotEmpty) {
        matchesLocation = job.place?.toLowerCase().contains(_currentLocation) ?? false;
      }
      
      // Filter by salary range
      if (_minSalary > 0 || _maxSalary < 100000) {
        // Extract numeric salary if possible
        double? jobSalary = _extractSalaryValue(job.salary);
        if (jobSalary != null) {
          matchesSalary = jobSalary >= _minSalary && jobSalary <= _maxSalary;
        } else {
          // If we can't determine salary, include it to avoid filtering out jobs without salary info
          matchesSalary = true;
        }
      }
      
      return matchesQuery && matchesCategory && matchesLocation && matchesSalary;
    }).toList();
  }
  
  // Helper method to extract numeric salary from string
  double? _extractSalaryValue(String? salaryString) {
    if (salaryString == null || salaryString.isEmpty) return null;
    
    // Extract numbers from string (this is a simplified approach)
    RegExp regExp = RegExp(r'(\d+[,.]?\d*)');
    var matches = regExp.allMatches(salaryString);
    if (matches.isEmpty) return null;
    
    // Get the first number found
    String? numStr = matches.first.group(0);
    if (numStr == null) return null;
    
    // Remove commas
    numStr = numStr.replaceAll(',', '');
    return double.tryParse(numStr);
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
    
    // Update in filtered jobs if needed
    for (int i = 0; i < _filteredJobs.length; i++) {
      if (_filteredJobs[i].id == jobId) {
        _filteredJobs[i].isBookmarked = isBookmarked;
        break;
      }
    }
    
    // Update or remove from bookmarked jobs list
    if (!isBookmarked) {
      _bookmarkedJobs.removeWhere((job) => job.id == jobId);
    }
  }
}