import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/models/producto.dart';
import '../local/gestor_base_datos.dart';

class RepositorioProductos {
  final _baseDatos = FirebaseFirestore.instance;
  final _almacenamiento = FirebaseStorage.instance;
  final _cacheLocal = GestorBaseDatos();

  Stream<List<Producto>> obtenerProductos() {
    return _baseDatos
        .collection('productos')
        .orderBy('nombre')
        .snapshots()
        .asyncMap((snapshot) async {
      final productos = snapshot.docs
          .map((doc) => Producto.fromMap(doc.id, doc.data()))
          .toList();

      try {
        await _cacheLocal.guardarProductos(productos);
      } catch (_) {

      }
      return productos;
    });
  }

  Future<List<Producto>> obtenerProductosDesdeCache() {
    return _cacheLocal.obtenerProductosLocales();
  }

  Future<Producto?> obtenerProductoPorId(String id) async {
    final doc = await _baseDatos.collection('productos').doc(id).get();
    if (!doc.exists) return null;
    return Producto.fromMap(doc.id, doc.data()!);
  }

  Future<String> _subirImagen(File? archivo, String sku) async {
    if (archivo == null) return '';
    try {
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
    } catch (_) {

      return '';
    }
  }

  Future<String> crearProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required String sku,
    File? imagen,
    String fotoUrlManual = '',
  }) async {
    String fotoUrl = await _subirImagen(imagen, sku);
    if (fotoUrl.isEmpty) {
      fotoUrl = fotoUrlManual.trim();
    }

    final docRef = await _baseDatos.collection('productos').add({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'fotoUrl': fotoUrl,
      'sku': sku,
      'creadoEn': FieldValue.serverTimestamp(),
    });

    try {
      await _cacheLocal.upsertProductoLocal(
        Producto(
          id: docRef.id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          stock: stock,
          fotoUrl: fotoUrl,
          sku: sku,
        ),
      );
    } catch (_) {}

    return docRef.id;
  }

  Future<void> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required String sku,
    File? imagen,
    String? fotoUrlActual,
    String fotoUrlManual = '',
  }) async {
    String fotoUrl = fotoUrlActual ?? '';

    if (imagen != null) {
      final subida = await _subirImagen(imagen, sku);
      if (subida.isNotEmpty) {
        fotoUrl = subida;
      }
    } else if (fotoUrlManual.trim().isNotEmpty) {
      fotoUrl = fotoUrlManual.trim();
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

    try {
      await _cacheLocal.upsertProductoLocal(
        Producto(
          id: id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          stock: stock,
          fotoUrl: fotoUrl,
          sku: sku,
        ),
      );
    } catch (_) {}
  }

  Future<void> eliminarProducto(String id) async {
    await _baseDatos.collection('productos').doc(id).delete();
    try {
      await _cacheLocal.eliminarProductoLocal(id);
    } catch (_) {}
  }
}
