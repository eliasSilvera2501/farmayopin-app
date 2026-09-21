import 'package:flutter/material.dart';
import '../../../data/remote/repositorio_compras.dart';
import '../../../domain/models/compra.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaHistorialCliente extends StatelessWidget {
  final String usuarioId;
  final String nombre;
  final String email;

  const PantallaHistorialCliente({
    super.key,
    required this.usuarioId,
    required this.nombre,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final repo = RepositorioCompras();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Historial del Cliente',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<List<Compra>>(
        stream: repo.historicoDeUsuario(usuarioId),
        builder: (context, snapshot) {
          final compras = snapshot.data ?? [];
          final total = compras.fold<double>(0, (s, c) => s + c.total);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorPrimario.withValues(alpha: 0.12),
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          color: colorPrimario,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _stat('${compras.length} facturas', 'Pedidos totales'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _stat(
                      '\$${total.toStringAsFixed(2)}',
                      'Gasto total',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Historial de Compras',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const Center(child: CircularProgressIndicator())
              else if (compras.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Este cliente todavía no tiene compras',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                ...compras.map((c) => _tarjetaCompra(c)),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String valor, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorPrimario,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _tarjetaCompra(Compra c) {
    final fecha =
        '${c.fecha.day.toString().padLeft(2, '0')}/${c.fecha.month.toString().padLeft(2, '0')}/${c.fecha.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fecha, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(
                c.numeroOrden,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...c.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${item.nombre}  ×${item.cantidad}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total pagado  \$${c.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
