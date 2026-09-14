import 'package:flutter/material.dart';
import '../../../data/remote/repositorio_autenticacion.dart';
import '../pantalla_login.dart';

const Color colorPrimario = Color(0xFF4F46E5);

// Pantalla temporal: se muestra a los usuarios con rol "admin" mientras
// la pantalla real de Administrador (Listar Productos, etc.) todavia no existe.
// Cuando esa pantalla este lista, se reemplaza esta por esa en pantalla_login.dart.
class PantallaAdminTemporal extends StatelessWidget {
  const PantallaAdminTemporal({super.key});

  @override
  Widget build(BuildContext context) {
    final repositorioAutenticacion = RepositorioAutenticacion();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Panel de Administrador',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entraste como admin. Esta pantalla todavia esta en construccion.',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () async {
                    await repositorioAutenticacion.cerrarSesion();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const PantallaLogin()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar sesion', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}