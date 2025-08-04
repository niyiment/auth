
import 'package:auth/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
});

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error && errorMessage != null;
  bool get isEmailNotVerified => status == AuthStatus.emailNotVerified;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
    bool clearUser =false
}) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : ( user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, errorMessage: $errorMessage, isLoading: $isLoading)';
  }

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
    other.status == status &&
    other.user == user &&
    other.errorMessage == errorMessage &&
    other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return status.hashCode ^
    user.hashCode ^
    errorMessage.hashCode ^
    isLoading.hashCode;
  }
}

