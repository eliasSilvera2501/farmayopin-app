import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/producto.dart';

class RepositorioProductos {
  final _baseDatos = FirebaseFirestore.instance;

  // Stream: la pantalla se actualiza sola si un producto cambia en Firestore
  // (por ejemplo, si Admin edita el stock mientras Cliente tiene el catalogo abierto).
  Stream<List<Producto>> obtenerProductos() {
    return _baseDatos.collection('productos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Producto.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<Producto?> obtenerProductoPorId(String id) async {
    final doc = await _baseDatos.collection('productos').doc(id).get();
    if (!doc.exists) return null;
    return Producto.fromMap(doc.id, doc.data()!);
  }
}