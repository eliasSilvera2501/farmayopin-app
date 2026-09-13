class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol; // "admin" o "cliente"

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {'nombre': nombre, 'email': email, 'rol': rol};
  }

  factory Usuario.fromMap(String uid, Map<String, dynamic> map) {
    return Usuario(
      uid: uid,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      rol: map['rol'] ?? 'cliente',
    );
  }
}