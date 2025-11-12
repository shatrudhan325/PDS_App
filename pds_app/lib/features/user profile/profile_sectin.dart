import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSectionApp extends StatelessWidget {
  const ProfileSectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Section',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.foreground,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
      home: UserProfileScreen(
        initialProfile: UserProfile(
          name: 'Bock Engineer',
          phone: '9999999999',
          email: 'blockengineer@email.com',
          about:
              'Product Manager at Trinetra with 5+ years of experience in mobile app development and user experience design.',
          imageUrl: 'pds_app/assets/images/i.avif56',
        ),
        onSave: (profile) {
          print('Profile saved: ${profile.toJson()}');
        },
        onHelpCenter: () {
          print('Help Center tapped');
        },
        onSettings: () {
          print('Settings tapped');
        },
        onEditPhoto: () {
          print('Edit photo tapped');
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 🔥 DATA MODEL
class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String about;
  final String? imageUrl;

  UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.about,
    this.imageUrl,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? about,
    String? imageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      about: about ?? this.about,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'about': about,
      'imageUrl': imageUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      about: json['about'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

// 🔥 CONSTANTS & DESIGN SYSTEM
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF030213);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryForeground = Colors.white;

  // Background Colors
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8F9FA);
  static const Color card = Colors.white;

  // Text Colors
  static const Color foreground = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);
  static const Color mutedForeground = Color(0xFF9CA3AF);

  // Border & Input Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color inputBackground = Color(0xFFF3F4F6);

  // Accent Colors
  static const Color accent = Color(0xFFE9EBF0);
  static const Color accentForeground = Color(0xFF030213);

  // Status Colors
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFDBEAFE);
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFD1FAE5);
  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeLight = Color(0xFFFEF3C7);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
}

class AppDimensions {
  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;

  // Component Sizes
  static const double avatarSize = 128.0;
  static const double inputHeight = 48.0;
  static const double buttonHeight = 44.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;

  // Touch Targets
  static const double minTouchTarget = 48.0;
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.foreground,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedForeground,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForeground,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

// 🔥 REUSABLE COMPONENTS

// Profile Header Component
class ProfileHeader extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final VoidCallback? onEditPhoto;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const ProfileHeader({
    super.key,
    this.imageUrl,
    required this.initials,
    this.onEditPhoto,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User Avatar with Edit Button
        Stack(
          children: [
            CircleAvatar(
              radius: AppDimensions.avatarSize / 2,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : null,
              child: imageUrl == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onEditPhoto,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingL),

        // Edit Profile Toggle Button
        SizedBox(
          width: 160,
          height: AppDimensions.buttonHeight,
          child: ElevatedButton(
            onPressed: onToggleEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEditing
                  ? AppColors.primary
                  : Colors.transparent,
              foregroundColor: isEditing
                  ? AppColors.primaryForeground
                  : AppColors.primary,
              elevation: 0,
              side: isEditing
                  ? null
                  : const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            child: Text(
              isEditing ? 'Save Changes' : 'Edit Profile',
              style: AppTextStyles.button,
            ),
          ),
        ),
      ],
    );
  }
}

// Profile Input Field Component
class ProfileInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final ValueChanged<String>? onChanged;
  final bool isEditable;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? placeholder;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    this.onChanged,
    required this.isEditable,
    this.keyboardType,
    this.maxLines = 1,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with Icon
        Row(
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSizeSmall,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Text(label, style: AppTextStyles.label),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingS),

        // Input Field or Display Container
        if (isEditable)
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: TextFormField(
              initialValue: value,
              onChanged: onChanged,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.mutedForeground,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: maxLines != null && maxLines! > 1
                      ? AppDimensions.paddingM
                      : AppDimensions.paddingM,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: maxLines != null && maxLines! > 1
                  ? 100
                  : AppDimensions.inputHeight,
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppTextStyles.body),
            ),
          ),
      ],
    );
  }
}

// Action List Tile Component
class ActionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const ActionListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, AppColors.accent.withOpacity(0.3)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColors.blueLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    icon,
                    size: AppDimensions.iconSize,
                    color: iconColor ?? AppColors.blue,
                  ),
                ),

                const SizedBox(width: AppDimensions.paddingM),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.subtitle),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ),

                // Chevron Icon
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔥 MAIN USER PROFILE SCREEN
class UserProfileScreen extends StatefulWidget {
  final UserProfile initialProfile;
  final Function(UserProfile)? onSave;
  final VoidCallback? onHelpCenter;
  final VoidCallback? onSettings;
  final VoidCallback? onEditPhoto;

  const UserProfileScreen({
    super.key,
    required this.initialProfile,
    this.onSave,
    this.onHelpCenter,
    this.onSettings,
    this.onEditPhoto,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _aboutController;

  bool _isEditing = true;
  late UserProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.initialProfile;
    _nameController = TextEditingController(text: _currentProfile.name);
    _phoneController = TextEditingController(text: _currentProfile.phone);
    _emailController = TextEditingController(text: _currentProfile.email);
    _aboutController = TextEditingController(text: _currentProfile.about);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _saveProfile() {
    final updatedProfile = _currentProfile.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      about: _aboutController.text,
    );

    setState(() {
      _currentProfile = updatedProfile;
      _isEditing = true;
    });

    widget.onSave?.call(updatedProfile);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  String _getInitials() {
    final nameParts = _currentProfile.name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
          onPressed: () => Get.back(),
        ),
        title: const Text('Profile', style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.foreground),
            onPressed: widget.onSettings,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            // Profile Header Section
            ProfileHeader(
              // FIX: Use the dynamic imageUrl from the current profile state
              imageUrl: _currentProfile.imageUrl,
              initials: _getInitials(),
              isEditing: _isEditing,
              onToggleEdit: _toggleEdit,
              onEditPhoto: widget.onEditPhoto,
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Information Fields Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.border),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.card, AppColors.accent.withOpacity(0.3)],
                ),
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  // Name Field
                  ProfileInputField(
                    label: 'Name',
                    icon: Icons.person,
                    value: _currentProfile.name,
                    isEditable: _isEditing,
                    onChanged: (value) => _nameController.text = value,
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Phone Field
                  ProfileInputField(
                    label: 'Phone',
                    icon: Icons.phone,
                    value: _currentProfile.phone,
                    isEditable: _isEditing,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _phoneController.text = value,
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Email Field
                  ProfileInputField(
                    label: 'Email',
                    icon: Icons.email,
                    value: _currentProfile.email,
                    isEditable: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _emailController.text = value,
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // About Me Field
                  ProfileInputField(
                    label: 'About me',
                    icon: Icons.description,
                    value: _currentProfile.about,
                    isEditable: _isEditing,
                    maxLines: 4,
                    placeholder: 'Tell us about yourself...',
                    onChanged: (value) => _aboutController.text = value,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Action/Navigation Section
            ActionListTile(
              icon: Icons.help_center,
              title: 'Help Center',
              subtitle: 'Get support and answers',
              iconColor: AppColors.blue,
              iconBackgroundColor: AppColors.blueLight,
              onTap: widget.onHelpCenter,
            ),

            // Save Button - Only visible when editing
            if (_isEditing) ...[
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.inputHeight,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],

            // Bottom padding for scroll
            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ),
    );
  }
}
