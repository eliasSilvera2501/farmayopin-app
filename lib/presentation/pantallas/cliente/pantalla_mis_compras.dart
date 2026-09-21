import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/remote/repositorio_carrito.dart';
import '../../../data/remote/repositorio_compras.dart';
import '../../../domain/models/compra.dart';
import '../../widgets/barra_navegacion_inferior.dart';
import 'pantalla_carrito.dart';

const Color colorPrimario = Color(0xFF4F46E5);
const Color colorFondoLavanda = Color(0xFFF3F2FA);

const _nombresMes = [
  '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

String _formatearFecha(DateTime fecha) {
  final ahora = DateTime.now();
  final horaMin = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  final esHoy = fecha.year == ahora.year && fecha.month == ahora.month && fecha.day == ahora.day;
  if (esHoy) return 'Hoy, $horaMin hs';
  return '${fecha.day} ${_nombresMes[fecha.month]} ${fecha.year}, $horaMin hs';
}

class PantallaMisCompras extends StatelessWidget {
  const PantallaMisCompras({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repositorioCompras = RepositorioCompras();
    final repositorioCarrito = RepositorioCarrito();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Mis Compras', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: StreamBuilder<List<Compra>>(
        stream: repositorioCompras.historicoDeUsuario(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar el historial:\n${snapshot.error}',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final compras = snapshot.data!;
          if (compras.isEmpty) {
            return Center(
              child: Text('Todavía no hiciste ninguna compra', style: TextStyle(color: Colors.grey.shade600)),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: colorFondoLavanda, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Historial de Pedidos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            '${compras.length} pedido${compras.length == 1 ? '' : 's'}',
                            style: const TextStyle(fontSize: 11, color: colorPrimario, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Text('Agrupados por estado', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...compras.map(
                (compra) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaPedido(
                    compra: compra,
                    onVolverAComprar: () async {
                      for (final item in compra.items) {
                        await repositorioCarrito.agregarProducto(item.productoId, item.cantidad);
                      }
                      if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCarrito()));
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BarraNavegacionInferior(
        indiceActual: 2,
        onTocar: (indice) {
          if (indice == 2) return;
          if (indice == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }
          if (indice == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCarrito()));
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil: próximamente')),
          );
        },
      ),
    );
  }
}

class _TarjetaPedido extends StatelessWidget {
  final Compra compra;
  final VoidCallback onVolverAComprar;

  const _TarjetaPedido({required this.compra, required this.onVolverAComprar});

  @override
  Widget build(BuildContext context) {
    final entregado = compra.estado == 'entregado';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${compra.numeroOrden}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(_formatearFecha(compra.fecha), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: entregado ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entregado ? Icons.check_circle : Icons.local_shipping_outlined,
                      size: 13,
                      color: entregado ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entregado ? 'Entregado' : 'En camino',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: entregado ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    compra.metodoEntrega.toLowerCase().contains('sucursal') ? Icons.storefront_outlined : Icons.local_shipping_outlined,
                    size: 14,
                    color: colorPrimario,
                  ),
                  const SizedBox(width: 6),
                  Text(compra.metodoEntrega, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Text(compra.metodoPago, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          const Divider(height: 20),
          ...compra.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: colorFondoLavanda, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.medication_outlined, size: 18, color: colorPrimario),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(
                          '${item.sku} • ${item.cantidad} unidad${item.cantidad == 1 ? '' : 'es'}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${(item.precioUnitario * item.cantidad).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 8),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total pagado', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text(
                    '\$${compra.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorPrimario),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onVolverAComprar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorPrimario,
                  backgroundColor: colorFondoLavanda,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.replay, size: 15),
                label: const Text('Volver a comprar', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
