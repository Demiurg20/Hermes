import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hermes/core/app/app_di.dart';
import 'package:hermes/core/theme/app_colors.dart';

class ReturnCarScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final bool isStartingTrip;

  const ReturnCarScreen({
    super.key,
    required this.bookingData,
    this.isStartingTrip = false,
  });

  @override
  State<ReturnCarScreen> createState() => _ReturnCarScreenState();
}

class _ReturnCarScreenState extends State<ReturnCarScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _image1Bytes;
  Uint8List? _image2Bytes;
  bool _isProcessing = false;

  // Используем золотой цвет из твоей темы
  static const Color gold = AppColors.primary;

  /// Функция для открытия камеры и получения байтов
  Future<void> _takePhoto(int photoNumber) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Сжимаем фото для API
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          if (photoNumber == 1) _image1Bytes = bytes;
          else _image2Bytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  /// Главная логика отправки
  Future<void> _handleAction() async {
    if (_image1Bytes == null || _image2Bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take both photos (Front & Rear)")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Приводим ID к строке
      final String bookingId = widget.bookingData["id"].toString();

      if (widget.isStartingTrip) {
        // Вызываем confirmBooking (Начало поездки + списание денег)
        // Мы используем .toList(), так как репозиторий ждет List<int>
        await AppDI.bookingRepo.confirmBooking(
          bookingId,
          _image1Bytes!.toList(),
          _image2Bytes!.toList(),
        );
      } else {
        // Вызываем clientReturn (Завершение поездки)
        await AppDI.bookingRepo.clientReturn(
          bookingId,
          _image1Bytes!.toList(),
          _image2Bytes!.toList(),
        );
      }

      if (!mounted) return;

      // Сразу обновляем баланс пользователя на устройстве
      await AppDI.userRepo.getUserInfo();

      // Возвращаемся на главную с сигналом об успехе
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String brand = widget.bookingData["carBrand"] ?? "Car";
    final String model = widget.bookingData["carModel"] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isStartingTrip ? "Start Journey" : "Return Car",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "$brand $model",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isStartingTrip
                  ? "Confirm car condition to start"
                  : "Finalize your trip",
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Фото 1
            _buildPhotoCard("FRONT VIEW", _image1Bytes, () => _takePhoto(1)),
            const SizedBox(height: 20),
            // Фото 2
            _buildPhotoCard("REAR VIEW", _image2Bytes, () => _takePhoto(2)),

            const SizedBox(height: 40),

            // Кнопка действия
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _handleAction,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                  widget.isStartingTrip ? "CONFIRM & START" : "SUBMIT RETURN",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Виджет карточки для фото
  Widget _buildPhotoCard(String label, Uint8List? bytes, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF111317),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: bytes != null ? gold : Colors.white.withOpacity(0.05),
            width: 2,
          ),
          image: bytes != null
              ? DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover)
              : null,
        ),
        child: bytes == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_rounded, color: gold, size: 42),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        )
            : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black26,
          ),
          child: const Icon(Icons.check_circle, color: gold, size: 40),
        ),
      ),
    );
  }
}