class ItemCompra {
  final String productoId;
  final int cantidad;
  final double precioUnitario;

  ItemCompra({required this.productoId, required this.cantidad, required this.precioUnitario});
}

class Compra {
  final String id;
  final String usuarioId;
  final DateTime fecha;
  final List<ItemCompra> items;
  final double total;
  final String estado; // "en_camino" | "entregado"

  Compra({
    required this.id,
    required this.usuarioId,
    required this.fecha,
    required this.items,
    required this.total,
    required this.estado,
  });
}