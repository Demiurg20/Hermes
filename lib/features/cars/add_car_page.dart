import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hermes/core/app/app_di.dart';
import '/core/theme/app_colors.dart';
import '/core/widgets/auth_textfield.dart';
import '/core/widgets/auth_button.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final picker = ImagePicker();
  File? carImage;
  bool _isLoading = false;

  // Контроллеры строго под твой CarRequest
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final capacityController = TextEditingController();
  final fuelTypeController = TextEditingController();
  final transmissionController = TextEditingController();
  final descriptionController = TextEditingController();
  final pricePerHourController = TextEditingController();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (picked != null) {
      setState(() {
        carImage = File(picked.path);
      });
    }
  }

  /// 🔌 API INTEGRATION (Strictly following CarRequest DTO)
  Future<void> submitCar() async {
    // Валидация перед отправкой
    if (carImage == null || brandController.text.isEmpty || pricePerHourController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please take a photo and fill in Brand and Price"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Подготовка данных - строго по именам полей в Java
      final Map<String, dynamic> data = {
        "brand": brandController.text.trim(),
        "model": modelController.text.trim(),
        "year": int.tryParse(yearController.text) ?? 2024, // Integer
        "color": colorController.text.trim(),
        "capacity": int.tryParse(capacityController.text) ?? 1, // Integer (Min 1)
        "fuelType": fuelTypeController.text.trim(), // Важно: fuelType
        "transmission": transmissionController.text.trim(),
        "description": descriptionController.text.trim(),
        "pricePerHour": int.tryParse(pricePerHourController.text) ?? 0, // Integer
      };

      final bytes = await carImage!.readAsBytes();

      // 4. Отправка
      await AppDI.api.addCarBackend(data, bytes.toList());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Car successfully listed!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Add Car Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "List Your Car",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 25),

              /// IMAGE
              GestureDetector(
                onTap: _isLoading ? null : pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: carImage != null ? AppColors.primary : Colors.white12, width: 2),
                  ),
                  child: carImage == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 40),
                      SizedBox(height: 12),
                      Text("Photograph your car", style: TextStyle(color: Colors.white54)),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(carImage!, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Поля ввода по порядку твоего DTO
              AuthTextField(controller: brandController, hint: "Brand", icon: Icons.car_rental),
              const SizedBox(height: 12),

              AuthTextField(controller: modelController, hint: "Model", icon: Icons.directions_car),
              const SizedBox(height: 12),

              AuthTextField(controller: yearController, hint: "Year", icon: Icons.calendar_today, keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              AuthTextField(controller: colorController, hint: "Color", icon: Icons.palette),
              const SizedBox(height: 12),

              AuthTextField(controller: capacityController, hint: "Capacity (Number)", icon: Icons.people, keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              AuthTextField(controller: fuelTypeController, hint: "Fuel Type", icon: Icons.local_gas_station),
              const SizedBox(height: 12),

              AuthTextField(controller: transmissionController, hint: "Transmission", icon: Icons.settings),
              const SizedBox(height: 12),

              // Description с поддержкой нескольких строк
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: const TextStyle(color: AppColors.greyText),
                  filled: true,
                  fillColor: AppColors.input,
                  prefixIcon: const Icon(Icons.description, color: AppColors.greyText),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              AuthTextField(controller: pricePerHourController, hint: "Price Per Hour", icon: Icons.attach_money, keyboardType: TextInputType.number),

              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : AuthButton(
                text: "LIST CAR FOR RENT",
                onPressed: submitCar,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}