import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/utility_widget.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Job job = ModalRoute.of(context)!.settings.arguments as Job;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          _buildBookmarkButton(context, job),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.isPremium)
              Container(
                width: double.infinity,
                color: Colors.amber.shade100,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const Center(
                  child: Text(
                    'Premium Job',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Job Header
            _buildJobHeader(job),
            
            // Job Images/Creatives
            if (job.creatives.isNotEmpty) _buildCreativesSection(job),
            
            // Job Details
            _buildDetailsSection(job),
            
            // Contact Section
            if (job.whatsappNo != null && job.whatsappNo!.isNotEmpty)
              _buildContactSection(job),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context, Job job) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        return IconButton(
          icon: Icon(
            job.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: job.isBookmarked ? Colors.amber : null,
          ),
          onPressed: () async {
            await provider.toggleBookmark(job);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    job.isBookmarked
                        ? 'Job added to bookmarks'
                        : 'Job removed from bookmarks',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildJobHeader(Job job) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (job.companyName != null && job.companyName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                job.companyName!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          _buildInfoRow(Icons.location_on, job.place ?? 'Location not specified'),
          _buildInfoRow(Icons.attach_money, job.salary ?? 'Salary not specified'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativesSection(Job job) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: job.creatives.length,
        itemBuilder: (context, index) {
          final creative = job.creatives[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                creative.file,
                height: 180,
                width: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 280,
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSection(Job job) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (job.otherDetails != null && job.otherDetails!.isNotEmpty)
            Text(
              job.otherDetails!,
              style: const TextStyle(fontSize: 14),
            )
          else
            const Text('No additional details available.'),
        ],
      ),
    );
  }

  Widget _buildContactSection(Job job) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _launchWhatsApp(job.whatsappNo!),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.message, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Contact on WhatsApp: ${job.whatsappNo}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    // Remove any non-numeric characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final whatsappUrl = "https://wa.me/$cleanNumber";
    
    final Uri uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // If WhatsApp is not installed, you might want to show a different option
      debugPrint('Could not launch WhatsApp');
    }
  }
}