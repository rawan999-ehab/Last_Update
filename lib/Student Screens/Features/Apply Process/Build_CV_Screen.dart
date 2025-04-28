import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuildCVScreen extends StatefulWidget {
  @override
  State<BuildCVScreen> createState() => _BuildCVScreenState();
}

class _BuildCVScreenState extends State<BuildCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;

  // Controllers for personal info
  final emailController = TextEditingController();
  final gpaController = TextEditingController();
  final nationalIdController = TextEditingController();
  final skillsController = TextEditingController();

  // Lists to store dynamic fields data
  List<WorkExperience> workExperiences = [];
  List<Language> languages = [];
  List<Course> courses = [];

  @override
  void initState() {
    super.initState();
    workExperiences.add(WorkExperience());
    languages.add(Language());
    courses.add(Course());

    if (user?.email != null) {
      emailController.text = user!.email!;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    gpaController.dispose();
    nationalIdController.dispose();
    skillsController.dispose();

    for (var exp in workExperiences) {
      exp.dispose();
    }

    for (var lang in languages) {
      lang.dispose();
    }

    for (var course in courses) {
      course.dispose();
    }

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> saveCV() async {
    if (_formKey.currentState!.validate()) {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login first")),
        );
        return;
      }

      try {
        DocumentReference buildCVRef = await FirebaseFirestore.instance.collection('Build_CV').add({
          'userId': user!.uid,
          'email': emailController.text,
          'gpa': gpaController.text,
          'nationalId': nationalIdController.text,
          'skills': skillsController.text.split(',').map((s) => s.trim()).toList(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance.collection('Student_Applicant').add({
          'userId': user!.uid,
          'email': emailController.text,
          'cvId': buildCVRef.id,
          'appliedFor': 'intern',
          'appliedAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

        for (var exp in workExperiences) {
          await buildCVRef.collection('Work_Experience').add({
            'jobTitle': exp.jobTitleController.text,
            'companyName': exp.companyNameController.text,
            'jobType': exp.jobType,
            'startDate': exp.startDateController.text,
            'endDate': exp.endDateController.text,
          });
        }

        for (var lang in languages) {
          await buildCVRef.collection('Language').add({
            'language': lang.languageController.text,
            'level': lang.level,
          });
        }

        for (var course in courses) {
          await buildCVRef.collection('Courses').add({
            'courseName': course.courseNameController.text,
            'companyName': course.companyNameController.text,
            'duration': course.durationController.text,
            'startDate': course.startDateController.text,
            'endDate': course.endDateController.text,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CV Saved and Application Submitted Successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving CV: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInfoContainer(),
            _buildCategory(
              title: "Additional Personal Info",
              children: [
                _buildTextField("Email", emailController),
                _buildTextField("GPA", gpaController),
                _buildTextField("National ID", nationalIdController, isNationalId: true),
              ],
            ),
            _buildCategory(
              title: "Skills",
              children: [
                _buildTextField("Skills (comma separated)", skillsController),
              ],
            ),
            _buildCategory(
              title: "Work Experience",
              children: [
                for (int i = 0; i < workExperiences.length; i++)
                  _buildExperienceFields(workExperiences[i], i),
                _buildAddButton(
                  text: "+ Add Job",
                  onPressed: () => setState(() => workExperiences.add(WorkExperience())),
                ),
              ],
            ),
            _buildCategory(
              title: "Languages",
              children: [
                for (int i = 0; i < languages.length; i++)
                  _buildLanguageFields(languages[i], i),
                _buildAddButton(
                  text: "+ Add Language",
                  onPressed: () => setState(() => languages.add(Language())),
                ),
              ],
            ),
            _buildCategory(
              title: "Courses",
              children: [
                for (int i = 0; i < courses.length; i++)
                  _buildCourseFields(courses[i], i),
                _buildAddButton(
                  text: "+ Add Course",
                  onPressed: () => setState(() => courses.add(Course())),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceFields(WorkExperience experience, int index) {
    return Column(
      children: [
        _buildTextField("Job Title", experience.jobTitleController),
        _buildTextField("Company Name", experience.companyNameController),
        _buildDropdownFormField<String>(
          value: experience.jobType,
          items: const ['Full-time', 'Part-time', 'Remote'],
          label: 'Job Type',
          onChanged: (value) => setState(() => experience.jobType = value!),
        ),
        _buildDateField("Start Date", experience.startDateController),
        _buildDateField("End Date", experience.endDateController),
        if (workExperiences.length > 1) _buildDeleteButton(() => setState(() => workExperiences.removeAt(index))),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLanguageFields(Language language, int index) {
    return Column(
      children: [
        _buildTextField("Language", language.languageController),
        _buildDropdownFormField<String>(
          value: language.level,
          items: const ['Basic', 'Intermediate', 'Advanced', 'Native'],
          label: 'Language Level',
          onChanged: (value) => setState(() => language.level = value!),
        ),
        if (languages.length > 1) _buildDeleteButton(() => setState(() => languages.removeAt(index))),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCourseFields(Course course, int index) {
    return Column(
      children: [
        _buildTextField("Course Name", course.courseNameController),
        _buildTextField("Company Name", course.companyNameController),
        _buildTextField("Duration (e.g. 3 months)", course.durationController),
        _buildDateField("Start Date", course.startDateController),
        _buildDateField("End Date", course.endDateController),
        if (courses.length > 1) _buildDeleteButton(() => setState(() => courses.removeAt(index))),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_month),
            color: Colors.blue,
            onPressed: () => _selectDate(context, controller),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNationalId = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          if (isNationalId && value.length != 14) {
            return "National ID must be 14 digits";
          }
          return null;
        },
        keyboardType: isNationalId ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // باقي الدوال تبقى كما هي بدون تغيير
  Widget _buildDropdownFormField<T>({
    required T value,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(VoidCallback onPressed) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildAddButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: saveCV,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2252A1),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text("Submit", style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your personal information will be sent from your profile. '
                  'If you need to update your details, please edit your profile first to ensure correct information.',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.blue, width: 1),
      ),
      child: ExpansionTile(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
          ),
        ),
        children: children,
      ),
    );
  }
}

class WorkExperience {
  final jobTitleController = TextEditingController();
  final companyNameController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  String jobType = 'Full-time';

  void dispose() {
    jobTitleController.dispose();
    companyNameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}

class Language {
  final languageController = TextEditingController();
  String level = 'Basic';

  void dispose() {
    languageController.dispose();
  }
}

class Course {
  final courseNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final durationController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  void dispose() {
    courseNameController.dispose();
    companyNameController.dispose();
    durationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}