import 'package:flutter/material.dart';
import '../../data/remote/repositorio_autenticacion.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _controladorNombre = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _repositorioAutenticacion = RepositorioAutenticacion();
  String? _error;

  Future<void> _registrar() async {
    final error = await _repositorioAutenticacion.registrar(
      _controladorNombre.text.trim(),
      _controladorEmail.text.trim(),
      _controladorContrasena.text.trim(),
    );
    setState(() => _error = error);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controladorNombre,
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            const SizedBox(height: 12),
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
            ElevatedButton(onPressed: _registrar, child: const Text('Registrarse')),
          ],
        ),
      ),
    );
  }
}