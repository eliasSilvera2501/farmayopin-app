import 'package:flutter/material.dart';
import '../../../data/remote/repositorio_autenticacion.dart';
import '../../../data/remote/repositorio_productos.dart';
import '../../../domain/models/producto.dart';
import '../pantalla_login.dart';
import 'pantalla_crear_producto.dart';
import 'pantalla_detalle_producto.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaListarProductos extends StatefulWidget {
  const PantallaListarProductos({super.key});

  @override
  State<PantallaListarProductos> createState() =>
      _PantallaListarProductosState();
}

class _PantallaListarProductosState extends State<PantallaListarProductos> {
  final _repositorioProductos = RepositorioProductos();
  final _repositorioAutenticacion = RepositorioAutenticacion();
  final _controladorBusqueda = TextEditingController();
  String _textoBusqueda = '';

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  List<Producto> _filtrar(List<Producto> productos) {
    if (_textoBusqueda.trim().isEmpty) return productos;
    final q = _textoBusqueda.toLowerCase().trim();
    return productos.where((p) {
      return p.nombre.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          p.descripcion.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
            '¿Seguro que querés salir del panel de administrador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await _repositorioAutenticacion.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaLogin()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Encabezado ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorPrimario,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administración',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Gestión de inventario',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                  ),
                ],
              ),
            ),

            // ── Buscador ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _controladorBusqueda,
                onChanged: (v) => setState(() => _textoBusqueda = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, SKU o descripción…',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  suffixIcon: _textoBusqueda.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _controladorBusqueda.clear();
                            setState(() => _textoBusqueda = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: colorPrimario, width: 1.5),
                  ),
                ),
              ),
            ),

            // ── Contador + lista ────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<Producto>>(
                stream: _repositorioProductos.obtenerProductos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: colorPrimario),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Error al cargar productos:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    );
                  }

                  final todos = snapshot.data ?? [];
                  final productos = _filtrar(todos);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Row(
                          children: [
                            Text(
                              'Todo el inventario',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorPrimario.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${productos.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimario,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: productos.isEmpty
                            ? _ListaVacia(
                                hayBusqueda: _textoBusqueda.isNotEmpty)
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 88),
                                itemCount: productos.length,
                                itemBuilder: (context, index) {
                                  return _TarjetaProducto(
                                    producto: productos[index],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PantallaDetalleProducto(
                                            productoId: productos[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PantallaCrearProducto()),
          );
        },
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
    );
  }
}

// ─── Lista vacía ────────────────────────────────────────────────────────────

class _ListaVacia extends StatelessWidget {
  final bool hayBusqueda;
  const _ListaVacia({required this.hayBusqueda});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hayBusqueda ? Icons.search_off : Icons.inventory_2_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hayBusqueda
                  ? 'No se encontraron productos'
                  : 'Aún no hay productos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hayBusqueda
                  ? 'Probá con otro término de búsqueda'
                  : 'Tocá el botón “Nuevo producto” para agregar el primero',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de producto ────────────────────────────────────────────────────

class _TarjetaProducto extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const _TarjetaProducto({required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sinStock = producto.stock <= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: producto.fotoUrl.isNotEmpty
                      ? Image.network(
                          producto.fotoUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImagen(),
                        )
                      : _placeholderImagen(),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${producto.sku}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '\$${producto.precio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: colorPrimario,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sinStock
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sinStock
                                  ? 'Sin stock'
                                  : 'Stock: ${producto.stock}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: sinStock
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImagen() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey.shade100,
      child: Icon(Icons.medication_outlined, color: Colors.grey.shade400),
    );
  }
}
