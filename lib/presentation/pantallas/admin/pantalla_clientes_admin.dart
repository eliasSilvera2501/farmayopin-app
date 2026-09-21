import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_historial_cliente.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaClientesAdmin extends StatelessWidget {
  const PantallaClientesAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Clientes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .where('rol', isEqualTo: 'cliente')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('usuarios')
                          .snapshots(),
                      builder: (context, snap2) {
                        if (!snap2.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = snap2.data!.docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return (data['rol'] ?? 'cliente') != 'admin';
                        }).toList();
                        return _lista(context, docs);
                      },
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _lista(context, snapshot.data!.docs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lista(BuildContext context, List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Text(
          'Todavía no hay clientes registrados',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final data = docs[i].data() as Map<String, dynamic>;
        final uid = docs[i].id;
        final nombre = data['nombre'] ?? 'Sin nombre';
        final email = data['email'] ?? '';
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaHistorialCliente(
                    usuarioId: uid,
                    nombre: nombre,
                    email: email,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorPrimario.withValues(alpha: 0.12),
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: colorPrimario,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
