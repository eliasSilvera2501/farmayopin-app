import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepositorioAutenticacion {
  final _autenticacion = FirebaseAuth.instance;
  final _baseDatos = FirebaseFirestore.instance;

  Future<String?> registrar(String nombre, String email, String contrasena) async {
    try {
      final credencial = await _autenticacion.createUserWithEmailAndPassword(
        email: email,
        password: contrasena,
      );
      await _baseDatos.collection('usuarios').doc(credencial.user!.uid).set({
        'nombre': nombre,
        'email': email,
        'rol': 'cliente',
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> iniciarSesion(String email, String contrasena) async {
    try {
      await _autenticacion.signInWithEmailAndPassword(email: email, password: contrasena);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> enviarRecuperoContrasena(String email) async {
    await _autenticacion.sendPasswordResetEmail(email: email);
  }

  Future<void> cerrarSesion() async {
    await _autenticacion.signOut();
  }

  Future<String?> obtenerRolUsuarioActual() async {
    final uid = _autenticacion.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _baseDatos.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;

    return doc.data()?['rol'] as String?;
  }
}
