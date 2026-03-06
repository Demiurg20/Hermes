import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/core/theme/app_colors.dart';
import '/core/widgets/auth_button.dart';

class DriverLicensePage extends StatefulWidget {
  const DriverLicensePage({super.key});

  @override
  State<DriverLicensePage> createState() => _DriverLicensePageState();
}

class _DriverLicensePageState extends State<DriverLicensePage> {

  final ImagePicker picker = ImagePicker();

  File? frontSide;
  File? backSide;

  /// 📸 FRONT IMAGE
  Future<void> pickFront() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        frontSide = File(picked.path);
      });
    }
  }

  /// 📸 BACK IMAGE
  Future<void> pickBack() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        backSide = File(picked.path);
      });
    }
  }

  /// 🔌 API READY
  Future<void> submitLicense() async {

    if (frontSide == null || backSide == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload both sides")),
      );
      return;
    }

    /// TODO: API
    /// ApiService.uploadLicense(frontSide, backSide);

    print("License submitted");

  }

  Widget imageBox(File? image, VoidCallback onTap, String text) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.input,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: image == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, color: AppColors.primary),
              SizedBox(height: 8),
              Text("Tap to photograph"),
            ],
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [

              /// HEADER
              Row(
                children: const [
                  BackButton(),
                  SizedBox(width: 10),
                  Text(
                    "Driver’s License",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                "Step 2 of 2",
                style: TextStyle(color: AppColors.greyText),
              ),

              const SizedBox(height: 20),

              const Text(
                "For verification, please photograph both sides of your driver's license. This is required to complete your registration.",
                style: TextStyle(color: AppColors.greyText),
              ),

              const SizedBox(height: 25),

              /// FRONT SIDE
              const Text("FRONT SIDE"),

              const SizedBox(height: 10),

              imageBox(frontSide, pickFront, "Tap to photograph front side"),

              const SizedBox(height: 25),

              /// BACK SIDE
              const Text("BACK SIDE"),

              const SizedBox(height: 10),

              imageBox(backSide, pickBack, "Tap to photograph back side"),

              const SizedBox(height: 25),

              /// INFO BOX
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [

                    Icon(Icons.info_outline, color: AppColors.primary),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "Your photos are encrypted and stored securely. They are used solely for identity verification and will not be shared with third parties.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// BUTTON
              AuthButton(
                text: "Complete Registration",
                onPressed: submitLicense,
              )
            ],
          ),
        ),
      ),
    );
  }
}