import 'package:flutter/material.dart';

const Color colorPrimarioNav = Color(0xFF4F46E5);

class BarraNavegacionAdmin extends StatelessWidget {
  final int indiceActual;
  final void Function(int) onTocar;

  const BarraNavegacionAdmin({
    super.key,
    required this.indiceActual,
    required this.onTocar,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Inicio'),
    (Icons.inventory_2_outlined, Icons.inventory_2, 'Productos'),
    (Icons.people_outline, Icons.people, 'Clientes'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'Reportes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (indice) {
            final seleccionado = indice == indiceActual;
            final color = seleccionado ? colorPrimarioNav : Colors.grey;
            final icono =
                seleccionado ? _items[indice].$2 : _items[indice].$1;

            return InkWell(
              onTap: () => onTocar(indice),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icono, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      _items[indice].$3,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            seleccionado ? FontWeight.w600 : FontWeight.normal,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
