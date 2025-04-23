import 'package:flutter/material.dart';

class BuildCVScreen extends StatefulWidget {
  @override
  State<BuildCVScreen> createState() => _BuildCVScreenState();
}

class _BuildCVScreenState extends State<BuildCVScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final universityController = TextEditingController();
  final facultyController = TextEditingController();
  final gpaController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  final cityController = TextEditingController();
  final nationalIdController = TextEditingController();
  final skillsController = TextEditingController();
  final experienceController = TextEditingController();
  final languageController = TextEditingController();
  final linkController = TextEditingController();
  final courseController = TextEditingController();

  List<Map<String, String>> workExperiences = [];
  List<Map<String, String>> languages = [];
  List<Map<String, String>> courses = [];

  String selectedJobType = 'Full-time';
  String selectedLanguageLevel = 'Basic';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildCategory(
            title: "Personal Info",
            children: [
              _buildTextField("Full Name", nameController),
              _buildTextField("University", universityController),
              _buildTextField("Faculty", facultyController),
              _buildTextField("GPA", gpaController),
              _buildTextField("Date of Birth", dobController),
              _buildTextField("Phone Number", phoneController),
              _buildTextField("Gender", genderController),
              _buildTextField("Email", emailController),
              _buildTextField("City", cityController),
              _buildTextField("National ID", nationalIdController),
            ],
          ),
          _buildCategory(
            title: "Skills",
            children: [
              _buildTextField("Skills (comma-separated)", skillsController),
            ],
          ),
          _buildCategory(
            title: "Work Experience",
            children: [
              for (var experience in workExperiences)
                _buildExperienceFields(experience),
              _buildAddJobButton(),
            ],
          ),
          _buildCategory(
            title: "Languages",
            children: [
              for (var language in languages) _buildLanguageFields(language),
              _buildAddLanguageButton(),
            ],
          ),
          _buildCategory(
            title: "Courses",
            children: [
              for (var course in courses) _buildCourseFields(course),
              _buildAddCourseButton(),
            ],
          ),
          _buildCategory(
            title: "GitHub Link",
            children: [
              _buildTextField("Link", linkController),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("CV Saved Successfully")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2252A1),
              padding: EdgeInsets.symmetric(vertical: 14),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text("Submit CV", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: controller,
        validator: (value) => value == null || value.isEmpty ? "This field is required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent, // جعل الخلفية شفافة
          labelStyle: TextStyle(color: Colors.black), // اللون الأسود للنص
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory({required String title, required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue, width: 1),
      ),
      child: ExpansionTile(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _buildExperienceFields(Map<String, String> experience) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          _buildTextField("Job Title", TextEditingController(text: experience['jobTitle'])),
          _buildTextField("Company Name", TextEditingController(text: experience['companyName'])),
          _buildJobTypeSelection(experience),
          _buildTextField("Start Date", TextEditingController(text: experience['startDate'])),
          _buildTextField("End Date", TextEditingController(text: experience['endDate'])),
        ],
      ),
    );
  }

  Widget _buildJobTypeSelection(Map<String, String> experience) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: experience['JobType'] ?? selectedJobType,
        items: ['Full-time', 'Part-time', 'Remote'].map((String jobType) {
          return DropdownMenuItem<String>(
            value: jobType,
            child: Text(jobType),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            experience['JobType'] = value!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Job Type',
          labelStyle: TextStyle(color: Colors.black), // اللون الأسود للنص
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildAddJobButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          workExperiences.add({
            'JobTitle': '',
            'companyName': '',
            'JobType': 'Full-time',
            'startDate': '',
            'endDate': '',
          });
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue,
        side: BorderSide(color: Colors.blue, width: 2),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        '+ Add Job',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLanguageFields(Map<String, String> language) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          _buildTextField("Language", TextEditingController(text: language['language'])),
          DropdownButtonFormField<String>(
            value: language['level'] ?? selectedLanguageLevel,
            items: ['Basic', 'Intermediate', 'Fluent', 'Native'].map((String level) {
              return DropdownMenuItem<String>(
                value: level,
                child: Text(level),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                language['level'] = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Language Level',
              labelStyle: TextStyle(color: Colors.black), // اللون الأسود للنص
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLanguageButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          languages.add({
            'language': '',
            'level': 'Basic',
          });
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue,
        side: BorderSide(color: Colors.blue, width: 2),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        '+ Add Language',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCourseFields(Map<String, String> course) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          _buildTextField("Course Name", TextEditingController(text: course['courseName'])),
          _buildTextField("Company Name", TextEditingController(text: course['companyName'])),
          _buildTextField("Duration (e.g. 3 months)", TextEditingController(text: course['duration'])),
          _buildTextField("Start Date", TextEditingController(text: course['startDate'])),
          _buildTextField("End Date", TextEditingController(text: course['endDate'])),
        ],
      ),
    );
  }

  Widget _buildAddCourseButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          courses.add({
            'courseName': '',
            'companyName': '',
            'duration': '',
            'startDate': '',
            'endDate': '',
          });
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue,
        side: BorderSide(color: Colors.blue, width: 2),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        '+ Add Course',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
