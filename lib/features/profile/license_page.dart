import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/core/theme/app_colors.dart';
import '/core/widgets/auth_button.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({super.key});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {

  final picker = ImagePicker();

  File? front;
  File? back;

  Future<void> pickFront() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) setState(() => front = File(img.path));
  }

  Future<void> pickBack() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) setState(() => back = File(img.path));
  }

  /// 🔌 API READY
  Future<void> submitLicense() async {

    /// TODO API
    /// ApiService.uploadLicense(front, back)

    print("License uploaded");
  }

  Widget imageBox(File? file, VoidCallback tap, String text) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.input,
          borderRadius: BorderRadius.circular(16),
        ),
        child: file == null
            ? Center(child: Text(text))
            : ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(file,fit: BoxFit.cover),
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

              Row(
                children: const [
                  BackButton(),
                  SizedBox(width: 10),
                  Text("Driver’s License",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold))
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "For verification, please photograph both sides of your driver's license.",
                style: TextStyle(color: AppColors.greyText),
              ),

              const SizedBox(height: 20),

              const Text("FRONT SIDE"),
              const SizedBox(height: 8),

              imageBox(front, pickFront, "Tap to photograph front side"),

              const SizedBox(height: 20),

              const Text("BACK SIDE"),
              const SizedBox(height: 8),

              imageBox(back, pickBack, "Tap to photograph back side"),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Your photos are encrypted and stored securely. They are used solely for identity verification.",
                  style: TextStyle(fontSize: 13),
                ),
              ),

              const SizedBox(height: 25),

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