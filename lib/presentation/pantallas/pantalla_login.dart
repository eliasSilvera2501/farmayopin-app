import 'package:flutter/material.dart';
import '../../data/remote/repositorio_autenticacion.dart';
import 'pantalla_registro.dart';

const Color colorPrimario = Color(0xFF4F46E5);

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
  bool _cargando = false;
  bool _verContrasena = false;

  Future<void> _iniciarSesion() async {
    setState(() => _cargando = true);
    final error = await _repositorioAutenticacion.iniciarSesion(
      _controladorEmail.text.trim(),
      _controladorContrasena.text.trim(),
    );
    setState(() {
      _error = error;
      _cargando = false;
    });
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login exitoso ✅')),
      );
    }
  }

  Future<void> _recuperarContrasena() async {
    if (_controladorEmail.text.trim().isEmpty) {
      setState(() => _error = 'Escribí tu correo arriba primero, para saber a dónde mandar el enlace');
      return;
    }
    try {
      await _repositorioAutenticacion.enviarRecuperoContrasena(_controladorEmail.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un correo para restablecer tu contraseña')),
      );
    } catch (e) {
      setState(() => _error = 'No pudimos enviar el correo, revisá que esté bien escrito');
    }
  }

  InputDecoration _decoracionInput(String etiqueta, {Widget? sufijo}) {
    return InputDecoration(
      labelText: etiqueta,
      filled: true,
      fillColor: Colors.grey.shade100,
      suffixIcon: sufijo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorPrimario,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Farmayopin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Gestión de inventario farmacéutico', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              TextField(
                controller: _controladorEmail,
                decoration: _decoracionInput('Correo Electrónico'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controladorContrasena,
                obscureText: !_verContrasena,
                decoration: _decoracionInput(
                  'Contraseña',
                  sufijo: IconButton(
                    icon: Icon(_verContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _verContrasena = !_verContrasena),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _recuperarContrasena,
                  child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: colorPrimario, fontSize: 13)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _cargando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaRegistro()));
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    children: const [
                      TextSpan(text: '¿No tenés cuenta? '),
                      TextSpan(text: 'Crear Cuenta', style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}