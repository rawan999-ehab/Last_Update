import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

class CourseUploadPage extends StatefulWidget {
  const CourseUploadPage({Key? key}) : super(key: key);

  @override
  _CourseUploadPageState createState() => _CourseUploadPageState();
}

class _CourseUploadPageState extends State<CourseUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseDescriptionController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _companyLinkController = TextEditingController();
  final _companyContactController = TextEditingController();

  XFile? _courseImage;
  XFile? _companyLogo;
  List<XFile> _roadmapImages = [];
  XFile? _videoFile;

  String? _selectedCategory;
  String? _selectedLevel;

  final List<String> _categories = [
    'برمجة',
    'تصميم',
    'تسويق',
    'إدارة',
    'علوم البيانات',
    'ذكاء اصطناعي'
  ];

  final List<String> _levels = [
    'مبتدئ',
    'متوسط',
    'متقدم'
  ];

  List<Map<String, dynamic>> _companies = [];

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    _companyLinkController.dispose();
    _companyContactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _courseImage = XFile(result.files.single.path!);
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _courseImage = pickedFile;
        });
      }
    }
  }

  Future<void> _pickCompanyLogo() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _companyLogo = XFile(result.files.single.path!);
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _companyLogo = pickedFile;
        });
      }
    }
  }

  Future<void> _pickRoadmapImages() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          _roadmapImages = result.files.map((file) => XFile(file.path!)).toList();
        });
      }
    } else {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _roadmapImages = pickedFiles;
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _videoFile = XFile(result.files.single.path!);
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _videoFile = pickedFile;
        });
      }
    }
  }

  Future<String> _uploadFile(XFile file, String bucketName) async {
    final fileExtension = path.extension(file.path); // import 'package:path/path.dart' as path;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    final fileBytes = await file.readAsBytes();

    await _supabase.storage.from(bucketName).uploadBinary(fileName, fileBytes);

    return _supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  void _addCompany() {
    if (_companyNameController.text.isEmpty) return;

    setState(() {
      _companies.add({
        'name': _companyNameController.text,
        'description': _companyDescriptionController.text,
        'link': _companyLinkController.text,
        'contact': _companyContactController.text,
        'logo': _companyLogo,
      });

// Clear fields
      _companyNameController.clear();
      _companyDescriptionController.clear();
      _companyLinkController.clear();
      _companyContactController.clear();
      _companyLogo = null;
    });
  }

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_courseImage == null || _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة صورة الكورس والفيديو')),
      );
      return;
    }

    try {
// Upload files to Supabase
      final imageUrl = await _uploadFile(_courseImage!, 'course-images');
      final videoUrl = await _uploadFile(_videoFile!, 'course-videos');

      List<String> roadmapUrls = [];
      for (var image in _roadmapImages) {
        final url = await _uploadFile(image, 'roadmap-images');
        roadmapUrls.add(url);
      }

// Upload course data
      final courseResponse = await _supabase.from('courses').insert({
        'name': _courseNameController.text,
        'description': _courseDescriptionController.text,
        'image_url': imageUrl,
        'video_url': videoUrl,
        'roadmap_images': roadmapUrls,
        'category': _selectedCategory,
        'level': _selectedLevel,
      }).select();

      if (courseResponse.isEmpty) throw Exception('Failed to create course');

      final courseId = courseResponse.first['id'];

// Upload companies data
      for (var company in _companies) {
        String? logoUrl;
        if (company['logo'] != null) {
          logoUrl = await _uploadFile(company['logo'] as XFile, 'company-logos');
        }

        await _supabase.from('companies').insert({
          'course_id': courseId,
          'name': company['name'],
          'description': company['description'],
          'link': company['link'],
          'contact': company['contact'],
          'logo_url': logoUrl,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع الكورس بنجاح!')),
      );

// Reset form
      _formKey.currentState!.reset();
      setState(() {
        _courseImage = null;
        _videoFile = null;
        _roadmapImages = [];
        _companies = [];
      });
    } catch (e) {
      debugPrint('حدث خطأ: ${e.toString()}');
    }
  }

  Widget _buildImagePreview(XFile? file) {
    if (file == null) return const SizedBox.shrink();

    if (kIsWeb) {
      return Image.network(
        file.path,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(file.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildVideoPreview(XFile? file) {
    if (file == null) return const SizedBox.shrink();

    return const Icon(Icons.video_library, size: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع كورس جديد'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// الجزء الأول: بيانات الكورس
              const Text(
                'بيانات الكورس',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

// اسم الكورس
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الكورس',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال اسم الكورس';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

// وصف الكورس
              TextFormField(
                controller: _courseDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف الكورس',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال وصف الكورس';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

// صورة الكورس
              const Text('صورة الكورس:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('اختر صورة'),
                  ),
                  const SizedBox(width: 16),
                  if (_courseImage != null)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildImagePreview(_courseImage),
                    ),
                ],
              ),
              const SizedBox(height: 16),

// فيديو الكورس
              const Text('فيديو الكورس:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickVideo,
                    child: const Text('اختر فيديو'),
                  ),
                  const SizedBox(width: 16),
                  if (_videoFile != null)
                    _buildVideoPreview(_videoFile),
                ],
              ),
              const SizedBox(height: 16),

// Roadmap
              const Text('صور Roadmap:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickRoadmapImages,
                child: const Text('اختر صور Roadmap'),
              ),
              const SizedBox(height: 8),
              if (_roadmapImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _roadmapImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildImagePreview(_roadmapImages[index]),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

// التصنيف
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'يجب اختيار تصنيف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

// مستوى الكورس
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'مستوى الكورس',
                  border: OutlineInputBorder(),
                ),
                value: _selectedLevel,
                items: _levels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value;
                  });
                },
              ),
              const SizedBox(height: 32),

// الجزء الثاني: الشركات المقدمة للكورس
              const Text(
                'الشركات المقدمة للكورس',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

// اسم الشركة
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الشركة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

// وصف مختصر للشركة
              TextFormField(
                controller: _companyDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف مختصر',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

// رابط الشركة
              TextFormField(
                controller: _companyLinkController,
                decoration: const InputDecoration(
                  labelText: 'رابط الشركة',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

// وسيلة تواصل
              TextFormField(
                controller: _companyContactController,
                decoration: const InputDecoration(
                  labelText: 'وسيلة تواصل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

// شعار الشركة
              const Text('شعار الشركة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickCompanyLogo,
                    child: const Text('اختر شعار'),
                  ),
                  const SizedBox(width: 16),
                  if (_companyLogo != null)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildImagePreview(_companyLogo),
                    ),
                ],
              ),
              const SizedBox(height: 16),

// زر إضافة شركة
              Center(
                child: ElevatedButton(
                  onPressed: _addCompany,
                  child: const Text('إضافة شركة'),
                ),
              ),
              const SizedBox(height: 16),

// قائمة الشركات المضافة
              if (_companies.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الشركات المضافة:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _companies.length,
                      itemBuilder: (context, index) {
                        final company = _companies[index];
                        return Card(
                          child: ListTile(
                            leading: company['logo'] != null
                                ? Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _buildImagePreview(company['logo']),
                            )
                                : const Icon(Icons.business),
                            title: Text(company['name']),
                            subtitle: Text(company['description'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _companies.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 32),

// زر رفع الكورس
              Center(
                child: ElevatedButton(
                  onPressed: _submitCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('رفع الكورس', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}