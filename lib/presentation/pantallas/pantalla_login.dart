import 'package:flutter/material.dart';
import '../../data/remote/repositorio_autenticacion.dart';
import 'pantalla_registro.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _controladorEmail = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _repositorioAutenticacion = RepositorioAutenticacion();
  String? _error;

  Future<void> _iniciarSesion() async {
    final error = await _repositorioAutenticacion.iniciarSesion(
      _controladorEmail.text.trim(),
      _controladorContrasena.text.trim(),
    );
    setState(() => _error = error);
    if (error == null) {
      // Login exitoso — más adelante acá navegamos a la pantalla principal.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login exitoso ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controladorEmail,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorContrasena,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _iniciarSesion, child: const Text('Iniciar Sesión')),
                        const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                );
              },
              child: const Text('¿No tenés cuenta? Registrate'),
            ),
          ],
        ),
      ),
    );
  }
}