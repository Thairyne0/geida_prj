import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/retro_card.dart';

class ProfileScreen extends StatefulWidget {
  final bool isFirstSetup;

  const ProfileScreen({super.key, this.isFirstSetup = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _kcalGoalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _weightController.text = profile.weight.toStringAsFixed(0);
      _heightController.text = profile.height.toStringAsFixed(0);
      _kcalGoalController.text = profile.dailyKcalGoal.toStringAsFixed(0);
    } else {
      _kcalGoalController.text = '2000';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _kcalGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      dailyKcalGoal: double.parse(_kcalGoalController.text),
    );

    await context.read<AppState>().saveProfile(profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warmBlack,
          content: Text(
            'Profilo salvato!',
            style: GoogleFonts.vt323(fontSize: 20, color: AppColors.offWhite),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      if (widget.isFirstSetup) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isFirstSetup)
                const SizedBox(height: 8),
              Text(
                widget.isFirstSetup ? 'BENVENUTO!' : 'PROFILO',
                style: GoogleFonts.pressStart2p(
                  fontSize: widget.isFirstSetup ? 18 : 12,
                  color: AppColors.warmBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isFirstSetup
                    ? 'Inserisci i tuoi dati per iniziare a tracciare le calorie.'
                    : 'Modifica i tuoi dati personali.',
                style: GoogleFonts.vt323(
                  fontSize: 22,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Name
              RetroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOME',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.vt323(fontSize: 24),
                      decoration: InputDecoration(
                        hintText: 'Il tuo nome',
                        hintStyle: GoogleFonts.vt323(
                          fontSize: 24,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Weight & Height
              Row(
                children: [
                  Expanded(
                    child: RetroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PESO (KG)',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.pressStart2p(fontSize: 18),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Richiesto';
                              if (double.tryParse(v) == null) return 'Numero non valido';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '70',
                              hintStyle: GoogleFonts.pressStart2p(
                                fontSize: 18,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RetroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALTEZZA (CM)',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.pressStart2p(fontSize: 18),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Richiesto';
                              if (double.tryParse(v) == null) return 'Numero non valido';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '175',
                              hintStyle: GoogleFonts.pressStart2p(
                                fontSize: 18,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Daily kcal goal
              RetroCard(
                highlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OBIETTIVO KCAL GIORNALIERO',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _kcalGoalController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.pressStart2p(fontSize: 22),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Richiesto';
                        if (double.tryParse(v) == null) return 'Numero non valido';
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixText: 'kcal',
                        suffixStyle: GoogleFonts.vt323(fontSize: 22, color: AppColors.textSecondary),
                        hintText: '2000',
                        hintStyle: GoogleFonts.pressStart2p(
                          fontSize: 22,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Save button
              Center(
                child: GestureDetector(
                  onTap: _saveProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.warmBlack, width: 2),
                      boxShadow: AppShadows.buttonShadow,
                    ),
                    child: Text(
                      widget.isFirstSetup ? 'INIZIA' : 'SALVA',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 12,
                        color: AppColors.warmBlack,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

