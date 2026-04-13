import 'package:flutter/material.dart';
import 'package:hermes/core/app/app_di.dart';

class ReturnCarScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const ReturnCarScreen({super.key, required this.bookingData});

  @override
  State<ReturnCarScreen> createState() => _ReturnCarScreenState();
}

class _ReturnCarScreenState extends State<ReturnCarScreen> {
  static const Color bg = Color(0xFF0B0C0E);
  static const Color gold = Color(0xFFD6A34A);
  static const Color card = Color(0xFF111317);
  static const Color green = Color(0xFF3DDC84);

  bool _isProcessing = false;

  // Функция для "фотографирования" (пока просто заглушка)
  Future<void> _takePhoto(String side) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open camera for $side photo...')),
    );
    // TODO: Интегрировать image_picker
  }

  // 🔥 ЛОГИКА ВОЗВРАТА МАШИНЫ В API
  Future<void> _confirmReturn() async {
    setState(() => _isProcessing = true);

    try {
      final bookingId = widget.bookingData["id"]?.toString();
      if (bookingId == null) throw StateError("Missing booking ID");

      // 1. Вызываем метод API (POST /bookings/$id/client-return)
      // В твоем ApiService он уже есть.
      await AppDI.bookingRepo.clientReturn(bookingId);

      if (!mounted) return;

      // 2. Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Return request sent! Waiting owner confirm."),
          backgroundColor: green,
        ),
      );

      // 3. Возвращаемся на HomePage, передавая true (сигнал для обновления)
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Return failed: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.bookingData["carBrand"] ?? "";
    final model = widget.bookingData["carModel"] ?? "";

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Return Car', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название машины
                    Center(
                      child: Text(
                        '$brand $model',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Take 2 photos before successful return',
                        style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Блок для фотографий
                    Text("CAR PHOTOS", style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 12),

                    _PhotoCard(side: "Front side", icon: Icons.photo_camera_front_outlined, onTap: () => _takePhoto("Front")),
                    const SizedBox(height: 16),
                    _PhotoCard(side: "Rear side", icon: Icons.photo_camera_back_outlined, onTap: () => _takePhoto("Rear")),

                    const SizedBox(height: 30),

                    // Инфо-блок
                    _SurfaceCard(
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: gold.withOpacity(0.7), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Photos will be sent for review to ensure car safety and integrity.',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопка подтверждения
            Padding(
              padding: const EdgeInsets.all(16),
              child: _PrimaryButton(
                text: _isProcessing ? 'Processing…' : 'Confirm Return',
                onTap: _confirmReturn, // Временно без валидации фото
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Виджет карточки для фото
class _PhotoCard extends StatelessWidget {
  final String side;
  final IconData icon;
  final VoidCallback onTap;

  const _PhotoCard({required this.side, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color card = Color(0xFF111317);
    const Color gold = Color(0xFFD6A34A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.15), size: 60),
          const SizedBox(height: 16),
          Text(side, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_a_photo, size: 16, color: gold),
            label: const Text("Take a photo", style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(backgroundColor: gold.withOpacity(0.08), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  const _SurfaceCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111317), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryButton({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD6A34A),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}