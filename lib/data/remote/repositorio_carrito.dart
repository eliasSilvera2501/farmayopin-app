import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/carrito.dart';

class RepositorioCarrito {
  final _baseDatos = FirebaseFirestore.instance;

  String? get _uidActual => FirebaseAuth.instance.currentUser?.uid;

  Stream<Carrito> obtenerCarrito() {
    final uid = _uidActual;
    if (uid == null) {
      return Stream.value(Carrito.vacio(''));
    }
    return _baseDatos.collection('carritos').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return Carrito.vacio(uid);
      }
      return Carrito.fromMap(doc.data()!);
    });
  }

  Future<void> agregarProducto(String productoId, int cantidad) async {
    final uid = _uidActual;
    if (uid == null) return;

    final referencia = _baseDatos.collection('carritos').doc(uid);
    final doc = await referencia.get();

    List<ItemCarrito> items = [];
    if (doc.exists && doc.data() != null) {
      items = Carrito.fromMap(doc.data()!).items;
    }

    final indiceExistente = items.indexWhere((item) => item.productoId == productoId);
    if (indiceExistente >= 0) {
      final actual = items[indiceExistente];
      items[indiceExistente] = ItemCarrito(
        productoId: productoId,
        cantidad: actual.cantidad + cantidad,
      );
    } else {
      items.add(ItemCarrito(productoId: productoId, cantidad: cantidad));
    }

    final carritoActualizado = Carrito(usuarioId: uid, items: items);
    await referencia.set(carritoActualizado.toMap());
  }

  Future<void> actualizarCantidad(String productoId, int nuevaCantidad) async {
    final uid = _uidActual;
    if (uid == null) return;

    final referencia = _baseDatos.collection('carritos').doc(uid);
    final doc = await referencia.get();
    if (!doc.exists || doc.data() == null) return;

    final items = Carrito.fromMap(doc.data()!).items;
    final indice = items.indexWhere((item) => item.productoId == productoId);
    if (indice < 0) return;

    if (nuevaCantidad <= 0) {
      items.removeAt(indice);
    } else {
      items[indice] = ItemCarrito(productoId: productoId, cantidad: nuevaCantidad);
    }

    final carritoActualizado = Carrito(usuarioId: uid, items: items);
    await referencia.set(carritoActualizado.toMap());
  }

  Future<void> eliminarProducto(String productoId) async {
    await actualizarCantidad(productoId, 0);
  }

  Future<void> vaciarCarrito() async {
    final uid = _uidActual;
    if (uid == null) return;
    await _baseDatos.collection('carritos').doc(uid).set(Carrito.vacio(uid).toMap());
  }
}
