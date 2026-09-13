import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
        // Las tablas locales (caché de productos, carrito) se crearan despues
      },
    );
  }
}