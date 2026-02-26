import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'car_details_page.dart';

class CarsListPage extends StatelessWidget {
  const CarsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cars = [
      {"name": "Tesla Model 3", "price": "\$15/hour"},
      {"name": "BMW 5 Series", "price": "\$22/hour"},
      {"name": "Mercedes C-Class", "price": "\$20/hour"},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Available Cars",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CarDetailsPage(
                    name: cars[index]["name"]!,
                    price: cars[index]["price"]!,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car,
                      color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cars[index]["name"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    cars[index]["price"]!,
                    style: const TextStyle(
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}