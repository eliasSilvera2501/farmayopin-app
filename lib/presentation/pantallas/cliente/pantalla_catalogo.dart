import 'package:flutter/material.dart';
import '../../../data/remote/repositorio_productos.dart';
import '../../../data/remote/repositorio_autenticacion.dart';
import '../../../domain/models/producto.dart';
import '../../../domain/models/carrito.dart';
import '../pantalla_login.dart';
import 'pantalla_detalle_producto.dart';
import 'pantalla_carrito.dart';
import '../../widgets/barra_navegacion_inferior.dart';
import '../../../data/remote/repositorio_carrito.dart';
import 'pantalla_mis_compras.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaCatalogo extends StatefulWidget {
  const PantallaCatalogo({super.key});

  @override
  State<PantallaCatalogo> createState() => _PantallaCatalogoState();
}

class _PantallaCatalogoState extends State<PantallaCatalogo> {
  final _repositorioProductos = RepositorioProductos();
  final _repositorioAutenticacion = RepositorioAutenticacion();
  final _repositorioCarrito = RepositorioCarrito();
  int _pestanaActual = 0;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorPrimario,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Productos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.black54),
                    onPressed: () => _pestanaAunNoDisponible('Buscar'),
                  ),
                ],
              ),
            ),

            StreamBuilder<List<Producto>>(
              stream: _repositorioProductos.obtenerProductos(),
              builder: (context, snapshot) {
                final cantidad = snapshot.data?.length ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              'Todo el Inventario',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more, size: 18, color: Colors.black54),
                          ],
                        ),
                      ),
                      Text(
                        '$cantidad artículos',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => _pestanaAunNoDisponible('Filtro'),
                        icon: const Icon(Icons.tune, size: 16),
                        label: const Text('Filtros', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            Expanded(
              child: StreamBuilder<List<Producto>>(
                stream: _repositorioProductos.obtenerProductos(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar productos: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final productos = snapshot.data!;
                  if (productos.isEmpty) {
                    return const Center(child: Text('No hay productos cargados todavía'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: productos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _FilaProducto(producto: productos[index], repositorioCarrito: _repositorioCarrito),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder<Carrito>(
        stream: _repositorioCarrito.obtenerCarrito(),
        builder: (context, snapshot) {
          final cantidad = snapshot.data?.items.fold<int>(0, (suma, item) => suma + item.cantidad) ?? 0;
          return BarraNavegacionInferior(
            indiceActual: _pestanaActual,
            insigniaCarrito: cantidad > 0 ? cantidad : null,
            onTocar: (indice) {
              if (indice == 0) {
                setState(() => _pestanaActual = indice);
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
}
class _FilaProducto extends StatelessWidget {
  final Producto producto;
  final RepositorioCarrito repositorioCarrito;

  const _FilaProducto({required this.producto, required this.repositorioCarrito});

  @override
  Widget build(BuildContext context) {
    final sinStock = producto.stock <= 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PantallaDetalleProducto(producto: producto)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: producto.fotoUrl.isNotEmpty
                  ? Image.network(
                      producto.fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _iconoPlaceholder(),
                    )
                  : _iconoPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  producto.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'SKU: ${producto.sku}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: sinStock ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sinStock ? 'Sin Stock' : 'En Stock',
                      style: TextStyle(
                        fontSize: 11,
                        color: sinStock ? Colors.red : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${producto.precio.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorPrimario),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: sinStock
                    ? null
                    : () {
                        repositorioCarrito.agregarProducto(producto.id, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${producto.nombre} agregado al carrito')),
                        );
                      },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: sinStock ? Colors.grey.shade300 : colorPrimario,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _iconoPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.medication_outlined, color: Colors.grey, size: 24),
      ),
    );
  }
}
