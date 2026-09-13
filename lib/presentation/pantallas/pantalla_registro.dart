import 'package:flutter/material.dart';
import '../../data/remote/repositorio_autenticacion.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _controladorNombre = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();
  final _repositorioAutenticacion = RepositorioAutenticacion();

  String? _error;
  bool _cargando = false;
  bool _verContrasena = false;
  bool _verConfirmarContrasena = false;

  Future<void> _registrar() async {
    if (_controladorContrasena.text != _controladorConfirmarContrasena.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    if (_controladorContrasena.text.length < 8) {
      setState(() => _error = 'La contraseña debe tener al menos 8 caracteres');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    final error = await _repositorioAutenticacion.registrar(
      _controladorNombre.text.trim(),
      _controladorEmail.text.trim(),
      _controladorContrasena.text.trim(),
    );

    setState(() {
      _error = error;
      _cargando = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada ✅')),
      );
    }
  }

  
  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  InputDecoration _decoracionInput(String placeholder, {Widget? sufijo}) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: sufijo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: colorPrimario, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              const Text(
                'Comenzar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                'Administra tu inventario y clientes de farmacia con Farmayopin',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 28),

              _etiqueta('Nombre Completo'),
              TextField(
                controller: _controladorNombre,
                decoration: _decoracionInput('Juan Pérez'),
              ),

              const SizedBox(height: 18),

              _etiqueta('Correo Electrónico'),
              TextField(
                controller: _controladorEmail,
                decoration: _decoracionInput('tu@farmacia.com'),
              ),

              const SizedBox(height: 18),

              _etiqueta('Contraseña'),
              TextField(
                controller: _controladorContrasena,
                obscureText: !_verContrasena,
                decoration: _decoracionInput(
                  'Mínimo 8 caracteres',
                  sufijo: IconButton(
                    icon: Icon(
                      _verContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() => _verContrasena = !_verContrasena);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _etiqueta('Confirmar Contraseña'),
              TextField(
                controller: _controladorConfirmarContrasena,
                obscureText: !_verConfirmarContrasena,
                decoration: _decoracionInput(
                  'Repite tu contraseña',
                  sufijo: IconButton(
                    icon: Icon(
                      _verConfirmarContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() => _verConfirmarContrasena = !_verConfirmarContrasena);
                    },
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Registrarse', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      children: const [
                        TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                          text: 'Iniciar Sesión',
                          style: TextStyle(
                            color: colorPrimario,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}