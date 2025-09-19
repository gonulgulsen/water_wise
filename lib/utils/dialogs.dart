import 'package:flutter/material.dart';

void showSuccessDialog(
    BuildContext context,
    String message, {
      VoidCallback? onOk,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFf5fde8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      color: Color(0xFF3c5070),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onOk != null) onOk();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3c5070),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Color(0xFFf5fde8)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              child: CircleAvatar(
                backgroundColor: const Color(0xFF3c5070),
                radius: 28,
                child: const Icon(
                  Icons.check,
                  color: Color(0xFFf5fde8),
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      );
    },
  ).then((_) {
    if (onOk != null) onOk();
  });
}
