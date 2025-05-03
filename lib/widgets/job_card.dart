import 'package:flutter/material.dart';
import '../models/job.dart';
import 'package:flutter/cupertino.dart';

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
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    // Define colors based on theme or custom colors
    final cardColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(job),
            splashColor: theme.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, textColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompanyInfo(subTextColor),
                      const SizedBox(height: 16.0),
                      _buildJobStats(theme, subTextColor),
                      if (job.description != null && job.description!.isNotEmpty)
                        ..._buildDescription(theme, subTextColor),
                      const SizedBox(height: 16.0),
                      _buildFooter(theme, subTextColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Logo or placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getRandomColor(),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                job.companyName != null && job.companyName!.isNotEmpty
                    ? job.companyName![0].toUpperCase()
                    : 'J',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Job Title and Premium Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (job.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade600, Colors.orange.shade700],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Text(
                  job.title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Bookmark button
          _buildBookmarkButton(),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: () => onBookmarkToggle(job),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: job.isBookmarked
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          job.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: job.isBookmarked ? Colors.blue : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(Color subTextColor) {
    return Row(
      children: [
        Icon(Icons.business, size: 16.0, color: subTextColor),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            job.companyName ?? 'Company not specified',
            style: TextStyle(
              fontSize: 15.0,
              color: subTextColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (job.postedDate != null)
          Text(
            _formatPostedDate(job.postedDate!),
            style: TextStyle(
              fontSize: 12.0,
              color: subTextColor,
            ),
          ),
      ],
    );
  }

  Widget _buildJobStats(ThemeData theme, Color subTextColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                icon: Icons.location_on,
                text: job.place ?? 'Location not specified',
                color: subTextColor,
              ),
              SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.work,
                text: job.jobType ?? 'Full-time',
                color: subTextColor,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.payments,
                text: job.salary ?? 'Salary not specified',
                color: subTextColor,
              ),
              SizedBox(width: 12),
              _buildStatItem(
                icon: Icons.access_time,
                text: job.experience ?? 'Experience not specified',
                color: subTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16.0, color: color),
          SizedBox(width: 6.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.0,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDescription(ThemeData theme, Color subTextColor) {
    return [
      const SizedBox(height: 16.0),
      Text(
        'Description',
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        job.description!,
        style: TextStyle(
          fontSize: 14.0,
          color: subTextColor,
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }

  Widget _buildFooter(ThemeData theme, Color subTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (job.whatsappNo != null && job.whatsappNo!.isNotEmpty)
          _buildContactButton(
            icon: Icons.message,
            text: 'WhatsApp',
            color: Color(0xFF25D366),
          ),
        if (job.email != null && job.email!.isNotEmpty)
          _buildContactButton(
            icon: Icons.email,
            text: 'Email',
            color: theme.primaryColor,
          ),
        if (job.phone != null && job.phone!.isNotEmpty)
          _buildContactButton(
            icon: Icons.phone,
            text: 'Call',
            color: Colors.blue,
          ),
      ],
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 36,
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatPostedDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else {
      return 'Just now';
    }
  }

  Color _getRandomColor() {
    final List<Color> colors = [
      Colors.blue.shade700,
      Colors.indigo.shade700,
      Colors.purple.shade700,
      Colors.deepPurple.shade700,
      Colors.teal.shade700,
      Colors.green.shade700,
    ];
    return colors[job.id.hashCode % colors.length];
  }
}

// Extension for Job model to make it compatible with the UI
extension JobUIExtensions on Job {
  String? get jobType => null; // Add this property to your Job model
  String? get experience => null; // Add this property to your Job model
  String? get description => null; // Add this property to your Job model
  String? get email => null; // Add this property to your Job model
  String? get phone => null; // Add this property to your Job model
  DateTime? get postedDate => null; // Add this property to your Job model
}