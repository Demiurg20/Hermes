

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.totalAmount,
  });

  final double totalAmount;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color bg = Color(0xFF0B0C0E);
  static const Color card = Color(0xFF111317);
  static const Color gold = Color(0xFFD6A34A);

  final _cardNumberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();

  String? _cardNumberErr;
  String? _nameErr;
  String? _expiryErr;
  String? _cvcErr;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  bool _isValidExpiry(String input) {
    // Expected MM/YY
    final m = RegExp(r'^(\d{2})\/(\d{2})$').firstMatch(input.trim());
    if (m == null) return false;
    final mm = int.tryParse(m.group(1) ?? '');
    final yy = int.tryParse(m.group(2) ?? '');
    if (mm == null || yy == null) return false;
    if (mm < 1 || mm > 12) return false;

    // Not in the past (simple check using current month/year)
    final now = DateTime.now();
    final currentYY = now.year % 100;
    final currentMM = now.month;
    if (yy < currentYY) return false;
    if (yy == currentYY && mm < currentMM) return false;
    return true;
  }

  void _validateAndPay() {
    final cardDigits = _digitsOnly(_cardNumberCtrl.text);
    final name = _nameCtrl.text.trim();
    final expiry = _expiryCtrl.text.trim();
    final cvc = _digitsOnly(_cvcCtrl.text);

    String? cardErr;
    String? nameErr;
    String? expiryErr;
    String? cvcErr;

    if (cardDigits.isEmpty) {
      cardErr = 'Enter your card number.';
    } else if (cardDigits.length != 16) {
      cardErr = 'Card number must be 16 digits.';
    }

    if (name.isEmpty) {
      nameErr = 'Enter the cardholder name.';
    } else if (name.length < 3) {
      nameErr = 'Name is too short.';
    }

    if (expiry.isEmpty) {
      expiryErr = 'Enter expiry as MM/YY.';
    } else if (!_isValidExpiry(expiry)) {
      expiryErr = 'Expiry must be valid (MM/YY) and not expired.';
    }

    if (cvc.isEmpty) {
      cvcErr = 'Enter CVC.';
    } else if (cvc.length != 3) {
      cvcErr = 'CVC must be 3 digits.';
    }

    setState(() {
      _cardNumberErr = cardErr;
      _nameErr = nameErr;
      _expiryErr = expiryErr;
      _cvcErr = cvcErr;
    });

    final ok = cardErr == null && nameErr == null && expiryErr == null && cvcErr == null;
    if (!ok) return;

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final totalText = '\$${widget.totalAmount.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _SurfaceCard(
                      child: Column(
                        children: [
                          Text(
                            'TOTAL AMOUNT',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            totalText,
                            style: const TextStyle(
                              color: gold,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Card Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _FieldLabel('CARD NUMBER'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _cardNumberCtrl,
                      hintText: '1234 5678 9012 3456',
                      prefixIcon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        _CardNumberSpacingFormatter(),
                      ],
                      onChanged: (_) {
                        if (_cardNumberErr != null) setState(() => _cardNumberErr = null);
                      },
                    ),
                    if (_cardNumberErr != null) _ErrorText(_cardNumberErr!),

                    const SizedBox(height: 14),

                    _FieldLabel('CARDHOLDER NAME'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _nameCtrl,
                      hintText: 'John Doe',
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {
                        if (_nameErr != null) setState(() => _nameErr = null);
                      },
                    ),
                    if (_nameErr != null) _ErrorText(_nameErr!),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('EXPIRY'),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _expiryCtrl,
                                hintText: 'MM/YY',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  _ExpiryFormatter(),
                                ],
                                onChanged: (_) {
                                  if (_expiryErr != null) setState(() => _expiryErr = null);
                                },
                              ),
                              if (_expiryErr != null) _ErrorText(_expiryErr!),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('CVC'),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _cvcCtrl,
                                hintText: '123',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                onChanged: (_) {
                                  if (_cvcErr != null) setState(() => _cvcErr = null);
                                },
                              ),
                              if (_cvcErr != null) _ErrorText(_cvcErr!),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.45), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Your payment information is encrypted and secure',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _PrimaryButton(
                text: 'Pay $totalText',
                onTap: _validateAndPay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.35),
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  static const Color card = Color(0xFF111317);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: Colors.white.withOpacity(0.55), size: 18),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textCapitalization: textCapitalization,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: Colors.white,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.redAccent.withOpacity(0.85),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;

  static const Color card = Color(0xFF111317);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 12),
            color: Colors.black.withOpacity(0.35),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  static const Color gold = Color(0xFFD6A34A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: gold,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

/// Formats digits as `1234 5678 9012 3456`.
class _CardNumberSpacingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buf.write(digits[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digits.length) buf.write(' ');
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats digits as `MM/YY`.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String text;
    if (digits.length <= 2) {
      text = digits;
    } else {
      text = '${digits.substring(0, 2)}/${digits.substring(2, digits.length.clamp(2, 4))}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}