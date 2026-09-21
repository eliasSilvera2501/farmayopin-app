import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/carrito.dart';
import '../../domain/models/compra.dart';

class RepositorioCompras {
  final _baseDatos = FirebaseFirestore.instance;

  String? get _uidActual => FirebaseAuth.instance.currentUser?.uid;

  Future<String?> confirmarCompra() async {
    final uid = _uidActual;
    if (uid == null) return 'No hay un usuario logueado';

    final referenciaCarrito = _baseDatos.collection('carritos').doc(uid);

    try {
      await _baseDatos.runTransaction((transaccion) async {
        final docCarrito = await transaccion.get(referenciaCarrito);
        if (!docCarrito.exists || docCarrito.data() == null) {
          throw Exception('El carrito está vacío');
        }

        final carrito = Carrito.fromMap(docCarrito.data()!);
        if (carrito.items.isEmpty) {
          throw Exception('El carrito está vacío');
        }

        final referenciasProductos = carrito.items
            .map((item) => _baseDatos.collection('productos').doc(item.productoId))
            .toList();

        final docsProductos = await Future.wait(
          referenciasProductos.map((referencia) => transaccion.get(referencia)),
        );

        double total = 0;
        final itemsCompra = <ItemCompra>[];

        for (var i = 0; i < carrito.items.length; i++) {
          final itemCarrito = carrito.items[i];
          final docProducto = docsProductos[i];

          if (!docProducto.exists || docProducto.data() == null) {
            throw Exception('Un producto de tu carrito ya no existe');
          }

          final datosProducto = docProducto.data()!;
          final stockActual = (datosProducto['stock'] ?? 0) as int;
          final precio = (datosProducto['precio'] ?? 0).toDouble();
          final nombre = datosProducto['nombre'] ?? '';
          final sku = datosProducto['sku'] ?? '';

          if (stockActual < itemCarrito.cantidad) {
            throw Exception('Sin stock suficiente de $nombre (quedan $stockActual unidades)');
          }

          total += precio * itemCarrito.cantidad;
          itemsCompra.add(ItemCompra(
            productoId: itemCarrito.productoId,
            nombre: nombre,
            sku: sku,
            cantidad: itemCarrito.cantidad,
            precioUnitario: precio,
          ));
        }

        for (var i = 0; i < carrito.items.length; i++) {
          final stockActual = (docsProductos[i].data()!['stock'] ?? 0) as int;
          transaccion.update(referenciasProductos[i], {
            'stock': stockActual - carrito.items[i].cantidad,
          });
        }

        final referenciaCompra = _baseDatos.collection('compras').doc();
        final numeroOrden = _generarNumeroOrden(referenciaCompra.id);

        final compra = Compra(
          id: referenciaCompra.id,
          numeroOrden: numeroOrden,
          usuarioId: uid,
          fecha: DateTime.now(),
          items: itemsCompra,
          total: total,
          estado: 'en_camino',
          metodoEntrega: 'Envío a domicilio',
          metodoPago: 'Tarjeta de Crédito (**** 4242)',
        );
        transaccion.set(referenciaCompra, compra.toMap());

        transaccion.set(referenciaCarrito, Carrito.vacio(uid).toMap());
      });

      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  String _generarNumeroOrden(String idDocumento) {
    final numero = (idDocumento.hashCode.abs() % 10000).toString().padLeft(4, '0');
    return 'FAR-${DateTime.now().year}-$numero';
  }

  Stream<List<Compra>> historicoDeUsuario(String uid) {
    return _baseDatos
        .collection('compras')
        .where('usuarioId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final compras = snap.docs.map((doc) => Compra.fromMap(doc.id, doc.data())).toList();
      compras.sort((a, b) => b.fecha.compareTo(a.fecha));
      return compras;
    });
  }

  Stream<List<Map<String, dynamic>>> historicoDeProducto(String productoId) {
    return _baseDatos.collection('compras').snapshots().map((snap) {
      final ventas = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final items = (data['items'] as List<dynamic>? ?? []);
        for (final item in items) {
          final map = item as Map<String, dynamic>;
          if (map['productoId'] == productoId) {
            final ts = data['fecha'];
            DateTime fecha = DateTime.now();
            if (ts is Timestamp) fecha = ts.toDate();
            ventas.add({
              'compraId': doc.id,
              'usuarioId': data['usuarioId'] ?? '',
              'fecha': fecha,
              'cantidad': map['cantidad'] ?? 0,
              'precioUnitario': (map['precioUnitario'] ?? 0).toDouble(),
              'nombreCliente': data['nombreCliente'] ?? '',
              'totalLinea': ((map['cantidad'] ?? 0) as int) *
                  ((map['precioUnitario'] ?? 0) as num).toDouble(),
            });
          }
        }
      }
      ventas.sort((a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
      return ventas;
    });
  }
}
