import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../utils/constants/custom_sizes.dart';
import '../utils/constants/custom_text_strings.dart';
import '../utils/validation_utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(authProvider.notifier).updateUserProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        _isEditing = false;
      });
      _showSuccessSnackBar('Profile updated successfully!');
    } else {
      _showErrorSnackBar('Failed to update profile. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.hasError) {
        _showErrorSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomText.profile),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || authState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CustomSize.lg),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: user?.profileImageUrl != null
                        ? ClipOval(
                      child: Image.network(
                        user!.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarFallback(user);
                        },
                      ),
                    )
                        : _buildAvatarFallback(user),
                  ),
                  const SizedBox(height: CustomSize.lg),

                  Text(
                    user?.fullName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: CustomSize.sm),

                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: CustomSize.sm),

                  // Email verification status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user?.isEmailVerified == true
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user?.isEmailVerified == true
                              ? Icons.verified
                              : Icons.pending,
                          size: 16,
                          color: user?.isEmailVerified == true
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: CustomSize.xs),
                        Text(
                          user?.isEmailVerified == true
                              ? CustomText.verified
                              : CustomText.pendingVerification,
                          style: TextStyle(
                            color: user?.isEmailVerified == true
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: CustomSize.xxl),

                  CustomTextField(
                    controller: _firstNameController,
                    label: CustomText.firstName,
                    prefixIcon: Icons.person_outline,
                    validator: (value) => ValidationUtils.nameValidator(
                      value,
                      fieldName: CustomText.firstName,
                    ),
                    readOnly: !_isEditing,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: _lastNameController,
                    label: CustomText.lastName,
                    prefixIcon: Icons.person_outline,
                    validator: (value) => ValidationUtils.nameValidator(
                      value,
                      fieldName: CustomText.lastName,
                    ),
                    readOnly: !_isEditing,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: TextEditingController(text: user?.email ?? ''),
                    label: CustomText.email,
                    prefixIcon: Icons.email_outlined,
                    readOnly: true,
                    enabled: false,
                  ),

                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: _phoneController,
                    label: '${CustomText.phone} (Optional)',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        return ValidationUtils.phoneNumberValidator(value);
                      }
                      return null;
                    },
                    readOnly: !_isEditing,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: CustomSize.xl),

                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: CustomText.cancel,
                            onPressed: () {
                              _loadUserData();
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: CustomSize.md),
                        Expanded(
                          child: CustomButton(
                            text: CustomText.submit,
                            onPressed: _updateProfile,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    CustomButton(
                      text: CustomText.editProfile,
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: Icons.edit,
                    ),
                  ],
                  const SizedBox(height: CustomSize.lg),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CustomText.accountInfo,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: CustomSize.sm),
                        _buildInfoRow(
                          CustomText.created,
                          user?.createdAt != null
                              ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                              : CustomText.na,
                        ),
                        const SizedBox(height: CustomSize.sm),
                        _buildInfoRow(
                          CustomText.lastUpdated,
                          user?.updatedAt != null
                              ? '${user!.updatedAt.day}/${user.updatedAt.month}/${user.updatedAt.year}'
                              : CustomText.na,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: CustomSize.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(user) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user?.initials ?? 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}

