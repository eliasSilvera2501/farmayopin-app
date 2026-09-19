import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/remote/repositorio_productos.dart';
import '../../../domain/models/producto.dart';

const Color colorPrimario = Color(0xFF4F46E5);

class PantallaEditarProducto extends StatefulWidget {
  final Producto producto;

  const PantallaEditarProducto({super.key, required this.producto});

  @override
  State<PantallaEditarProducto> createState() => _PantallaEditarProductoState();
}

class _PantallaEditarProductoState extends State<PantallaEditarProducto> {
  final _formKey = GlobalKey<FormState>();
  final _repositorio = RepositorioProductos();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _skuCtrl;

  File? _imagenNueva;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p.nombre);
    _descripcionCtrl = TextEditingController(text: p.descripcion);
    _precioCtrl = TextEditingController(text: p.precio.toStringAsFixed(2));
    _stockCtrl = TextEditingController(text: p.stock.toString());
    _skuCtrl = TextEditingController(text: p.sku);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      await _repositorio.actualizarProducto(
        id: widget.producto.id,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        precio: double.parse(_precioCtrl.text.trim().replaceAll(',', '.')),
        stock: int.parse(_stockCtrl.text.trim()),
        sku: _skuCtrl.text.trim().toUpperCase(),
        imagen: _imagenNueva,
        fotoUrlActual: widget.producto.fotoUrl,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
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

  Widget _vistaImagen() {
    if (_imagenNueva != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          _imagenNueva!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
        ),
      );
    }

    if (widget.producto.fotoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          widget.producto.fotoUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Toca para cambiar la imagen',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
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
          'Editar producto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              GestureDetector(
                onTap: _guardando ? null : _elegirImagen,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _vistaImagen(),
                ),
              ),

              if (_imagenNueva != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => setState(() => _imagenNueva = null),
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Descartar imagen nueva'),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              _etiqueta('Nombre *'),
              TextFormField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoracion('Nombre del producto'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _etiqueta('SKU *'),
              TextFormField(
                controller: _skuCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: _decoracion('SKU'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El SKU es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _etiqueta('Descripción'),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoracion('Descripción…'),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _etiqueta('Precio *'),
                        TextFormField(
                          controller: _precioCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,]'),
                            ),
                          ],
                          decoration: _decoracion('0.00'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Obligatorio';
                            }
                            final n =
                                double.tryParse(v.trim().replaceAll(',', '.'));
                            if (n == null || n < 0) return 'Precio inválido';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _etiqueta('Stock *'),
                        TextFormField(
                          controller: _stockCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _decoracion('0'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Obligatorio';
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 0) return 'Stock inválido';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        colorPrimario.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
