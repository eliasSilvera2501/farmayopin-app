import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/remote/repositorio_productos.dart';
import '../../../domain/models/producto.dart';
import '../../widgets/barra_navegacion_admin.dart';
import 'pantalla_admin_principal.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaEditarProducto extends StatefulWidget {
  final String productoId;

  const PantallaEditarProducto({super.key, required this.productoId});

  @override
  State<PantallaEditarProducto> createState() => _PantallaEditarProductoState();
}

class _PantallaEditarProductoState extends State<PantallaEditarProducto> {
  final _formKey = GlobalKey<FormState>();
  final _repositorio = RepositorioProductos();

  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _fotoUrlCtrl = TextEditingController();

  Producto? _producto;
  File? _imagenNueva;
  bool _cargando = true;
  bool _guardando = false;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final p = await _repositorio.obtenerProductoPorId(widget.productoId);
      if (!mounted) return;
      if (p == null) {
        setState(() {
          _errorCarga = 'Producto no encontrado';
          _cargando = false;
        });
        return;
      }
      _producto = p;
      _nombreCtrl.text = p.nombre;
      _descripcionCtrl.text = p.descripcion;
      _precioCtrl.text = p.precio.toStringAsFixed(2);
      _stockCtrl.text = p.stock.toString();
      _skuCtrl.text = p.sku;
      _fotoUrlCtrl.text = p.fotoUrl;
      setState(() => _cargando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCarga = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _fotoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen() async {
    final picker = ImagePicker();
    final archivo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (archivo == null) return;
    setState(() => _imagenNueva = File(archivo.path));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _producto == null) return;

    setState(() => _guardando = true);

    try {
      await _repositorio.actualizarProducto(
        id: widget.productoId,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        precio: double.parse(_precioCtrl.text.trim().replaceAll(',', '.')),
        stock: int.parse(_stockCtrl.text.trim()),
        sku: _skuCtrl.text.trim().toUpperCase(),
        imagen: _imagenNueva,
        fotoUrlActual: _producto!.fotoUrl,
        fotoUrlManual: _fotoUrlCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  InputDecoration _decoracion(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: colorPrimario, width: 1.5),
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorCarga != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar')),
        body: Center(child: Text(_errorCarga!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Editar Producto',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _elegirImagen,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _imagenNueva != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _imagenNueva!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : (_producto!.fotoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              _producto!.fotoUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            ),
                          )
                        : _placeholder()),
              ),
            ),
            if (_imagenNueva != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _imagenNueva = null),
                child: const Text('Quitar imagen nueva'),
              ),
            ],
            const SizedBox(height: 14),
            _etiqueta('URL de la foto'),
            TextFormField(
              controller: _fotoUrlCtrl,
              decoration: _decoracion('https://...'),
            ),
            const SizedBox(height: 14),
            _etiqueta('Nombre del Producto *'),
            TextFormField(
              controller: _nombreCtrl,
              decoration: _decoracion('Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 14),
            _etiqueta('SKU'),
            TextFormField(
              controller: _skuCtrl,
              decoration: _decoracion('SKU'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 14),
            _etiqueta('Descripción'),
            TextFormField(
              controller: _descripcionCtrl,
              decoration: _decoracion('Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _etiqueta('Precio (\$) *'),
                      TextFormField(
                        controller: _precioCtrl,
                        decoration: _decoracion('0.00'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          if (double.tryParse(v.replaceAll(',', '.')) == null) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _etiqueta('Stock *'),
                      TextFormField(
                        controller: _stockCtrl,
                        decoration: _decoracion('0'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          if (int.tryParse(v) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimario,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar Producto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BarraNavegacionAdmin(
        indiceActual: 1,
        onTocar: (i) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => PantallaAdminPrincipal(indiceInicial: i),
            ),
            (_) => false,
          );
        },
      ),
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'Tocar para cambiar imagen',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }
}
