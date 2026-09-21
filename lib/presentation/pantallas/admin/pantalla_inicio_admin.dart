import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/remote/repositorio_autenticacion.dart';
import '../pantalla_login.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaInicioAdmin extends StatelessWidget {
  const PantallaInicioAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = RepositorioAutenticacion();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorPrimario,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_pharmacy, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farmayopin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Panel de administración',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar sesión',
                  onPressed: () async {
                    await auth.cerrarSesion();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const PantallaLogin()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Resumen',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('productos').snapshots(),
              builder: (context, snapProd) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('compras').snapshots(),
                  builder: (context, snapComp) {
                    final nProd = snapProd.data?.docs.length ?? 0;
                    final nComp = snapComp.data?.docs.length ?? 0;
                    double total = 0;
                    for (final d in snapComp.data?.docs ?? []) {
                      total += ((d.data() as Map)['total'] ?? 0) as num;
                    }
                    return Row(
                      children: [
                        Expanded(child: _card('Productos', '$nProd', Icons.inventory_2_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: _card('Pedidos', '$nComp', Icons.receipt_long_outlined)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _card(
                            'Ingresos',
                            '\$${total.toStringAsFixed(0)}',
                            Icons.payments_outlined,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Usá la barra de abajo para ir a Productos, Clientes o Reportes.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorPrimario, size: 22),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
