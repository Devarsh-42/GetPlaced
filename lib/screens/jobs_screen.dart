import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/utility_widget.dart' as utility;

class JobsScreen extends StatefulWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initial data fetch
    _loadJobs();

    // Set up scroll listener for infinite scroll
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more jobs when we're close to the bottom
      _loadMoreJobs();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        // Reset search and refresh jobs
        _loadJobs();
      }
    });
  }

  Future<void> _loadJobs() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    await jobProvider.fetchJobs(refresh: true);
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    // Only fetch more if we have more pages
    if (jobProvider.hasMorePages) {
      await jobProvider.fetchJobs();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    // Implement search functionality in your provider
    await jobProvider.searchJobs(query);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              onSubmitted: _handleSearch,
              autofocus: true,
            )
          : Text(
              'Job Finder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterOptions(),
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          tabs: [
            Tab(text: 'All Jobs'),
            Tab(text: 'Premium'),
            Tab(text: 'Bookmarked'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          _buildJobsList(context, jobType: 'all'),
          _buildJobsList(context, jobType: 'premium'),
          _buildJobsList(context, jobType: 'bookmarked'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Scroll to top
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
        child: Icon(Icons.arrow_upward),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Jobs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Salary Range',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          RangeSlider(
            values: RangeValues(0, 100000),
            min: 0,
            max: 100000,
            divisions: 20,
            labels: RangeLabels('\$0', '\$100K'),
            onChanged: (values) {
              // Update salary range filter
            },
          ),
          SizedBox(height: 20),
          Text(
            'Location',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Remote'),
              _buildFilterChip('New York'),
              _buildFilterChip('San Francisco'),
              _buildFilterChip('London'),
              _buildFilterChip('Tokyo'),
            ],
          ),
          Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset filters
                    Navigator.pop(context);
                  },
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        // Handle filter selection
      },
    );
  }

  Widget _buildJobsList(BuildContext context, {required String jobType}) {
    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          // Show different jobs based on tab
          final jobs = jobType == 'premium' 
              ? jobProvider.jobs.where((job) => job.isPremium).toList()
              : jobType == 'bookmarked'
                  ? jobProvider.jobs.where((job) => job.isBookmarked).toList()
                  : jobProvider.jobs;

          if (jobProvider.jobsStatus == LoadingStatus.loading && 
              jobProvider.jobs.isEmpty) {
            return const LoadingWidget(message: 'Discovering opportunities...');
          }

          if (jobProvider.jobsStatus == LoadingStatus.error && 
              jobProvider.jobs.isEmpty) {
            return utility.ErrorWidget(
              message: jobProvider.errorMessage,
              onRetry: _loadJobs,
            );
          }

          if (jobs.isEmpty) {
            return utility.EmptyStateWidget(
              icon: jobType == 'bookmarked' ? Icons.bookmark_border : Icons.work_off,
              message: jobType == 'premium' 
                ? 'No premium jobs available'
                : jobType == 'bookmarked'
                    ? 'No bookmarked jobs yet'
                    : 'No jobs match your criteria',
            );
          }

          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemCount: jobs.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == jobs.length) {
                return const utility.LoadingMoreWidget();
              }

              final job = jobs[index];
              return JobCard(
                job: job,
                onTap: (job) {
                  Navigator.pushNamed(
                    context, 
                    '/job-details',
                    arguments: job,
                  );
                },
                onBookmarkToggle: (job) {
                  Provider.of<JobProvider>(context, listen: false).toggleBookmark(job);
                },
              );
            },
          );
        },
      ),
    );
  }
}