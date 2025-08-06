import 'package:auth/utils/constants/custom_text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/auth_provider.dart';
import '../utils/constants/custom_sizes.dart';
import '../utils/validation_utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(authProvider.notifier).sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        _emailSent = true;
      });
      _showSuccessSnackBar(CustomText.passwordResetEmailSent);
    } else {
      _showErrorSnackBar(CustomText.passwordResetEmailFailed);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomText.resetPassword),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _emailSent ? Iconsax.sms_tracking : Iconsax.lock_circle,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: CustomSize.xl),

                Text(
                  _emailSent ? CustomText.checkEmail : CustomText.forgotPassword,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CustomSize.md),

                Text(
                  _emailSent
                      ? '${CustomText.sentPasswordResetLink} ${_emailController.text.trim()}'
                      : CustomText.enterEmail,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CustomSize.xl),

                if (!_emailSent) ...[
                  CustomTextField(
                    controller: _emailController,
                    label: CustomText.email,
                    prefixIcon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationUtils.emailValidator,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: CustomSize.lg),

                  CustomButton(
                    text: CustomText.sendResetLink,
                    onPressed: _handleSendResetEmail,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: CustomSize.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        CustomText.rememberPassword,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[600],
                          size: 48,
                        ),
                        const SizedBox(height: CustomSize.md),
                        Text(
                          CustomText.emailSent,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: CustomSize.sm),
                        Text(
                          CustomText.checkEmailForResetPassword,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: CustomSize.xl),

                  CustomButton(
                    text: CustomText.resendEmail,
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    isOutlined: true,
                  ),
                  const SizedBox(height: CustomSize.md),

                  CustomButton(
                    text: CustomText.backToSignIn,
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    CustomText.checkSpam,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: CustomSize.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


