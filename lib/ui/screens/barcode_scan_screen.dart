import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/openfoodfacts_service.dart';
import '../../theme/app_theme.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _service = OpenFoodFactsService();
  bool _isProcessing = false;
  String? _error;

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    final product = await _service.getProductByBarcode(barcode);

    if (!mounted) return;

    if (product != null) {
      Navigator.pop(context, product);
    } else {
      setState(() {
        _isProcessing = false;
        _error = 'Prodotto non trovato per il codice: $barcode';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.offWhite,
        title: Text(
          'SCANSIONA',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: AppColors.offWhite,
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onBarcodeDetected,
          ),
          // Overlay
          Center(
            child: Container(
              width: 280,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accentGreen, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Bottom info
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warmBlack.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: AppColors.accentGreen,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ricerca prodotto...',
                          style: GoogleFonts.vt323(
                            fontSize: 20,
                            color: AppColors.offWhite,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_error != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warmBlack.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Inquadra il codice a barre',
                      style: GoogleFonts.vt323(
                        fontSize: 20,
                        color: AppColors.offWhite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


