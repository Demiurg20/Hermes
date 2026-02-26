import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:hermes/core/theme/app_colors.dart';
import 'package:hermes/core/widgets/auth_button.dart';
import '/core/api/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final api = ApiService();

  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final personalNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();

  DateTime? dateOfBirth;
  DateTime? dateOfGetLicense;
  DateTime? dateOfEndLicense;

  String gender = "Male";
  String category = "B";

  File? imageFile;

  bool isLoading = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> pickDate(Function(DateTime) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        onSelected(picked);
      });
    }
  }

  Future<void> saveProfile() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {

      FormData formData = FormData.fromMap({
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "phone": phoneController.text.trim(),
        "personalNumber": personalNumberController.text.trim(),
        "licenseNumber": licenseNumberController.text.trim(),
        "gender": gender,
        "categoryOfLicense": category,
        "dateOfBirth": dateOfBirth?.toIso8601String(),
        "dateOfGetDriverLicense": dateOfGetLicense?.toIso8601String(),
        "dateOfEndDriverLicense": dateOfEndLicense?.toIso8601String(),
        if (imageFile != null)
          "image": await MultipartFile.fromFile(
            imageFile!.path,
            filename: "profile.jpg",
          ),
      });

      await api.dio.post(
        "/profile", // ← ВСТАВИШЬ СВОЙ ENDPOINT
        data: formData,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save profile")),
      );
    }

    setState(() => isLoading = false);
  }

  Widget buildDateField(String title, DateTime? value, Function(DateTime) onSelected) {
    return GestureDetector(
      onTap: () => pickDate(onSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.input,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null ? title : value.toLocal().toString().split(' ')[0],
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: AppColors.greyText),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.input,
                  backgroundImage:
                  imageFile != null ? FileImage(imageFile!) : null,
                  child: imageFile == null
                      ? const Icon(Icons.camera_alt,
                      color: AppColors.greyText)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              buildTextField("First Name", firstNameController),
              buildTextField("Last Name", lastNameController),
              buildTextField("Phone", phoneController),
              buildTextField("Personal Number", personalNumberController),
              buildTextField("License Number", licenseNumberController),

              const SizedBox(height: 15),

              buildDateField("Date of Birth", dateOfBirth,
                      (d) => dateOfBirth = d),

              const SizedBox(height: 10),

              buildDateField("Date of Get License",
                  dateOfGetLicense, (d) => dateOfGetLicense = d),

              const SizedBox(height: 10),

              buildDateField("Date of End License",
                  dateOfEndLicense, (d) => dateOfEndLicense = d),

              const SizedBox(height: 15),

              buildDropdown("Gender", ["Male", "Female"],
                  gender, (v) => gender = v),

              buildDropdown("License Category",
                  ["A", "B", "C", "D"], category,
                      (v) => category = v),

              const SizedBox(height: 20),

              AuthButton(
                text: "Save Profile",
                onPressed: saveProfile,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.input,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items,
      String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppColors.input,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.input,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e,
              style:
              const TextStyle(color: Colors.white)),
        ))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => onChanged(v));
          }
        },
      ),
    );
  }
}