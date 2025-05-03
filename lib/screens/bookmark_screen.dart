import 'package:flutter/material.dart';
import 'package:getplaced/widgets/utility_widget.dart' as customWidgets;
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/utility_widget.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // Load bookmarked jobs when screen initializes
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    await jobProvider.loadBookmarkedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadBookmarks,
        child: Consumer<JobProvider>(
          builder: (context, jobProvider, child) {
            if (jobProvider.bookmarksStatus == LoadingStatus.loading) {
              return const LoadingWidget(message: 'Loading bookmarks...');
            }

            if (jobProvider.bookmarksStatus == LoadingStatus.error) {
              return customWidgets.ErrorWidget(
                message: jobProvider.errorMessage,
                onRetry: _loadBookmarks,
              );
            }

            if (jobProvider.bookmarkedJobs.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.bookmark_border,
                message: 'No bookmarked jobs\n\nJobs you bookmark will appear here',
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: jobProvider.bookmarkedJobs.length,
              itemBuilder: (context, index) {
                final job = jobProvider.bookmarkedJobs[index];
                
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