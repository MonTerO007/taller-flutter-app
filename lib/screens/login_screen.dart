import 'package:flutter/material.dart';

import 'home_screen.dart';

/// Pantalla de inicio de sesión WFC4.
///
/// Esta pantalla protege el acceso principal
/// del sistema técnico.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioController = TextEditingController();
  final claveController = TextEditingController();

  bool ocultarClave = true;

  final String usuarioCorrecto = 'admin';
  final String claveCorrecta = '1234';

  @override
  void dispose() {
    usuarioController.dispose();
    claveController.dispose();
    super.dispose();
  }

  void iniciarSesion() {
    final usuario = usuarioController.text.trim();
    final clave = claveController.text.trim();

    if (usuario == usuarioCorrecto && clave == claveCorrecta) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuario o contraseña incorrectos'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_wfc4.png',
                    height: 120,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Acceso WFC4',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Sistema técnico electrónico',
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: claveController,
                    obscureText: ocultarClave,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          ocultarClave
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            ocultarClave = !ocultarClave;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: iniciarSesion,
                      icon: const Icon(Icons.login),
                      label: const Text('Entrar al sistema'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}