import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? text;
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.text,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 8),
          Text(
            text!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
