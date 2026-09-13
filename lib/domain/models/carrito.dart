class ItemCarrito {
  final String productoId;
  final int cantidad;

  ItemCarrito({required this.productoId, required this.cantidad});

  Map<String, dynamic> toMap() => {'productoId': productoId, 'cantidad': cantidad};

  factory ItemCarrito.fromMap(Map<String, dynamic> map) {
    return ItemCarrito(productoId: map['productoId'], cantidad: map['cantidad']);
  }
}

class Carrito {
  final String usuarioId;
  final List<ItemCarrito> items;

  Carrito({required this.usuarioId, required this.items});
}