import 'dart:ui';

import 'package:auth/providers/auth_provider.dart';
import 'package:auth/providers/auth_state.dart';
import 'package:auth/utils/constants/custom_text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../utils/constants/custom_sizes.dart';
import '../utils/validation_utils.dart';
import '../widgets/index.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedPrivacyPolicy = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    ref.read(authProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedPrivacyPolicy) {
      _showErrorSnackBar('Accept the Privacy Policy');
      return;
    }

    final success = await ref.read(authProvider.notifier).registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null
        : _phoneController.text.trim(),
    );

    if (success && mounted) {
      _showSuccessSnackBar('Registration successful! Please verify your email');

      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const EmailVerificationScreen())
      );
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

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.hasError) {
        _showErrorSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.lg, vertical: CustomSize.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: CustomSize.lg),
                  Text(
                    CustomText.registerTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CustomSize.md),
                  Text(
                    CustomText.registerSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: CustomSize.lg),

                  CustomTextField(
                    controller: _firstNameController,
                    label: CustomText.firstName,
                    prefixIcon: Iconsax.user,
                    validator: (value) => ValidationUtils.nameValidator(
                      value,
                      fieldName: CustomText.firstName,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: _lastNameController,
                    label: CustomText.lastName,
                    prefixIcon: Iconsax.user,
                    validator: (value) => ValidationUtils.nameValidator(
                      value,
                      fieldName: CustomText.lastName,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: _emailController,
                    label: CustomText.email,
                    prefixIcon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationUtils.emailValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: _phoneController,
                    label: '${CustomText.phone} (Optional)',
                    prefixIcon: Iconsax.call,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        return ValidationUtils.phoneNumberValidator(value);
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: _passwordController,
                    label: CustomText.password,
                    prefixIcon: Iconsax.lock,
                    obscureText: _obscurePassword,
                    validator: ValidationUtils.passwordValidator,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Iconsax.eye : Iconsax.eye_slash),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: CustomSize.md),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: CustomText.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => ValidationUtils.confirmPasswordValidator(
                      value,
                      _passwordController.text,
                    ),
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: CustomSize.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedPrivacyPolicy,
                        onChanged: (value) => setState(() => _acceptedPrivacyPolicy = value ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _acceptedPrivacyPolicy = !_acceptedPrivacyPolicy,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Term of Service',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CustomSize.lg,),

                  CustomButton(
                    text: CustomText.signUp,
                    onPressed: _registerUser,
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: CustomSize.lg,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        CustomText.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          CustomText.signIn,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CustomSize.lg,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
