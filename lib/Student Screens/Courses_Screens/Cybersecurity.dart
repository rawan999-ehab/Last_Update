import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Cybersecurity extends StatelessWidget {
  static const String routeName = "Cybersecurity";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF196AB3),
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(color: Colors.white), // This makes the back arrow white
        title: Text(
          'Cybersecurity',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Image describing the field
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/Cybersecurity.jpeg.webp', // Replace with your image path
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Cybersecurity is the practice of protecting internet-connected systems such as hardware, software, and data from cyber threats.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),

                  // Icon and Video Section
                  Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        color: Color(0xFF196AB3),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Watch Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF196AB3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Placeholder for Video (retrieved from database)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FutureBuilder<String>(
                        // Replace with your database call to retrieve video URL
                        future: fetchVideoUrlFromDatabase(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading video');
                          } else {
                            return VideoPlayerWidget(videoUrl: snapshot.data!);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Roadmap Section with Unique Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Roadmap Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RoadmapScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF196AB3),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore Roadmap',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Places Where Courses Are Available
                  Text(
                    'Places to Learn Cybersecurity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),

                  // List of Course Cards
                  CourseCard(
                    logo: 'assets/images/udemy.png',
                    title: 'Cybersecurity Course',
                    subtitle: 'Udemy - Online Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://www.udemy.com/courses/search/?q=cyber+security+course&src=sac&kw=cyber'));
                    },
                  ),
                  SizedBox(height: 16),
                  CourseCard(
                    logo: 'assets/images/coursera.png',
                    title: 'Cybersecurity Course',
                    subtitle: 'Coursera - Online Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://www.coursera.org/collections/cybersecurity-for-beginners'));
                    },
                  ),
                  SizedBox(height: 16),
                  CourseCard(
                    logo: 'assets/images/tryhackme.png',
                    title: 'Cybersecurity Course',
                    subtitle: 'TryHackMe - Online Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://tryhackme.com/'));
                    },
                  ),
                  SizedBox(height: 16),
                  CourseCard(
                    logo: 'assets/images/edx-free-courses.jpg',
                    title: 'Cybersecurity Course',
                    subtitle: 'edx - Online Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://www.edx.org/search?q=cybersecurity%20course'));
                    },
                  ),
                  SizedBox(height: 16),
                  CourseCard(
                    logo: 'assets/images/EC-Council- image.png',
                    title: 'Cybersecurity Course',
                    subtitle: 'EC-Council - Hybrid Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://www.eccouncil.org/'));
                    },
                  ),
                  SizedBox(height: 16),
                  CourseCard(
                    logo: 'assets/images/sans institute-.png',
                    title: 'Cybersecurity Course',
                    subtitle: 'Sans Institute - Offline Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://www.sans.org/cyber-security-courses/'));
                    },
                  ),
                  SizedBox(height: 16),
                  CourseCard(
                    logo: 'assets/images/IT gate academy.png',
                    title: 'Cybersecurity Course',
                    subtitle: 'IT Gate Academy - Hybrid Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://www.itgateacademy.com/cours_category.php?id=12'));
                    },
                  ),
                  SizedBox(height: 16),
                  CourseCard(
                    logo: 'assets/images/inspire-logo.png',
                    title: 'Cybersecurity Course',
                    subtitle: 'Inspire - Offline Courses',
                    onApply: () {
                      launchUrl(Uri.parse('https://www.cybersecurityindia.in/'));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Simulate fetching video URL from database
  Future<String> fetchVideoUrlFromDatabase() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return 'https://example.com/cybersecurity-video.mp4'; // Replace with actual URL
  }
}
// RoadmapScreen image

class RoadmapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roadmap'),
      ),
      body: Container(
        color: Colors.white,
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.1,  // Minimum zoom level (10% of original)
          maxScale: 4.0,  // Maximum zoom level (4x original)
          panEnabled: true,  // Allow panning
          scaleEnabled: true,  // Allow zooming
          child: Center(
            child: Image.asset('assets/images/cybersecurity-roadmap-.png'),
          ),
        ),
      ),
    );
  }
}

// Video Player Widget (Placeholder)
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
            'Video Player: $videoUrl'), // Replace with actual video player implementation
      ),
    );
  }
}

// CourseCard Widget (Reusable)
class CourseCard extends StatelessWidget {
  final String logo;
  final String title;
  final String subtitle;
  final VoidCallback onApply;

  const CourseCard({
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF196AB3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.asset(
                  logo,
                  height: 50,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF196AB3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 40),
                  Image.asset(
                    'assets/images/tap.png',
                    color: Colors.white,
                    height: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}