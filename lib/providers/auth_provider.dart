
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_auth_service.dart';
import 'auth_state.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return AuthNotifier(authService, connectivityService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;
  final ConnectivityService _connectivityService;

  AuthNotifier(this._authService, this._connectivityService)
      : super(const AuthState()) {
    _authService.authStateChanges.listen(_onAuthStateChanged);

    _authService.userChanges.listen(_onUserChanged);
  }

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      );
    } else {
      _loadUserData(user);
    }
  }

  void _onUserChanged(User? user) {
    if (user != null) {
      _loadUserData(user);
    }
  }

  Future<void> _loadUserData(User user) async {
    try {
      final userData = await _authService.getUserDataFromFirestore(user.uid);

      if (userData != null) {
        final updatedUserData = userData.copyWith(
          isEmailVerified: user.emailVerified,
        );

        if (user.emailVerified) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: updatedUserData,
            clearError: true,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.emailNotVerified,
            user: updatedUserData,
            clearError: true,
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'User data not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, isLoading: true);

      final hasInternet = await _connectivityService.hasInternetConnection();
      if (!hasInternet) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'No internet connection. Please check your network and try again.',
          isLoading: false,
        );
        return false;
      }

      final credential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          isEmailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _authService.saveUserDataToFirestore(userModel);

        await _authService.sendEmailVerification();

        state = state.copyWith(
          status: AuthStatus.emailNotVerified,
          user: userModel,
          isLoading: false,
          clearError: true,
        );

        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      await _authService.reloadUser();
      final user = _authService.currentUser;
      if (user != null) {
        _loadUserData(user);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final currentUser = state.user;
      if (currentUser == null) return false;

      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      if (updateData.isNotEmpty) {
        await _authService.updateUserDataInFirestore(currentUser.uid, updateData);

        final updatedUser = currentUser.copyWith(
          firstName: firstName ?? currentUser.firstName,
          lastName: lastName ?? currentUser.lastName,
          phoneNumber: phoneNumber ?? currentUser.phoneNumber,
          profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(user: updatedUser);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
