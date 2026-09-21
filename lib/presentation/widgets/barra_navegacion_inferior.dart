import 'package:flutter/material.dart';

const Color colorPrimarioNav = Color(0xFF4F46E5);

class BarraNavegacionInferior extends StatelessWidget {
  final int indiceActual;
  final void Function(int) onTocar;
  final int? insigniaCarrito;

  const BarraNavegacionInferior({
    super.key,
    required this.indiceActual,
    required this.onTocar,
    this.insigniaCarrito,
  });

  static const _items = [
    (Icons.home_outlined, 'Inicio'),
    (Icons.shopping_cart_outlined, 'Carrito'),
    (Icons.receipt_long_outlined, 'Historial'),
    (Icons.person_outline, 'Perfil'),
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
            final mostrarInsignia = indice == 1 && insigniaCarrito != null && insigniaCarrito! > 0;

            return InkWell(
              onTap: () => onTocar(indice),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(_items[indice].$1, color: color, size: 24),
                      if (mostrarInsignia)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: const BoxDecoration(
                              color: colorPrimarioNav,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${insigniaCarrito! > 9 ? '9+' : insigniaCarrito}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _items[indice].$2,
                    style: TextStyle(color: color, fontSize: 11, fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
