import 'package:flutter/material.dart';
import '../../../domain/models/producto.dart';
import '../../../data/remote/repositorio_autenticacion.dart';
import '../pantalla_login.dart';
import '../../widgets/barra_navegacion_inferior.dart';
import '../../../data/remote/repositorio_carrito.dart';
import '../../../domain/models/carrito.dart';
import 'pantalla_carrito.dart';
import 'pantalla_mis_compras.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaDetalleProducto extends StatefulWidget {
  final Producto producto;

  const PantallaDetalleProducto({super.key, required this.producto});

  @override
  State<PantallaDetalleProducto> createState() => _PantallaDetalleProductoState();
}

class _PantallaDetalleProductoState extends State<PantallaDetalleProducto> {
  int _cantidad = 1;
  final _repositorioAutenticacion = RepositorioAutenticacion();
  final _repositorioCarrito = RepositorioCarrito();

  void _agregarAlCarrito() {
    _repositorioCarrito.agregarProducto(widget.producto.id, _cantidad);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.producto.nombre} agregado al carrito')),
    );
  }

  void _pestanaAunNoDisponible(String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nombre: próximamente')),
    );
  }

  void _mostrarMenuPerfil() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _repositorioAutenticacion.cerrarSesion();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const PantallaLogin()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final sinStock = producto.stock <= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Detalle del Producto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: producto.fotoUrl.isNotEmpty
                        ? Image.network(
                            producto.fotoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => _iconoPlaceholder(),
                          )
                        : _iconoPlaceholder(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                producto.nombre,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                producto.descripcion,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'SKU: ${producto.sku}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: sinStock ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    sinStock ? 'Sin Stock' : 'En Stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: sinStock ? Colors.red : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '\$${producto.precio.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorPrimario),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cantidad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      _BotonCantidad(
                        icono: Icons.remove,
                        habilitado: _cantidad > 1,
                        onTap: () => setState(() => _cantidad--),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$_cantidad',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _BotonCantidad(
                        icono: Icons.add,
                        habilitado: !sinStock && _cantidad < producto.stock,
                        onTap: () => setState(() => _cantidad++),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: sinStock ? null : _agregarAlCarrito,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    sinStock ? 'Sin Stock' : 'Agregar al Carrito',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StreamBuilder<Carrito>(
        stream: _repositorioCarrito.obtenerCarrito(),
        builder: (context, snapshot) {
          final cantidad = snapshot.data?.items.fold<int>(0, (suma, item) => suma + item.cantidad) ?? 0;
          return BarraNavegacionInferior(
            indiceActual: 0,
            insigniaCarrito: cantidad > 0 ? cantidad : null,
            onTocar: (indice) {
              if (indice == 0) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                return;
              }
              if (indice == 3) {
                _mostrarMenuPerfil();
                return;
              }
              if (indice == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCarrito()));
                return;
              }
              if (indice == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaMisCompras()));
                return;
              }
              const nombres = ['Inicio', 'Carrito', 'Historial', 'Perfil'];
              _pestanaAunNoDisponible(nombres[indice]);
            },
          );
        },
      ),
    );
  }

  Widget _iconoPlaceholder() {
    return const Center(
      child: Icon(Icons.medication_outlined, color: Colors.grey, size: 56),
    );
  }
}

class _BotonCantidad extends StatelessWidget {
  final IconData icono;
  final bool habilitado;
  final VoidCallback onTap;

  const _BotonCantidad({required this.icono, required this.habilitado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: habilitado ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icono, size: 16, color: habilitado ? Colors.black87 : Colors.grey.shade400),
      ),
    );
  }
}
