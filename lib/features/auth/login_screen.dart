import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'auth_view_model.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authVM.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.azulMarino, // Dark branding background for login
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
                
                // Programmatic Caja Arequipa Isotype / Logo
                const Center(child: CajaArequipaLogo()),
                const SizedBox(height: 24),
                
                const Text(
                  'Fuerza de Ventas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.turquesaBrillante,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'Oficiales de Crédito',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.blancoPuro,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Form Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black45,
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
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulMarino,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Username / DNI field
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(color: AppColors.textoOscuro),
                            decoration: const InputDecoration(
                              labelText: 'Usuario / DNI',
                              prefixIcon: Icon(Icons.person_outline, color: AppColors.azulMarino),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingrese su usuario o DNI';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          TextFormField(
                            controller: _passwordController,
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
                                onPressed: () {
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
                                color: AppColors.rojoCoral.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.rojoCoral, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.rojoCoral),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authVM.errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.rojoCoral,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
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
                              onPressed: authVM.isLoading ? null : _handleLogin,
                              child: authVM.isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.azulMarino),
                                    )
                                  : const Text(
                                      'INGRESAR',
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
                  'Caja Arequipa © 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
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
