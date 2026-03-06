import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();
  final seatsController = TextEditingController();
  final transmissionController = TextEditingController();
  final fuelController = TextEditingController();
  final priceController = TextEditingController();

  String carClass = "Economy";

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        carImage = File(picked.path);
      });
    }
  }

  /// 🔌 API READY
  Future<void> submitCar() async {
    final data = {
      "brand": brandController.text,
      "model": modelController.text,
      "year": yearController.text,
      "color": colorController.text,
      "seats": seatsController.text,
      "transmission": transmissionController.text,
      "fuel": fuelController.text,
      "price": priceController.text,
      "class": carClass
    };

    /// TODO: API
    /// ApiService.addCar(data, carImage)

    print(data);
  }

  Widget buildClassButton(String value) {
    final selected = carClass == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => carClass = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.input,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
              ),
            ),
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

              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: const [
                  BackButton(),
                  SizedBox(width: 10),
                  Text(
                    "List Your Car",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// IMAGE
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: carImage == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,color: AppColors.primary),
                        SizedBox(height: 8),
                        Text("Tap to photograph your car"),
                      ],
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(carImage!,fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              AuthTextField(controller: brandController, hint: "Brand", icon: Icons.car_rental),
              const SizedBox(height: 12),

              AuthTextField(controller: modelController, hint: "Model", icon: Icons.directions_car),
              const SizedBox(height: 12),

              AuthTextField(controller: yearController, hint: "Year", icon: Icons.calendar_today),
              const SizedBox(height: 12),

              AuthTextField(controller: colorController, hint: "Color", icon: Icons.palette),
              const SizedBox(height: 12),

              AuthTextField(controller: seatsController, hint: "Seats", icon: Icons.event_seat),
              const SizedBox(height: 12),

              AuthTextField(controller: transmissionController, hint: "Transmission", icon: Icons.settings),
              const SizedBox(height: 12),

              AuthTextField(controller: fuelController, hint: "Fuel", icon: Icons.local_gas_station),
              const SizedBox(height: 12),

              AuthTextField(controller: priceController, hint: "Price / hour", icon: Icons.attach_money),

              const SizedBox(height: 20),

              /// CLASS
              const Text("CLASS"),

              const SizedBox(height: 10),

              Row(
                children: [
                  buildClassButton("Economy"),
                  const SizedBox(width: 10),
                  buildClassButton("Comfort"),
                  const SizedBox(width: 10),
                  buildClassButton("Business"),
                ],
              ),

              const SizedBox(height: 25),

              AuthButton(
                text: "List Car for Rent",
                onPressed: submitCar,
              )
            ],
          ),
        ),
      ),
    );
  }
}