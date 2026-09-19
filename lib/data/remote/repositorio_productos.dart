import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/models/producto.dart';

class RepositorioProductos {
  final _baseDatos = FirebaseFirestore.instance;
  final _almacenamiento = FirebaseStorage.instance;

  /// Stream en tiempo real: la pantalla se actualiza sola si alguien
  /// (admin u otro dispositivo) cambia un producto en Firestore.
  Stream<List<Producto>> obtenerProductos() {
    return _baseDatos
        .collection('productos')
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
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

  /// Sube una imagen a Firebase Storage y devuelve la URL de descarga.
  /// Si [archivo] es null, devuelve cadena vacía.
  Future<String> _subirImagen(File? archivo, String sku) async {
    if (archivo == null) return '';

    final extension = archivo.path.split('.').last.toLowerCase();
    final nombreArchivo =
        'productos/${sku}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final referencia = _almacenamiento.ref().child(nombreArchivo);

    final metadata = SettableMetadata(
      contentType: 'image/$extension',
      cacheControl: 'public, max-age=31536000',
    );

    await referencia.putFile(archivo, metadata);
    return await referencia.getDownloadURL();
  }

  /// Crea un producto nuevo. Devuelve el id generado o lanza excepción.
  Future<String> crearProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required String sku,
    File? imagen,
  }) async {
    final fotoUrl = await _subirImagen(imagen, sku);

    final docRef = await _baseDatos.collection('productos').add({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'fotoUrl': fotoUrl,
      'sku': sku,
      'creadoEn': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Actualiza un producto existente.
  /// Si se pasa [imagen], se sube una nueva y se reemplaza fotoUrl.
  /// Si [imagen] es null, se mantiene la fotoUrl actual.
  Future<void> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required String sku,
    File? imagen,
    String? fotoUrlActual,
  }) async {
    String fotoUrl = fotoUrlActual ?? '';

    if (imagen != null) {
      fotoUrl = await _subirImagen(imagen, sku);
    }

    await _baseDatos.collection('productos').doc(id).update({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'fotoUrl': fotoUrl,
      'sku': sku,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina el documento del producto.
  Future<void> eliminarProducto(String id) async {
    await _baseDatos.collection('productos').doc(id).delete();
  }
}
