import 'package:flutter/material.dart';
import 'package:hermes/core/app/app_di.dart';
import 'package:hermes/core/theme/app_colors.dart';
import 'package:hermes/features/cars/payment_page.dart';

class BalanceTopUpPage extends StatefulWidget {
  const BalanceTopUpPage({super.key});

  @override
  State<BalanceTopUpPage> createState() => _BalanceTopUpPageState();
}

class _BalanceTopUpPageState extends State<BalanceTopUpPage> {
  double? _balance;
  bool _loading = true;
  String? _error;

  double _selectedAmount = 100;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AppDI.api.getUserInfo();
      final raw = data['balance'] ??
          data['walletBalance'] ??
          data['wallet'] ??
          data['amount'];
      final bal = raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '');
      setState(() {
        _balance = bal ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _topUp() async {
    final amount = _selectedAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a top-up amount greater than 0')),
      );
      return;
    }

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(totalAmount: amount),
      ),
    );
    if (paid != true) return;

    try {
      await AppDI.api.topUpBalance(amount);
      await _loadBalance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balance topped up successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Top-up failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Balance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const Text(
                    'Current balance',
                    style: TextStyle(
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _balance == null ? '--' : '\$${_balance!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Top-up amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [50, 100, 200, 500].map((v) {
                      final isSelected = _selectedAmount == v.toDouble();
                      return ChoiceChip(
                        label: Text('\$$v'),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedAmount = v.toDouble();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      onPressed: _topUp,
                      child: const Text(
                        'Top up balance',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

