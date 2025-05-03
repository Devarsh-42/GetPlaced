class Job {
  final int id;
  final String title;
  final String? companyName;
  final String? salary;
  final String? place;
  final String? whatsappNo;
  final String? otherDetails;
  final bool isPremium;
  final List<JobCreative> creatives;
  bool isBookmarked;

  Job({
    required this.id,
    required this.title,
    this.companyName,
    this.salary,
    this.place,
    this.whatsappNo,
    this.otherDetails,
    this.isPremium = false,
    this.creatives = const [],
    this.isBookmarked = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Extract primary details for salary and place
    Map<String, dynamic>? primaryDetails = json['primary_details'] as Map<String, dynamic>?;
    
    List<JobCreative> creativesList = [];
    if (json['creatives'] != null) {
      creativesList = (json['creatives'] as List)
          .map((creative) => JobCreative.fromJson(creative))
          .toList();
    }

    return Job(
      id: json['id'],
      title: json['title'],
      companyName: json['company_name'],
      salary: primaryDetails?['Salary'] ?? '-',
      place: primaryDetails?['Place'] ?? '-',
      whatsappNo: json['whatsapp_no'],
      otherDetails: json['other_details'],
      isPremium: json['is_premium'] ?? false,
      creatives: creativesList,
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'salary': salary,
      'place': place,
      'whatsappNo': whatsappNo,
      'otherDetails': otherDetails,
      'isPremium': isPremium ? 1 : 0, // SQLite doesn't have boolean type
      'isBookmarked': isBookmarked ? 1 : 0,
      // We'll handle creatives in a separate table or as serialized JSON
      'creatives': creatives.map((c) => c.toMap()).toList().toString()
    };
  }

  // Create Job from database map
  factory Job.fromMap(Map<String, dynamic> map) {
    List<JobCreative> creativesList = [];
    // Parse creatives from string if available
    if (map['creatives'] != null && map['creatives'].toString().isNotEmpty) {
      // This is a simplified approach - you may need a proper JSON parsing
      // depending on how you store the creatives
    }

    return Job(
      id: map['id'],
      title: map['title'],
      companyName: map['companyName'],
      salary: map['salary'],
      place: map['place'],
      whatsappNo: map['whatsappNo'],
      otherDetails: map['otherDetails'],
      isPremium: map['isPremium'] == 1,
      isBookmarked: map['isBookmarked'] == 1,
      creatives: creativesList,
    );
  }
}

class JobCreative {
  final String file;
  final String thumbUrl;
  final int creativeType;

  JobCreative({
    required this.file,
    required this.thumbUrl,
    required this.creativeType,
  });

  factory JobCreative.fromJson(Map<String, dynamic> json) {
    return JobCreative(
      file: json['file'],
      thumbUrl: json['thumb_url'],
      creativeType: json['creative_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'file': file,
      'thumbUrl': thumbUrl,
      'creativeType': creativeType,
    };
  }
}