import 'package:flutter/material.dart';
import 'package:hermes/core/api/api_service.dart';
import 'package:hermes/core/theme/app_colors.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final api = ApiService();

  Map<String, dynamic>? user;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// ФУНКЦИЯ ДЛЯ ОБНОВЛЕНИЯ (Refresh)
  Future<void> _onRefresh() async {
    await loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await api.getUserInfo();

      print("PROFILE DATA: $data");

      if (mounted) {
        setState(() {
          user = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildInfo(String title, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.greyText),
          ),
          Text(
            value == null || value.toString().isEmpty ? "N/A" : value.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Profile"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh, // Тот самый свайп вниз
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Обязательно для свайпа
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.input,
                backgroundImage: user?["image"] != null
                    ? NetworkImage(user!["image"])
                    : null,
                child: user?["image"] == null
                    ? const Icon(Icons.person, color: AppColors.greyText)
                    : null,
              ),
              const SizedBox(height: 20),
              buildInfo("First Name", user?["firstName"]),
              buildInfo("Last Name", user?["lastName"]),
              buildInfo("Phone", user?["phone"]),
              buildInfo("Personal Number", user?["personalNumber"]),
              buildInfo("License Number", user?["licenseNumber"]),
              buildInfo("Gender", user?["gender"]),
              buildInfo("License Category", user?["categoryOfLicense"]),
              buildInfo("Date of Birth", user?["dateOfBirth"]),
              buildInfo("License Issued", user?["dateOfGetDriverLicense"]),
              buildInfo("License Expiry", user?["dateOfEndDriverLicense"]),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );

                  loadProfile();
                },
                child: const Text("Edit Profile"),
              )
            ],
          ),
        ),
      ),
    );
  }
}