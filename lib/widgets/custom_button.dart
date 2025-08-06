
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
    this.borderRadius = 40,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = backgroundColor ?? theme.primaryColor;
    final onPrimaryColor = textColor ?? Colors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _buildButtonContent(context, primaryColor),
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          elevation: isLoading ? 0 : 2,
          shadowColor: primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _buildButtonContent(context, onPrimaryColor),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Specialized button variants
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.icon,
  });
}

class SecondaryButton extends CustomButton {
  const SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.icon,
  }) : super(
    isOutlined: true,
  );
}

class DangerButton extends CustomButton {
  const DangerButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.icon,
  }) : super(
    backgroundColor: Colors.red,
  );
}
