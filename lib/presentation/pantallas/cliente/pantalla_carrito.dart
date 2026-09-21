import 'package:flutter/material.dart';
import '../../../data/remote/repositorio_carrito.dart';
import '../../../data/remote/repositorio_productos.dart';
import '../../../domain/models/carrito.dart';
import '../../../domain/models/producto.dart';
import '../../widgets/barra_navegacion_inferior.dart';
import 'pantalla_confirmar_pago.dart';
import 'pantalla_mis_compras.dart';

const Color colorPrimario = Color(0xFF4F46E5);
const int _stockBajoUmbral = 3;

class PantallaCarrito extends StatefulWidget {
  const PantallaCarrito({super.key});

  @override
  State<PantallaCarrito> createState() => _PantallaCarritoState();
}

class _PantallaCarritoState extends State<PantallaCarrito> {
  final _repositorioCarrito = RepositorioCarrito();
  final _repositorioProductos = RepositorioProductos();

  void _pestanaAunNoDisponible(String nombre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nombre: próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Mi Carrito', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: StreamBuilder<Carrito>(
        stream: _repositorioCarrito.obtenerCarrito(),
        builder: (context, snapshotCarrito) {
          if (!snapshotCarrito.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final carrito = snapshotCarrito.data!;
          if (carrito.items.isEmpty) {
            return Center(
              child: Text('Tu carrito está vacío', style: TextStyle(color: Colors.grey.shade600)),
            );
          }

          return FutureBuilder<List<Producto?>>(
            future: Future.wait(
              carrito.items.map((item) => _repositorioProductos.obtenerProductoPorId(item.productoId)),
            ),
            builder: (context, snapshotProductos) {
              if (!snapshotProductos.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final productos = snapshotProductos.data!;
              double subtotal = 0;
              int cantidadTotal = 0;
              for (var i = 0; i < carrito.items.length; i++) {
                final producto = productos[i];
                if (producto != null) {
                  subtotal += producto.precio * carrito.items[i].cantidad;
                  cantidadTotal += carrito.items[i].cantidad;
                }
              }

              return Column(
                children: [

                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${carrito.items.length} artículos',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colorPrimario),
                        ),
                        Text(
                          'Precios actualizados en vivo',
                          style: TextStyle(fontSize: 11, color: colorPrimario.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: carrito.items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = carrito.items[index];
                        final producto = productos[index];

                        if (producto == null) {
                          return const SizedBox.shrink();
                        }

                        return _FilaCarrito(
                          producto: producto,
                          cantidad: item.cantidad,
                          onSumar: () {
                            _repositorioCarrito.actualizarCantidad(producto.id, item.cantidad + 1);
                          },
                          onRestar: () {
                            _repositorioCarrito.actualizarCantidad(producto.id, item.cantidad - 1);
                          },
                          onEliminar: () {
                            _repositorioCarrito.eliminarProducto(producto.id);
                          },
                        );
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      children: [
                        _filaResumen('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _filaResumen('Envío', 'GRATIS', valorSecundario: '\$0.00'),
                        const Divider(height: 20),
                        _filaResumen(
                          'Total',
                          '\$${subtotal.toStringAsFixed(2)}',
                          negrita: true,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PantallaConfirmarPago()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrimario,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Pagar Carrito', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<Carrito>(
        stream: _repositorioCarrito.obtenerCarrito(),
        builder: (context, snapshot) {
          final cantidad = snapshot.data?.items.fold<int>(0, (suma, item) => suma + item.cantidad) ?? 0;
          return BarraNavegacionInferior(
            indiceActual: 1,
            insigniaCarrito: cantidad > 0 ? cantidad : null,
            onTocar: (indice) {
              if (indice == 1) return;
              if (indice == 0) {
                Navigator.of(context).popUntil((route) => route.isFirst);
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

  Widget _filaResumen(String etiqueta, String valor, {String? valorSecundario, bool negrita = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            fontSize: negrita ? 16 : 13,
            fontWeight: negrita ? FontWeight.bold : FontWeight.normal,
            color: negrita ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Row(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: negrita ? 18 : 13,
                fontWeight: FontWeight.bold,
                color: negrita ? colorPrimario : Colors.green.shade700,
              ),
            ),
            if (valorSecundario != null) ...[
              const SizedBox(width: 4),
              Text(
                valorSecundario,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400, decoration: TextDecoration.lineThrough),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _FilaCarrito extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final VoidCallback onSumar;
  final VoidCallback onRestar;
  final VoidCallback onEliminar;

  const _FilaCarrito({
    required this.producto,
    required this.cantidad,
    required this.onSumar,
    required this.onRestar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final stockBajo = producto.stock > 0 && producto.stock <= _stockBajoUmbral;
    final sinStock = producto.stock <= 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                        Text('SKU: ${producto.sku}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: sinStock
                                ? Colors.red
                                : (stockBajo ? Colors.orange : Colors.green),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sinStock
                              ? 'Sin Stock'
                              : (stockBajo ? 'Quedan ${producto.stock} unidades' : 'En Stock'),
                          style: TextStyle(
                            fontSize: 11,
                            color: sinStock
                                ? Colors.red
                                : (stockBajo ? Colors.orange.shade800 : Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorPrimario),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onEliminar,
                    child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),

          if (stockBajo) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '¡Quedan pocas unidades! Stock restante: ${producto.stock} un.',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${producto.precio.toStringAsFixed(2)} c/u',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Row(
                children: [
                  _botonRedondo(icono: Icons.remove, onTap: onRestar),
                  SizedBox(
                    width: 30,
                    child: Text('$cantidad', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  _botonRedondo(icono: Icons.add, onTap: cantidad < producto.stock ? onSumar : null),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonRedondo({required IconData icono, VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icono, size: 14, color: onTap == null ? Colors.grey.shade300 : Colors.black87),
      ),
    );
  }

  Widget _iconoPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.medication_outlined, color: Colors.grey, size: 24)),
    );
  }
}
