import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/models/producto.dart';

class GestorBaseDatos {
  static final GestorBaseDatos _instancia = GestorBaseDatos._interno();
  factory GestorBaseDatos() => _instancia;
  GestorBaseDatos._interno();

  Database? _baseDatos;

  Future<Database> get baseDatos async {
    if (_baseDatos != null) return _baseDatos!;
    _baseDatos = await _inicializarBaseDatos();
    return _baseDatos!;
  }

  Future<Database> _inicializarBaseDatos() async {
    final ruta = await getDatabasesPath();
    final rutaBaseDatos = join(ruta, 'farmayopin.db');
    return await openDatabase(
      rutaBaseDatos,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE productos (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            descripcion TEXT,
            precio REAL NOT NULL,
            stock INTEGER NOT NULL,
            fotoUrl TEXT,
            sku TEXT
          )
        ''');
      },
    );
  }

  Future<void> guardarProductos(List<Producto> productos) async {
    final db = await baseDatos;
    final batch = db.batch();
    batch.delete('productos');
    for (final p in productos) {
      batch.insert('productos', {
        'id': p.id,
        'nombre': p.nombre,
        'descripcion': p.descripcion,
        'precio': p.precio,
        'stock': p.stock,
        'fotoUrl': p.fotoUrl,
        'sku': p.sku,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Producto>> obtenerProductosLocales() async {
    final db = await baseDatos;
    final filas = await db.query('productos', orderBy: 'nombre ASC');
    return filas
        .map(
          (f) => Producto(
            id: f['id'] as String,
            nombre: f['nombre'] as String? ?? '',
            descripcion: f['descripcion'] as String? ?? '',
            precio: (f['precio'] as num?)?.toDouble() ?? 0,
            stock: f['stock'] as int? ?? 0,
            fotoUrl: f['fotoUrl'] as String? ?? '',
            sku: f['sku'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<void> eliminarProductoLocal(String id) async {
    final db = await baseDatos;
    await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertProductoLocal(Producto p) async {
    final db = await baseDatos;
    await db.insert(
      'productos',
      {
        'id': p.id,
        'nombre': p.nombre,
        'descripcion': p.descripcion,
        'precio': p.precio,
        'stock': p.stock,
        'fotoUrl': p.fotoUrl,
        'sku': p.sku,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
