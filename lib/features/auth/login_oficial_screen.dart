import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'auth_oficial_view_model.dart';
import '../cartera/cartera_diaria_screen.dart';

class LoginOficialScreen extends StatefulWidget {
  const LoginOficialScreen({super.key});

  @override
  State<LoginOficialScreen> createState() => _LoginOficialScreenState();
}

class _LoginOficialScreenState extends State<LoginOficialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController(text: 'OF12345');
  final _passwordController = TextEditingController(text: 'caja123');
  bool _obscurePassword = true;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdownTimerIfNeeded();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startCountdownTimerIfNeeded() {
    final authVM = Provider.of<AuthOficialViewModel>(context, listen: false);
    if (authVM.isLockedOut) {
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && authVM.isLockedOut) {
          setState(() {});
        } else {
          timer.cancel();
          setState(() {});
        }
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authVM = Provider.of<AuthOficialViewModel>(context, listen: false);
      if (authVM.isLockedOut) {
        _startCountdownTimerIfNeeded();
        return;
      }

      final success = await authVM.login(
        _codeController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CarteraDiariaScreen()),
        );
      } else {
        if (authVM.isLockedOut) {
          _startCountdownTimerIfNeeded();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authVM = Provider.of<AuthOficialViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.azulMarino, // Dark identity for officers
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                
                // Programmatic Logo
                const Center(child: CajaArequipaLogo()),
                const SizedBox(height: 16),
                
                const Text(
                  'Portal Oficial de Crédito',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.amarilloMostaza,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const Text(
                  'Fuerza de Ventas Externa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.blancoPuro,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Form Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Ingreso Institucional',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulMarino,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Locked Out Countdown UI
                          if (authVM.isLockedOut) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.rojoCoral.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.rojoCoral, width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.timer, color: AppColors.rojoCoral, size: 40),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'ACCESO BLOQUEADO POR INTRUSIÓN',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.rojoCoral,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Podrá ingresar en: ${_formatDuration(authVM.lockoutSecondsRemaining)}',
                                    style: const TextStyle(
                                      color: AppColors.textoOscuro,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Employee Code field
                          TextFormField(
                            controller: _codeController,
                            enabled: !authVM.isLockedOut,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(color: AppColors.textoOscuro),
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Código de Empleado',
                              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.azulMarino),
                              hintText: 'Ej. OF12345',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                  return 'Ingrese su código de empleado';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            enabled: !authVM.isLockedOut,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppColors.textoOscuro),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.azulMarino),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textoMutado,
                                ),
                                onPressed: authVM.isLockedOut ? null : () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese su contraseña';
                              }
                              return null;
                            },
                          ),

                          
                          // Error indicator
                          if (authVM.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.rojoCoral.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.rojoCoral, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.rojoCoral, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authVM.errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.rojoCoral,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (authVM.isLoading || authVM.isLockedOut) ? null : _handleLogin,
                              child: authVM.isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.azulMarino),
                                    )
                                  : const Text(
                                      'INGRESAR PORTAL',
                                      style: TextStyle(letterSpacing: 1.1),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Footer
                const Text(
                  'Portal Oficial - Caja Arequipa © 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget that paints the geometric Caja Arequipa Isotype
class CajaArequipaLogo extends StatelessWidget {
  final double size;
  const CajaArequipaLogo({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Isotype: a colorful geometric arch shape
        SizedBox(
          width: size,
          height: size * 0.7,
          child: CustomPaint(
            painter: IsotypePainter(),
          ),
        ),
        const SizedBox(height: 12),
        // Logo Text
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: const [
            Text(
              'caja',
              style: TextStyle(
                color: AppColors.blancoPuro,
                fontSize: 26,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'arequipa',
              style: TextStyle(
                color: AppColors.turquesaBrillante,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class IsotypePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // We draw the corporate logo: a stylized geometric roof/triangles arch made of different colored blocks
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Define colors of isotype segments
    final List<Color> colors = [
      AppColors.rojoCoral,      // #D93D41
      AppColors.naranjaOcre,    // #C67A43
      AppColors.amarilloMostaza, // #FF9E1B
      AppColors.verdeCesped,    // #1FA02F
      AppColors.turquesaOscuro,  // #008EA7
    ];

    // Drawing a stylized geometric crown/roof shape: 5 bars
    final double barWidth = w / 7;
    final double spacing = barWidth * 0.2;
    
    // Position of bars
    for (int i = 0; i < 5; i++) {
      paint.color = colors[i];
      
      // Calculate heights to form a roof structure (low sides, high center)
      double barHeight;
      if (i == 0 || i == 4) {
        barHeight = h * 0.45;
      } else if (i == 1 || i == 3) {
        barHeight = h * 0.75;
      } else {
        barHeight = h * 1.0;
      }

      final double x = (w - (5 * barWidth + 4 * spacing)) / 2 + i * (barWidth + spacing);
      final double y = h - barHeight;

      // Draw each bar as a rounded rectangle
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
