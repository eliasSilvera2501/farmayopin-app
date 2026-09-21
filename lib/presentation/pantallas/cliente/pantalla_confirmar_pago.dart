import 'package:flutter/material.dart';
import '../../../data/remote/repositorio_carrito.dart';
import '../../../data/remote/repositorio_compras.dart';
import '../../../data/remote/repositorio_productos.dart';
import '../../../domain/models/carrito.dart';
import '../../../domain/models/producto.dart';
import '../../widgets/barra_navegacion_inferior.dart';
import 'pantalla_mis_compras.dart';
import 'pantalla_catalogo.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaConfirmarPago extends StatefulWidget {
  const PantallaConfirmarPago({super.key});

  @override
  State<PantallaConfirmarPago> createState() => _PantallaConfirmarPagoState();
}

class _PantallaConfirmarPagoState extends State<PantallaConfirmarPago> {
  final _repositorioCarrito = RepositorioCarrito();
  final _repositorioProductos = RepositorioProductos();
  final _repositorioCompras = RepositorioCompras();

  bool _procesando = false;
  String? _error;

  Future<void> _confirmarYPagar() async {
    setState(() {
      _procesando = true;
      _error = null;
    });

    final error = await _repositorioCompras.confirmarCompra();

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _error = error;
        _procesando = false;
      });
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PantallaCatalogo()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra confirmada ✅')),
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
        title: const Text('Confirmar Pago', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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
              for (var i = 0; i < carrito.items.length; i++) {
                final producto = productos[i];
                if (producto != null) {
                  subtotal += producto.precio * carrito.items[i].cantidad;
                }
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Resumen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${carrito.items.length} Producto${carrito.items.length == 1 ? '' : 's'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Ver Detalles', style: TextStyle(color: colorPrimario)),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _filaResumen('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          _filaResumen('Envío', 'GRATIS'),
                          const Divider(height: 24),
                          _filaResumen('Total', '\$${subtotal.toStringAsFixed(2)}', negrita: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Método de pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorPrimario, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.credit_card, color: colorPrimario),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Tarjeta terminada en 4242', style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cambiar método de pago: próximamente')),
                              );
                            },
                            child: const Text('Editar'),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _procesando ? null : _confirmarYPagar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _procesando
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Confirmar y Pagar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BarraNavegacionInferior(
        indiceActual: 1,
        onTocar: (indice) {
          if (indice == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }
          if (indice == 1) {
            Navigator.pop(context);
            return;
          }
          if (indice == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaMisCompras()));
            return;
          }
          const nombres = ['Inicio', 'Carrito', 'Historial', 'Perfil'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${nombres[indice]}: próximamente')),
          );
        },
      ),
    );
  }

  Widget _filaResumen(String etiqueta, String valor, {bool negrita = false}) {
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
        Text(
          valor,
          style: TextStyle(
            fontSize: negrita ? 18 : 13,
            fontWeight: FontWeight.bold,
            color: negrita ? colorPrimario : Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}
