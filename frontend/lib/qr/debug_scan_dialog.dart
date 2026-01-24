import 'package:flutter/material.dart';
import 'qr.dart';

Future<ScanResult?> showDebugScanDialog(BuildContext context) async {
  final controller = TextEditingController();

  return showDialog<ScanResult>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('DEBUG QR Scan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'qr_token (napr. 1, 2, 3...)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = controller.text.trim();
              if (token.isEmpty) return;

              try {
                final result = await handleScan(context, token);
                Navigator.pop(ctx, result);
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Odoslať'),
          ),
        ],
      );
    },
  );
}
