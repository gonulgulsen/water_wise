import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FDE8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF3C5070),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onOk != null) onOk();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C5070),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        color: Color(0xFFF5FDE8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: -60,
              child: SizedBox(
                height: 120,
                width: 120,
                child: Lottie.network(
                  "https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json",
                  repeat: false,
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
