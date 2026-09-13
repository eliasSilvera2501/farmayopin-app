class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String fotoUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.fotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'fotoUrl': fotoUrl,
    };
  }

  factory Producto.fromMap(String id, Map<String, dynamic> map) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      fotoUrl: map['fotoUrl'] ?? '',
    );
  }
}