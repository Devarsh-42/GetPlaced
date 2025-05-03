import 'package:flutter/material.dart';
import '../models/job.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final Function(Job) onTap;
  final Function(Job) onBookmarkToggle;

  const JobCard({
    Key? key,
    required this.job,
    required this.onTap,
    required this.onBookmarkToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => onTap(job),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Job title with premium badge if applicable
                  Expanded(
                    child: Row(
                      children: [
                        if (job.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bookmark button
                  IconButton(
                    icon: Icon(
                      job.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: job.isBookmarked ? Colors.blue : null,
                    ),
                    onPressed: () => onBookmarkToggle(job),
                  ),
                ],
              ),
              
              const SizedBox(height: 8.0),
              
              // Company name if available
              if (job.companyName != null && job.companyName!.isNotEmpty)
                Text(
                  job.companyName!,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[700],
                  ),
                ),
              
              const SizedBox(height: 12.0),
              
              // Location and salary
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.0, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Text(
                    job.place ?? 'Location not specified',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  Icon(Icons.payments, size: 16.0, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Text(
                    job.salary ?? 'Salary not specified',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              
              const SizedBox(height: 12.0),
              
              // Contact info
              if (job.whatsappNo != null && job.whatsappNo!.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.phone, size: 16.0, color: Colors.grey[600]),
                    const SizedBox(width: 4.0),
                    Text(
                      job.whatsappNo!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}