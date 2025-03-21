import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/farm.dart';
import '../models/crop.dart';
import '../services/user_onboarding_service.dart';
import '../widgets/notification_banner.dart';
import '../screens/dashboard/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // User Information
  final TextEditingController _phoneController = TextEditingController();
  String _profilePicture = '';
  File? _selectedImage;
  String _selectedCountryCode = '+1';
  String _selectedFlag = '🇺🇸';

  // User details from Auth
  String _userEmail = '';
  String _userName = '';

  // Farm Details
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _farmLocationController = TextEditingController();
  final TextEditingController _farmAreaController = TextEditingController();

  // Crop Details
  List<Map<String, String>> _crops = [];

  // Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  // Fetch user details from Supabase Auth
  Future<void> _getUserDetails() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
        // Try to get user's name from user metadata or from email
        _userName = user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String? ??
            _userEmail.split('@').first;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _farmAreaController.dispose();
    super.dispose();
  }

  void _addCrop() {
    setState(() {
      _crops.add({'name': '', 'type': ''});
    });
  }

  void _removeCrop(int index) {
    setState(() {
      _crops.removeAt(index);
    });
  }

  // Select and Upload Image
  Future<void> _pickAndUploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final File file = File(pickedFile.path);
    final String fileName = 'profile_${_supabase.auth.currentUser!.id}.jpg';

    try {
      // First check if the user is authenticated
      if (_supabase.auth.currentUser == null) {
        print('ERROR: User not authenticated');
        showNotificationBanner(context, 'User not authenticated.');
        return;
      }

      // Print debug information
      print('Attempting to upload file:');
      print('File path: ${file.path}');
      print('User ID: ${_supabase.auth.currentUser!.id}');
      print('Bucket name: profile-pictures');
      print('File name: $fileName');

      // Upload with better error handling
      await _supabase.storage.from('profile-pictures').upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String imageUrl = _supabase.storage.from('profile-pictures').getPublicUrl(fileName);
      print('Upload successful. Public URL: $imageUrl');

      setState(() {
        _selectedImage = file;
        _profilePicture = imageUrl;
      });

      showNotificationBanner(context, 'Profile picture uploaded!', isSuccess: true);
    } catch (e) {
      // Detailed error logging
      print('ERROR UPLOADING PROFILE PICTURE:');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');

      if (e is StorageException) {
        print('Storage error code: ${e.statusCode}');
        print('Storage error message: ${e.message}');
        print('Storage error details: ${e.error}');
      }

      // Show the actual error to the user
      showNotificationBanner(context, 'Failed to upload profile picture: ${e.toString()}');
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _supabase.auth.currentUser;
    if (user == null) {
      showNotificationBanner(context, 'User not authenticated. Please log in again.');
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Ensure phone number is complete with country code
      final String fullPhoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}';

      // Check inputs
      if (_farmNameController.text.trim().isEmpty || _farmLocationController.text.trim().isEmpty) {
        Navigator.pop(context); // Remove loading indicator
        showNotificationBanner(context, 'Please fill in all farm details.');
        return;
      }

      if (_crops.isEmpty) {
        Navigator.pop(context); // Remove loading indicator
        showNotificationBanner(context, 'Please add at least one crop.');
        return;
      }

      for (var crop in _crops) {
        final name = crop['name'];
        final type = crop['type'];

        if (name == null || name.isEmpty || type == null || type.isEmpty) {
          Navigator.pop(context); // Remove loading indicator
          showNotificationBanner(context, 'Please fill in all crop details (name and type).');
          return;
        }
      }

      // Create Farm Object (without setting an empty ID)
      final farm = Farm(
        id: '', // This will be assigned by the database
        name: _farmNameController.text.trim(),
        location: _farmLocationController.text.trim(),
        totalArea: _farmAreaController.text.trim(),
        ownerId: user.id,
      );

      // Create Profile Object (without farm ID initially)
      final userProfile = UserProfile(
        id: user.id,
        fullName: _userName,
        email: _userEmail,
        phone: fullPhoneNumber,
        profilePicture: _profilePicture,
        memberSince: DateTime.now().toIso8601String(),
        subscription: 'Free',
        farmId: '', // Will be updated after farm is created
      );

      // Create Crop Objects (without farm ID initially)
      List<Crop> crops = _crops.map((crop) {
        return Crop(
          id: '', // This will be assigned by the database
          name: crop['name']!,
          farmId: '', // Will be updated after farm is created
          type: crop['type']!,
        );
      }).toList();

      // Save Data to Supabase
      final success = await ProfileSetupService().completeProfile(
        userProfile: userProfile,
        farm: farm,
        crops: crops,
        context: context,
      );

      // Remove loading indicator
      if (context.mounted) Navigator.pop(context);

      if (success) {
        showNotificationBanner(context, 'Profile setup completed!', isSuccess: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        showNotificationBanner(context, 'Failed to save profile. Please try again.');
      }
    } catch (e) {
      // Remove loading indicator
      if (context.mounted) Navigator.pop(context);
      print('ERROR IN SUBMIT PROFILE:');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      showNotificationBanner(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildStepperHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepperContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildStepperButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stepIndicator(0, 'Personal'),
        _stepIndicator(1, 'Farm'),
        _stepIndicator(2, 'Crops'),
      ],
    );
  }

  Widget _stepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: isActive ? Colors.green : Colors.grey,
          child: Text('${step + 1}', style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? Colors.green : Colors.grey)),
      ],
    );
  }

  Widget _buildStepperContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
          if (_currentStep == 0) _buildPersonalStep(),
          if (_currentStep == 1) _buildFarmStep(),
          if (_currentStep == 2) _buildCropStep(),
        ],
      ),
    );
  }

  Widget _buildPersonalStep() {
    return Column(
      children: [
        // Display user's name (read-only)
        TextFormField(
          initialValue: _userName,
          readOnly: true,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            helperText: 'Automatically populated from your account',
          ),
        ),
        const SizedBox(height: 16),

        // Display user's email (read-only)
        TextFormField(
          initialValue: _userEmail,
          readOnly: true,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            helperText: 'Automatically populated from your account',
          ),
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code selector
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    setState(() {
                      _selectedCountryCode = '+${country.phoneCode}';
                      _selectedFlag = country.flagEmoji;
                    });
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text("$_selectedFlag $_selectedCountryCode"),
              ),
            ),
            const SizedBox(width: 8.0),
            // Phone number input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickAndUploadProfilePicture,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Upload Profile Picture'),
        ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.file(
                _selectedImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFarmStep() {
    return Column(
      children: [
        TextFormField(
          controller: _farmNameController,
          decoration: const InputDecoration(labelText: 'Farm Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your farm name';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _farmLocationController,
          decoration: const InputDecoration(labelText: 'Location'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your farm location';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _farmAreaController,
          decoration: const InputDecoration(labelText: 'Total Area (acres)'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your farm area';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCropStep() {
    return Column(
      children: [
        if (_crops.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('No crops added yet. Add your first crop below.'),
          ),
        ..._crops.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, String> crop = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: crop['name'],
                    decoration: const InputDecoration(labelText: 'Crop Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a crop name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _crops[index]['name'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: crop['type'],
                    decoration: const InputDecoration(labelText: 'Crop Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a crop type';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _crops[index]['type'] = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeCrop(index),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addCrop,
          icon: const Icon(Icons.add),
          label: const Text('Add Crop'),
        ),
      ],
    );
  }

  Widget _buildStepperButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Back')
            )
          else
            const SizedBox(width: 70), // Placeholder to maintain alignment
          ElevatedButton(
            onPressed: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _submitProfile();
              }
            },
            child: Text(_currentStep < 2 ? 'Next' : 'Submit'),
          ),
        ],
      ),
    );
  }
}