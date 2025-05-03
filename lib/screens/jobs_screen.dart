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

class _JobsScreenState extends State<JobsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initial data fetch
    _loadJobs();

    // Set up scroll listener for infinite scroll
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more jobs when we're close to the bottom
      _loadMoreJobs();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadJobs,
        child: Consumer<JobProvider>(
          builder: (context, jobProvider, child) {
            if (jobProvider.jobsStatus == LoadingStatus.loading && 
                jobProvider.jobs.isEmpty) {
              return const LoadingWidget(message: 'Loading jobs...');
            }

            if (jobProvider.jobsStatus == LoadingStatus.error && 
                jobProvider.jobs.isEmpty) {
              return utility.ErrorWidget(
                message: jobProvider.errorMessage,
                onRetry: _loadJobs,
              );
            }

            if (jobProvider.jobs.isEmpty) {
              return const utility.EmptyStateWidget(
                icon: Icons.work_off,
                message: 'No jobs available at the moment',
              );
            }

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: jobProvider.jobs.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom
                if (index == jobProvider.jobs.length) {
                  return const utility.LoadingMoreWidget();
                }

                final job = jobProvider.jobs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, 
                    vertical: 8.0
                  ),
                  child: JobCard(
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}