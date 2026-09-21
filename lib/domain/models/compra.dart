import 'package:cloud_firestore/cloud_firestore.dart';

class ItemCompra {
  final String productoId;
  final String nombre;
  final String sku;
  final int cantidad;
  final double precioUnitario;

  ItemCompra({
    required this.productoId,
    required this.nombre,
    required this.sku,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap() => {
        'productoId': productoId,
        'nombre': nombre,
        'sku': sku,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
      };

  factory ItemCompra.fromMap(Map<String, dynamic> map) {
    return ItemCompra(
      productoId: map['productoId'] ?? '',
      nombre: map['nombre'] ?? '',
      sku: map['sku'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      precioUnitario: (map['precioUnitario'] ?? 0).toDouble(),
    );
  }
}

class Compra {
  final String id;
  final String numeroOrden;
  final String usuarioId;
  final DateTime fecha;
  final List<ItemCompra> items;
  final double total;
  final String estado;
  final String metodoEntrega;
  final String metodoPago;

  Compra({
    required this.id,
    required this.numeroOrden,
    required this.usuarioId,
    required this.fecha,
    required this.items,
    required this.total,
    required this.estado,
    required this.metodoEntrega,
    required this.metodoPago,
  });

  Map<String, dynamic> toMap() {
    return {
      'numeroOrden': numeroOrden,
      'usuarioId': usuarioId,
      'fecha': FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'estado': estado,
      'metodoEntrega': metodoEntrega,
      'metodoPago': metodoPago,
    };
  }

  factory Compra.fromMap(String id, Map<String, dynamic> map) {
    final listaItems = (map['items'] as List<dynamic>? ?? [])
        .map((item) => ItemCompra.fromMap(item as Map<String, dynamic>))
        .toList();

    final timestamp = map['fecha'] as Timestamp?;

    return Compra(
      id: id,
      numeroOrden: map['numeroOrden'] ?? id.substring(0, 4).toUpperCase(),
      usuarioId: map['usuarioId'] ?? '',
      fecha: timestamp?.toDate() ?? DateTime.now(),
      items: listaItems,
      total: (map['total'] ?? 0).toDouble(),
      estado: map['estado'] ?? 'en_camino',
      metodoEntrega: map['metodoEntrega'] ?? 'Envío a domicilio',
      metodoPago: map['metodoPago'] ?? '',
    );
  }
}
