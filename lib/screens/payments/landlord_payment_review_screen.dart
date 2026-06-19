import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/payment.dart';
import '../../providers/app_providers.dart';
import '../../widgets/base64_image.dart';

/// El arrendador revisa comprobantes y aprueba o rechaza pagos.
class LandlordPaymentReviewScreen extends StatefulWidget {
  const LandlordPaymentReviewScreen({super.key, required this.paymentId});

  final String paymentId;

  @override
  State<LandlordPaymentReviewScreen> createState() =>
      _LandlordPaymentReviewScreenState();
}

class _LandlordPaymentReviewScreenState
    extends State<LandlordPaymentReviewScreen> {
  bool _loading = true;
  bool _processing = false;
  Payment? _payment;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final payment =
        await context.read<PaymentProvider>().getPaymentById(widget.paymentId);
    if (mounted) {
      setState(() {
        _payment = payment;
        _loading = false;
      });
    }
  }

  Future<void> _approve() async {
    setState(() => _processing = true);
    try {
      final provider = context.read<PaymentProvider>();
      final user = context.read<AuthProvider>().currentUser;
      await provider.approvePayment(widget.paymentId);
      await provider.loadDashboardData(user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago aprobado'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _reject() async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Rechazar pago'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
              hintText: 'Ej: El comprobante no es legible',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );
    if (!mounted || motivo == null) return;

    setState(() => _processing = true);
    try {
      final provider = context.read<PaymentProvider>();
      final user = context.read<AuthProvider>().currentUser;
      await provider.rejectPayment(widget.paymentId, motivo: motivo);
      await provider.loadDashboardData(user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago rechazado')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final payment = _payment;
    if (payment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revisar pago')),
        body: const Center(child: Text('Pago no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Revisar pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              payment.esDeposito
                  ? payment.concepto.label
                  : Formatters.monthYear(payment.periodo),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.currency(payment.monto),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (payment.comprobanteBase64 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Base64Image(
                  base64: payment.comprobanteBase64,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Text('Sin comprobante adjunto'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _processing ? null : _reject,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _processing ? null : _approve,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: _processing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Aprobar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
