import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaReportesAdmin extends StatelessWidget {
  const PantallaReportesAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Reportes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('compras').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                double totalVentas = 0;
                int totalItems = 0;
                for (final d in docs) {
                  final data = d.data() as Map<String, dynamic>;
                  totalVentas += (data['total'] ?? 0) as num;
                  final items = data['items'] as List? ?? [];
                  for (final it in items) {
                    totalItems += (it['cantidad'] ?? 0) as int;
                  }
                }
                return Column(
                  children: [
                    _tarjeta(
                      'Ventas totales',
                      '\$${totalVentas.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 12),
                    _tarjeta(
                      'Pedidos realizados',
                      '${docs.length}',
                      Icons.shopping_bag_outlined,
                    ),
                    const SizedBox(height: 12),
                    _tarjeta(
                      'Unidades vendidas',
                      '$totalItems',
                      Icons.inventory_outlined,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Los reportes se calculan en tiempo real desde Firestore.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(String titulo, String valor, IconData icono) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorPrimario.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: colorPrimario),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
