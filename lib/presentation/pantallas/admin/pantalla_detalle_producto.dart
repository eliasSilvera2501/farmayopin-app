import 'package:flutter/material.dart';
import '../../../data/remote/repositorio_productos.dart';
import '../../../domain/models/producto.dart';
import 'pantalla_editar_producto.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaDetalleProducto extends StatefulWidget {
  final String productoId;

  const PantallaDetalleProducto({super.key, required this.productoId});

  @override
  State<PantallaDetalleProducto> createState() =>
      _PantallaDetalleProductoState();
}

class _PantallaDetalleProductoState extends State<PantallaDetalleProducto> {
  final _repositorio = RepositorioProductos();
  Producto? _producto;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final p = await _repositorio.obtenerProductoPorId(widget.productoId);
      if (!mounted) return;
      setState(() {
        _producto = p;
        _cargando = false;
        if (p == null) _error = 'Producto no encontrado';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Seguro que querés eliminar “${_producto?.nombre ?? 'este producto'}”? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _repositorio.eliminarProducto(widget.productoId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _irAEditar() async {
    if (_producto == null) return;
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaEditarProducto(producto: _producto!),
      ),
    );
    if (actualizado == true && mounted) {
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Detalle del producto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_producto != null) ...[
            IconButton(
              tooltip: 'Editar',
              onPressed: _irAEditar,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: _eliminar,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ],
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: colorPrimario),
      );
    }

    if (_error != null || _producto == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Producto no encontrado',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final p = _producto!;
    final sinStock = p.stock <= 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: p.fotoUrl.isNotEmpty
              ? Image.network(
                  p.fotoUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImagen(),
                )
              : _placeholderImagen(),
        ),

        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                p.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: sinStock ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sinStock ? 'Sin stock' : 'Stock: ${p.stock}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sinStock ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'SKU: ${p.sku}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 16),

        Text(
          '\$${p.precio.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorPrimario,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          p.descripcion.isEmpty ? 'Sin descripción' : p.descripcion,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: p.descripcion.isEmpty
                ? Colors.grey.shade400
                : Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _irAEditar,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorPrimario,
                  side: const BorderSide(color: colorPrimario),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _eliminar,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _placeholderImagen() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.medication_outlined,
        size: 64,
        color: Colors.grey.shade400,
      ),
    );
  }
}
