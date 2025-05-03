import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuildCVScreen extends StatefulWidget {
  final String internshipId;
  final String internshipTitle;

  const BuildCVScreen({
    Key? key,
    required this.internshipId,
    required this.internshipTitle,
  }) : super(key: key);

  @override
  State<BuildCVScreen> createState() => _BuildCVScreenState();
}

class _BuildCVScreenState extends State<BuildCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final User? user = FirebaseAuth.instance.currentUser;

  bool _isLoading = false;

  // Controllers
  final emailController = TextEditingController();
  final gpaController = TextEditingController();
  final nationalIdController = TextEditingController();
  final skillsController = TextEditingController();

  // Dynamic fields
  List<WorkExperience> workExperiences = [];
  List<Language> languages = [];
  List<Course> courses = [];
  List<Education> educations = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    workExperiences.add(WorkExperience());
    languages.add(Language());
    courses.add(Course());
    educations.add(Education());

    if (user?.email != null) {
      emailController.text = user!.email!;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
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
    for (var edu in educations) {
      edu.dispose();
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> saveCV() async {
    if (_isLoading) return;
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;
    if (user == null) {
      _showSnackBar("Please login first");
      return;
    }

    try {
      setState(() => _isLoading = true);

      // حفظ البيانات الأساسية في Build_CV
      final cvData = {
        'userId': user!.uid,
        'email': emailController.text,
        'gpa': gpaController.text,
        'nationalId': nationalIdController.text,
        'skills': skillsController.text.split(',').map((s) => s.trim()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'internshipId': widget.internshipId,
      };

      // إنشاء وثيقة السيرة الذاتية
      final cvDocRef = FirebaseFirestore.instance
          .collection('Build_CV')
          .doc(user!.uid); // استخدام userId كمُعرّف للوثيقة

      await cvDocRef.set(cvData);

      // حفظ البيانات الفرعية (الخبرات، التعليم، إلخ)
      await _saveSubcollections(cvDocRef);

      // تسجيل المتقدم في Student_Applicant
      await _saveApplicantData(cvDocRef.id);

      _showSnackBar("CV Saved and Application Submitted Successfully");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error saving CV: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSubcollections(DocumentReference cvDocRef) async {
    final batch = FirebaseFirestore.instance.batch();

    // حفظ الخبرات العملية
    for (var exp in workExperiences) {
      if (exp.jobTitleController.text.isNotEmpty) {
        final docRef = cvDocRef.collection('Work_Experience').doc();
        batch.set(docRef, {
          'jobTitle': exp.jobTitleController.text,
          'companyName': exp.companyNameController.text,
          'jobType': exp.jobType,
          'startDate': exp.startDateController.text,
          'endDate': exp.endDateController.text,
        });
      }
    }

    // حفظ اللغات
    for (var lang in languages) {
      if (lang.languageController.text.isNotEmpty) {
        final docRef = cvDocRef.collection('Language').doc();
        batch.set(docRef, {
          'language': lang.languageController.text,
          'level': lang.level,
        });
      }
    }

    // حفظ الدورات
    for (var course in courses) {
      if (course.courseNameController.text.isNotEmpty) {
        final docRef = cvDocRef.collection('Courses').doc();
        batch.set(docRef, {
          'courseName': course.courseNameController.text,
          'companyName': course.companyNameController.text,
          'duration': course.durationController.text,
          'startDate': course.startDateController.text,
          'endDate': course.endDateController.text,
        });
      }
    }

    // حفظ المؤهلات التعليمية
    for (var edu in educations) {
      if (edu.degreeController.text.isNotEmpty) {
        final docRef = cvDocRef.collection('Education').doc();
        batch.set(docRef, {
          'degree': edu.degreeController.text,
          'university': edu.universityController.text,
          'major': edu.majorController.text,
          'startDate': edu.startDateController.text,
          'endDate': edu.endDateController.text,
        });
      }
    }

    await batch.commit();
  }

  Future<void> _saveApplicantData(String cvId) async {
    await FirebaseFirestore.instance.collection('Student_Applicant').add({
      'userId': user!.uid,
      'email': emailController.text,
      'cvId': cvId,
      'appliedFor': widget.internshipTitle,
      'internshipId': widget.internshipId,
      'appliedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'cvType': 'built',
      'uploadMethod': 'built',
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your CV'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInfoContainer(),
              _buildPersonalInfoSection(),
              _buildSkillsSection(),
              _buildWorkExperienceSection(),
              _buildEducationSection(),
              _buildLanguagesSection(),
              _buildCoursesSection(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildCategory(
      title: "Personal Information",
      children: [
        _buildTextField("Email", emailController, readOnly: true),
        _buildTextField("GPA (0-4)", gpaController, validator: _validateGPA),
        _buildTextField("National ID", nationalIdController,
            isNationalId: true, validator: _validateNationalId),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return _buildCategory(
      title: "Skills",
      children: [
        _buildTextField("Skills (comma separated)", skillsController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
      ],
    );
  }

  Widget _buildWorkExperienceSection() {
    return _buildCategory(
      title: "Work Experience",
      children: [
        for (int i = 0; i < workExperiences.length; i++)
          _buildExperienceFields(workExperiences[i], i),
        _buildAddButton(
          text: "+ Add Work Experience",
          onPressed: () => setState(() => workExperiences.add(WorkExperience())),
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return _buildCategory(
      title: "Education",
      children: [
        for (int i = 0; i < educations.length; i++)
          _buildEducationFields(educations[i], i),
        _buildAddButton(
          text: "+ Add Education",
          onPressed: () => setState(() => educations.add(Education())),
        ),
      ],
    );
  }

  Widget _buildLanguagesSection() {
    return _buildCategory(
      title: "Languages",
      children: [
        for (int i = 0; i < languages.length; i++)
          _buildLanguageFields(languages[i], i),
        _buildAddButton(
          text: "+ Add Language",
          onPressed: () => setState(() => languages.add(Language())),
        ),
      ],
    );
  }

  Widget _buildCoursesSection() {
    return _buildCategory(
      title: "Courses & Certificates",
      children: [
        for (int i = 0; i < courses.length; i++)
          _buildCourseFields(courses[i], i),
        _buildAddButton(
          text: "+ Add Course",
          onPressed: () => setState(() => courses.add(Course())),
        ),
      ],
    );
  }

  Widget _buildExperienceFields(WorkExperience exp, int index) {
    return Column(
      children: [
        _buildTextField("Job Title", exp.jobTitleController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildTextField("Company Name", exp.companyNameController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildDropdownFormField(
          value: exp.jobType,
          items: const ['Full-time', 'Part-time', 'Remote', 'Internship'],
          label: 'Job Type',
          onChanged: (value) => setState(() => exp.jobType = value as String? ?? 'Full-time'),
        ),
        _buildDateField("Start Date", exp.startDateController),
        _buildDateField("End Date", exp.endDateController),
        if (workExperiences.length > 1)
          _buildDeleteButton(() => setState(() => workExperiences.removeAt(index))),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEducationFields(Education edu, int index) {
    return Column(
      children: [
        _buildTextField("Degree", edu.degreeController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildTextField("University", edu.universityController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildTextField("Major", edu.majorController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildDateField("Start Date", edu.startDateController),
        _buildDateField("End Date (or expected)", edu.endDateController),
        if (educations.length > 1)
          _buildDeleteButton(() => setState(() => educations.removeAt(index))),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLanguageFields(Language lang, int index) {
    return Column(
      children: [
        _buildTextField("Language", lang.languageController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildDropdownFormField(
          value: lang.level,
          items: const ['Beginner', 'Intermediate', 'Advanced', 'Native'],
          label: 'Proficiency Level',
          onChanged: (value) => setState(() => lang.level = value as String? ?? 'Beginner'),
        ),
        if (languages.length > 1)
          _buildDeleteButton(() => setState(() => languages.removeAt(index))),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCourseFields(Course course, int index) {
    return Column(
      children: [
        _buildTextField("Course/Certificate Name", course.courseNameController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildTextField("Institution", course.companyNameController,
            validator: (value) => value?.isEmpty ?? true ? "This field is required" : null),
        _buildTextField("Duration (e.g. 3 months)", course.durationController),
        _buildDateField("Start Date", course.startDateController),
        _buildDateField("End Date", course.endDateController),
        if (courses.length > 1)
          _buildDeleteButton(() => setState(() => courses.removeAt(index))),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool isNationalId = false,
        bool readOnly = false,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: validator,
        keyboardType: isNationalId ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey[100] : Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  String? _validateGPA(String? value) {
    if (value == null || value.isEmpty) return "GPA is required";
    final gpa = double.tryParse(value);
    if (gpa == null) return "Enter a valid number";
    if (gpa < 0 || gpa > 4) return "GPA must be between 0 and 4";
    return null;
  }

  String? _validateNationalId(String? value) {
    if (value == null || value.isEmpty) return "National ID is required";
    if (value.length != 14) return "National ID must be 14 digits";
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Must contain numbers only";
    return null;
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: AbsorbPointer(
        child: _buildTextField(
          label,
          controller,
          readOnly: true,
          validator: (value) => value?.isEmpty ?? true ? "This field is required" : null,
        ),
      ),
    );
  }

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
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item.toString()),
        )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) => value == null ? "This field is required" : null,
      ),
    );
  }

  Widget _buildDeleteButton(VoidCallback onPressed) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildAddButton({required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.blue)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _isLoading ? null : saveCV,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2252A1),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Submit Application",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Applying for: ${widget.internshipTitle}\n'
                  'Please fill all required fields carefully.',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue,
          ),
        ),
        children: children,
      ),
    );
  }
}

class WorkExperience {
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

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
  String level = 'Beginner';
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

class Education {
  final degreeController = TextEditingController();
  final universityController = TextEditingController();
  final majorController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  void dispose() {
    degreeController.dispose();
    universityController.dispose();
    majorController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}