import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job.dart';

class ApiService {
  // In a real app, replace with your API endpoint
  static const String _baseUrl = 'https://testapi.getlokalapp.com/common/jobs';
  
  // Fetch jobs with pagination
  Future<List<Job>> getJobs({int page = 1, int pageSize = 3}) async {
    try {
      // In a real implementation, you'd add pagination parameters to the URL
      final response = await http.get(Uri.parse('$_baseUrl?page=$page&pageSize=$pageSize'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('results') && data['results'] is List) {
          return (data['results'] as List)
              .map((job) => Job.fromJson(job))
              .toList();
        }
        
        return [];
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load jobs: $e');
    }
  }

  // Mock implementation for demo
  Future<List<Job>> getMockJobs({int page = 1, int pageSize = 10}) async {
    // In a real app, you would call the API
    // For demo, we'll provide mock data from the parsed JSON
    
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    // Hard-coded mock data based on the provided JSON
    final String mockJson = '''
    {
      "results": [
        {
          "id": 606376,
          "title": "Satyam Home Care Services wants nannies and ward boys for patient care, housework and cooking.",
          "company_name": "Satyam Home Care Services",
          "primary_details": {
            "Place": "Hyderabad",
            "Salary": "₹18000 - ₹25000+"
          },
          "whatsapp_no": "6302532832",
          "other_details": "Title : Satyam Home Care Services Wanted Nurses, Ward Boys for Patient Care, Housekeeping, Cooking\\r\\nOther Details: Satyam Home Care requires experienced women (females) to provide patient care, home/cooking work for elderly. Agents Commission: 5,000/-\\r\\nEligibility: Experience is sufficient.\\r\\nNo fee is required\\r\\nVacancies : 200\\r\\nSalary: 18,000/- upto 25,000/- will be given\\r\\nExperience: Any\\r\\nAddress: Kookat Palli\\r\\nClick the call button below for more details",
          "is_premium": true,
          "is_bookmarked": false,
          "creatives": [
            {
              "file": "https://media.getlokalapp.com/classified_images/606376/606376_411e9452730aa77ccb17642734b7995f.jpg",
              "thumb_url": "https://creatives.getlokalapp.com/cache/e2/77/e277823ddb606daca9b148b786a5de3e.jpg",
              "creative_type": 1
            }
          ]
        },
        {
          "id": 605947,
          "title": "Wanted Tele Sales Executives",
          "company_name": "Local app",
          "primary_details": {
            "Place": "Hyderabad",
            "Salary": "-"
          },
          "whatsapp_no": "9985628338",
          "other_details": "",
          "is_premium": false,
          "is_bookmarked": false,
          "creatives": [
            {
              "file": "https://media.getlokalapp.com/classified_images/605947/605947_WhatsApp_Image_2024-03-11_at_4.09.03_PM.jpeg",
              "thumb_url": "https://creatives.getlokalapp.com/cache/23/da/23dae3c5cb08c8009dada3582a3913fe.jpg",
              "creative_type": 1
            }
          ]
        }
      ]
    }
    ''';
    
    final Map<String, dynamic> data = json.decode(mockJson);
    
    if (data.containsKey('results') && data['results'] is List) {
      return (data['results'] as List)
          .map((job) => Job.fromJson(job))
          .toList();
    }
    
    return [];
  }
}