import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime? fechaActualizacion;

  Carrito({required this.usuarioId, required this.items, this.fechaActualizacion});

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'items': items.map((item) => item.toMap()).toList(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  factory Carrito.fromMap(Map<String, dynamic> map) {
    final listaItems = (map['items'] as List<dynamic>? ?? [])
        .map((item) => ItemCarrito.fromMap(item as Map<String, dynamic>))
        .toList();

    final timestamp = map['fechaActualizacion'] as Timestamp?;

    return Carrito(
      usuarioId: map['usuarioId'] ?? '',
      items: listaItems,
      fechaActualizacion: timestamp?.toDate(),
    );
  }

  factory Carrito.vacio(String usuarioId) => Carrito(usuarioId: usuarioId, items: []);
}
