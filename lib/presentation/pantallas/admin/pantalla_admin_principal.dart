import 'package:flutter/material.dart';
import '../../widgets/barra_navegacion_admin.dart';
import 'pantalla_listar_productos.dart';
import 'pantalla_inicio_admin.dart';
import 'pantalla_clientes_admin.dart';
import 'pantalla_reportes_admin.dart';

class PantallaAdminPrincipal extends StatefulWidget {
  final int indiceInicial;

  const PantallaAdminPrincipal({super.key, this.indiceInicial = 1});

  @override
  State<PantallaAdminPrincipal> createState() => _PantallaAdminPrincipalState();
}

class _PantallaAdminPrincipalState extends State<PantallaAdminPrincipal> {
  late int _indice;

  @override
  void initState() {
    super.initState();
    _indice = widget.indiceInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: const [
          PantallaInicioAdmin(),

          PantallaListarProductos(embebido: true),
          PantallaClientesAdmin(),
          PantallaReportesAdmin(),
        ],
      ),
      bottomNavigationBar: BarraNavegacionAdmin(
        indiceActual: _indice,
        onTocar: (i) => setState(() => _indice = i),
      ),
    );
  }
}
