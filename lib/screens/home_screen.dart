import 'package:auth/utils/constants/custom_text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/constants/custom_sizes.dart';
import '../widgets/custom_button.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomText.home),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CustomText.welcomeBack,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: CustomSize.sm),
                    Text(
                      user?.fullName ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: CustomSize.xs),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CustomSize.xl),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: user?.isEmailVerified == true
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: user?.isEmailVerified == true
                        ? Colors.green[200]!
                        : Colors.orange[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      user?.isEmailVerified == true
                          ? Icons.verified_user
                          : Icons.warning_amber,
                      color: user?.isEmailVerified == true
                          ? Colors.green[600]
                          : Colors.orange[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.isEmailVerified == true
                                ? CustomText.accountVerified
                                : CustomText.emailNotVerified,
                            style: TextStyle(
                              color: user?.isEmailVerified == true
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user?.isEmailVerified == true
                                ? CustomText.emailVerifiedAndSecure
                                : CustomText.verifyEmailForFullAccess,
                            style: TextStyle(
                              color: user?.isEmailVerified == true
                                  ? Colors.green[600]
                                  : Colors.orange[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: CustomSize.xl),

              Text(
                CustomText.quickAction,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: CustomSize.md),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.person,
                    title: CustomText.profile,
                    subtitle: CustomText.viewAndEditProfile,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.settings,
                    title: CustomText.settings,
                    subtitle: CustomText.appPreference,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(CustomText.settingSoon)),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.security,
                    title: CustomText.security,
                    subtitle: CustomText.passwordAndSecurity,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(CustomText.securitySettingSoon)),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.help,
                    title: CustomText.help,
                    subtitle: CustomText.supportAndFaq,
                    onTap: () {
                      // Navigate to help
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(CustomText.helpSettingSoon)),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),

              CustomButton(
                text: CustomText.signOut,
                onPressed: () => _showSignOutDialog(context, ref),
                backgroundColor: Colors.red,
                textColor: Colors.white,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(CustomText.signOut),
          content: const Text(CustomText.signOutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                CustomText.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              child: const Text(
                CustomText.signOut,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

