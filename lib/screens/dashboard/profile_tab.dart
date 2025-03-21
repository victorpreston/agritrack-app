import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_profile.dart';
import '../../models/farm.dart';
import '../../models/crop.dart';
import '../../services/profile_service.dart';
import '../../services/farm_service.dart';
import '../../services/crop_service.dart';
import '../../widgets/notification_banner.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final UserProfileService _profileService = UserProfileService();
  final FarmService _farmService = FarmService();
  final CropService _cropService = CropService();
  final ImagePicker _imagePicker = ImagePicker();

  UserProfile? _profile;
  Farm? _farm;
  List<Crop> _crops = [];
  bool _loading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      showNotificationBanner(context, 'Not authenticated');
      return;
    }

    final profile = await _profileService.getUserProfile(userId, context);
    Farm? farm;
    List<Crop> crops = [];

    if (profile != null) {
      farm = await _farmService.getFarm(profile.farmId, context);
      crops = await _cropService.getCropsByFarm(profile.farmId, context);
    }

    setState(() {
      _profile = profile;
      _farm = farm;
      _crops = crops;
      _loading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() => _isUploading = true);

      // Upload the file to Supabase Storage
      final userId = _supabase.auth.currentUser!.id;
      final fileExt = image.path.split('.').last;
      final fileName = 'profile_$userId.$fileExt';
      final filePath = 'profiles/$fileName';

      final imageFile = File(image.path);
      await _supabase.storage.from('profile-pictures').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      // Get the public URL
      final imageUrl = _supabase.storage.from('profile-pictures').getPublicUrl(filePath);

      // Update profile with new image URL
      if (_profile != null) {
        final updatedProfile = UserProfile(
          id: _profile!.id,
          fullName: _profile!.fullName,
          email: _profile!.email,
          phone: _profile!.phone,
          profilePicture: imageUrl,
          memberSince: _profile!.memberSince,
          subscription: _profile!.subscription,
          farmId: _profile!.farmId,
        );

        await _profileService.updateUserProfile(updatedProfile, context);

        setState(() {
          _profile = updatedProfile;
          _isUploading = false;
        });
      }
    } catch (error) {
      setState(() => _isUploading = false);
      showNotificationBanner(context, 'Failed to update profile picture');
    }
  }

  void _showProfileEditSheet() {
    if (_profile == null) return;

    final fullNameController = TextEditingController(text: _profile!.fullName);
    final emailController = TextEditingController(text: _profile!.email);
    final phoneController = TextEditingController(text: _profile!.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                InkWell(
                  onTap: _pickAndUploadImage,
                  child: Row(
                    children: [
                      const Icon(Icons.photo_camera),
                      const SizedBox(width: 8),
                      Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updatedProfile = UserProfile(
                    id: _profile!.id,
                    fullName: fullNameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    profilePicture: _profile!.profilePicture,
                    memberSince: _profile!.memberSince,
                    subscription: _profile!.subscription,
                    farmId: _profile!.farmId,
                  );

                  await _profileService.updateUserProfile(updatedProfile, context);
                  Navigator.pop(context);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFarmEditSheet() {
    if (_farm == null) return;

    final nameController = TextEditingController(text: _farm!.name);
    final locationController = TextEditingController(text: _farm!.location);
    final areaController = TextEditingController(text: _farm!.totalArea);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Farm Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Farm Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(
                labelText: 'Total Area',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updatedFarm = Farm(
                    id: _farm!.id,
                    name: nameController.text,
                    location: locationController.text,
                    totalArea: areaController.text,
                    ownerId: _farm!.ownerId,
                  );

                  await _farmService.updateFarm(updatedFarm, context);
                  Navigator.pop(context);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCropManagementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Crops',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Your Crops',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _crops.length,
                itemBuilder: (context, index) {
                  final crop = _crops[index];
                  return Card(
                    child: ListTile(
                      title: Text(crop.name),
                      subtitle: Text('Type: ${crop.type}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditCropSheet(crop),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAddCropSheet(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Add New Crop'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditCropSheet(Crop crop) {
    final nameController = TextEditingController(text: crop.name);
    final typeController = TextEditingController(text: crop.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Crop',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Crop Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updatedCrop = Crop(
                    id: crop.id,
                    name: nameController.text,
                    type: typeController.text,
                    farmId: crop.farmId,
                  );

                  await _cropService.updateCrop(updatedCrop, context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddCropSheet() {
    if (_profile == null || _profile!.farmId.isEmpty) return;

    final nameController = TextEditingController();
    final typeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Crop',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Crop Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newCrop = Crop(
                    name: nameController.text,
                    type: typeController.text,
                    farmId: _profile!.farmId,
                  );

                  await _cropService.addCrop(newCrop, context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Add Crop'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAccountEditSheet() {
    if (_profile == null) return;

    final emailController = TextEditingController(text: _profile!.email);
    final phoneController = TextEditingController(text: _profile!.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Account Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updatedProfile = UserProfile(
                    id: _profile!.id,
                    fullName: _profile!.fullName,
                    email: emailController.text,
                    phone: phoneController.text,
                    profilePicture: _profile!.profilePicture,
                    memberSince: _profile!.memberSince,
                    subscription: _profile!.subscription,
                    farmId: _profile!.farmId,
                  );

                  await _profileService.updateUserProfile(updatedProfile, context);
                  Navigator.pop(context);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profile == null) {
      return const Center(child: Text('Profile not found'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Farm Information'),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              [
                _buildInfoItem('Farm Name', _farm?.name ?? 'N/A'),
                _buildInfoItem('Location', _farm?.location ?? 'N/A'),
                _buildInfoItem('Total Area', _farm?.totalArea ?? 'N/A'),
                _buildInfoItem('Crops', _crops.map((e) => e.name).join(', ')),
              ],
              onEdit: _farm != null ? _showFarmEditSheet : null,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Crops'),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              _crops.isEmpty
                  ? [_buildInfoItem('No crops', 'Add your first crop')]
                  : _crops.map((crop) => _buildInfoItem(crop.name, crop.type)).toList(),
              onEdit: _showCropManagementSheet,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Account Information'),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              [
                _buildInfoItem('Email', _profile!.email),
                _buildInfoItem('Phone', _profile!.phone),
                _buildInfoItem('Member Since', _profile!.memberSince.split('T').first),
                _buildInfoItem('Subscription', _profile!.subscription),
              ],
              onEdit: _showAccountEditSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final initials = _profile!.fullName.isNotEmpty
        ? _profile!.fullName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join()
        .substring(0, min(2, _profile!.fullName.isNotEmpty ?
    _profile!.fullName.split(' ').where((e) => e.isNotEmpty).length : 0))
        : 'U';

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profile!.profilePicture.isNotEmpty
                  ? NetworkImage(_profile!.profilePicture)
                  : null,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: _profile!.profilePicture.isEmpty
                  ? Text(
                initials,
                style: const TextStyle(fontSize: 32, color: Colors.white),
              )
                  : null,
            ),
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _profile!.fullName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          _crops.isNotEmpty
              ? _crops.map((e) => e.type).toSet().join(', ') + ' Farmer'
              : 'No crops listed',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _showProfileEditSheet,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children, {VoidCallback? onEdit}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (onEdit != null)
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Helper function for initials generation
  int min(int a, int b) => a < b ? a : b;
}