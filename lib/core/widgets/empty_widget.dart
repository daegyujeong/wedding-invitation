import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onRefresh;

  const EmptyWidget({
    super.key,
    required this.message,
    this.icon,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.info_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('새로고침'),
            ),
          ],
        ],
      ),
    );
  }
}
