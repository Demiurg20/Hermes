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

  static const Color gold = AppColors.primary;

  Future<void> _takePhoto(int photoNumber) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
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

  Future<void> _handleAction() async {
    // 1. Проверка наличия фото
    if (_image1Bytes == null || _image2Bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take both photos (Front & Rear)")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final String bookingId = widget.bookingData["id"].toString();

      if (widget.isStartingTrip) {
        // 🔥 СТАРТ ПОЕЗДКИ
        await AppDI.bookingRepo.confirmBooking(
          bookingId,
          _image1Bytes!.toList(),
          _image2Bytes!.toList(),
        );
      } else {
        // 🔥 ВОЗВРАТ МАШИНЫ
        await AppDI.bookingRepo.clientReturn(
          bookingId,
          _image1Bytes!.toList(),
          _image2Bytes!.toList(),
        );
      }

      // 2. Даем бэкенду время обновить статус (0.5 сек)
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. ИСПРАВЛЕНО: проверяем mounted и возвращаемся
      if (!mounted) return;

      // Возвращаем TRUE, чтобы HomePage вызвал _onRefresh()
      Navigator.of(context).pop(true);

    } catch (e) {
      debugPrint("Action Error: $e");
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
    // Используем ключи из твоего API (Changan Uni-Z и т.д.)
    final String brand = widget.bookingData["carBrand"] ?? "";
    final String model = widget.bookingData["carModel"] ?? "Car";

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          widget.isStartingTrip ? "START JOURNEY" : "RETURN CAR",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "$brand $model".toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.isStartingTrip
                      ? "UPLOAD PHOTOS TO UNLOCK"
                      : "UPLOAD PHOTOS TO FINISH TRIP",
                  style: const TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),

              _buildPhotoCard("FRONT VIEW", _image1Bytes, () => _takePhoto(1)),
              const SizedBox(height: 20),
              _buildPhotoCard("REAR VIEW", _image2Bytes, () => _takePhoto(2)),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : _handleAction,
                  child: _isProcessing
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                  )
                      : Text(
                    widget.isStartingTrip ? "START TRIP NOW" : "FINALIZE RETURN",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String label, Uint8List? bytes, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF16181D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: bytes != null ? gold : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: bytes != null
              ? Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover),
              Container(color: Colors.black26),
              const Center(child: Icon(Icons.check_circle, color: gold, size: 50)),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, color: gold, size: 32),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}