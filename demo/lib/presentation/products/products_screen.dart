import 'package:demo/presentation/widget/layout/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

// Formatter to keep a fixed, non-deletable prefix at the start of the field.
class PrefixTextInputFormatter extends TextInputFormatter {
  final String prefix;
  PrefixTextInputFormatter(this.prefix);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If new text is shorter than prefix, restore prefix
    if (newValue.text.length < prefix.length) {
      return TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    }

    String text = newValue.text;

    // If user removed/modified the prefix, reinsert it at the start.
    if (!text.startsWith(prefix)) {
      // Remove any occurrences of the prefix elsewhere and prepend it
      final rest = text.replaceAll(prefix, '');
      text = prefix + rest;
    }

    // Ensure the cursor/selection is not placed inside the prefix
    int selectionIndex = newValue.selection.end;
    if (selectionIndex < prefix.length) selectionIndex = prefix.length;
    if (selectionIndex > text.length) selectionIndex = text.length;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  static const String name = "product_screen";
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Controladores
  final _productIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _stockController = TextEditingController();

  String? _selectedProductType;

  bool _isLoading = false;
  bool _isProductIdTaken = false;

  static const _productPrefix = 'PROD-';

  @override
  void initState() {
    super.initState();
    // Initialize product ID with prefix and place cursor at the end
    _productIdController.text = _productPrefix;
    _productIdController.selection = TextSelection.collapsed(
      offset: _productPrefix.length,
    );
  }

  @override
  void dispose() {
    _unitPriceController.removeListener(_onPriceChanged);
    _productIdController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _unitPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  _onPriceChanged() {
    if (_isEditing) return;

    _isEditing = true;

    String texto = _unitPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (texto.isEmpty) {
      _unitPriceController.text = '';
    } else {
      final numero = int.parse(texto);
      _unitPriceController.text = _formatter.format(numero);
      _unitPriceController.selection = TextSelection.fromPosition(
        TextPosition(offset: _unitPriceController.text.length),
      );
    }

    _isEditing = false;
  }

  // Validar ID del producto (PROD-00000)
  String? _validateProductId(String? value) {
    if (value == null || value.isEmpty) {
      return 'El ID del producto es requerido';
    }
    if (!value.startsWith('PROD-')) {
      return 'Debe empezar con PROD-';
    }
    if (value.length > 10) {
      return 'Máximo 10 caracteres (PROD-00000)';
    }
    // Verificar que después de PROD- solo haya números
    final idNumber = value.substring(5);
    if (idNumber.isEmpty || int.tryParse(idNumber) == null) {
      return 'Después de PROD- debe haber números';
    }
    return null;
  }

  // Comprueba si el productId ya existe en el servidor
  Future<bool> _checkProductIdExists(String id) async {
    try {
      final resp = await _apiService.getProducts();
      if (!resp.isSuccess || resp.data == null) return false;
      return resp.data!.any((p) => (p.productId ?? '') == id);
    } catch (_) {
      // En caso de error, no bloqueamos el flujo; retornamos false para permitir guardar
      return false;
    }
  }

  // Validación asíncrona invocada al terminar de editar el campo
  Future<void> _validateUniqueProductId() async {
    final id = _productIdController.text;
    // Solo verificar si cumple el formato mínimo
    if (id.isEmpty || !id.startsWith(_productPrefix)) return;
    final exists = await _checkProductIdExists(id);
    if (exists) {
      setState(() {
        _isProductIdTaken = true;
      });
      _showError(
        'ID del producto ya utilizado, por favor escribir uno diferente',
      );
    } else {
      if (_isProductIdTaken) {
        setState(() {
          _isProductIdTaken = false;
        });
      }
    }
  }

  // Validar nombre
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < 3) {
      return 'Debe tener al menos 3 caracteres';
    }
    if (value.length > 25) {
      return 'Máximo 25 caracteres';
    }
    return null;
  }

  // Validar precio unitario
  String? _validateUnitPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    String precioLimpio = value.replaceAll(RegExp(r'[^0-9]'), '');
    final price = int.tryParse(precioLimpio);
    if (price == null) {
      return 'Ingrese un precio válido';
    }
    if (price <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    if (price > 100000000) {
      return 'Máximo 100 millones';
    }
    return null;
  }

  // Validar stock
  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'El stock es requerido';
    }
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Ingrese solo números';
    }
    if (stock < 0) {
      return 'No puede ser negativo';
    }
    if (stock > 100000) {
      return 'Máximo 100,000 unidades';
    }
    return null;
  }

  // Mostrar error con SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      margin: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 20.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  // Mostrar exito con SnackBar
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      margin: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 20.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  // Limpiar formulario
  void _clearForm() {
    _formKey.currentState?.reset();
    // Keep the prefix in the product ID field
    _productIdController.text = _productPrefix;
    _productIdController.selection = TextSelection.collapsed(
      offset: _productPrefix.length,
    );
    _nameController.clear();
    _descriptionController.clear();
    _unitPriceController.clear();
    _stockController.clear();
    setState(() {
      _selectedProductType = null;
    });
  }

  // Guardar producto
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductType == null) {
      _showError('Debe seleccionar un tipo de producto');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        productId: _productIdController.text,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? ''
            : _descriptionController.text,
        unitPrice: int.parse(_unitPriceController.text),
        stock: int.parse(_stockController.text),
        productType: _selectedProductType!,
      );

    final product = Product(
      productId: _productIdController.text,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty 
          ? '' 
          : _descriptionController.text,
      unitPrice: int.parse(precioLimpio),
      stock: int.parse(_stockController.text),
      productType: _selectedProductType!,
    );

    final result = await _apiService.createProduct(product);

    setState(() {
      _isLoading = false;
      
    });

    if (result == 'Producto creado exitosamente') {
      _showSuccess(result);
      _clearForm();
    } else {
      _showError(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Producto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: DrawerWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Id del Producto
                    TextFormField(
                      controller: _productIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID del Producto *',
                        hintText: 'PROD-1, PROD-123, PROD-00000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.tag),
                      ),
                      inputFormatters: [
                        PrefixTextInputFormatter(_productPrefix),
                        // Allow letters, numbers and dash after prefix (validation enforces numbers)
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9\-]'),
                        ),
                      ],
                      onTap: () {
                        // If user taps before the prefix, move caret to the end of prefix
                        final sel = _productIdController.selection;
                        if (sel.start < _productPrefix.length) {
                          _productIdController.selection =
                              TextSelection.collapsed(
                                offset: _productPrefix.length,
                              );
                        }
                      },
                      onFieldSubmitted: (_) => _validateUniqueProductId(),
                      onEditingComplete: () => _validateUniqueProductId(),
                      validator: _validateProductId,
                    ),
                    const SizedBox(height: 15),

                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        hintText: 'Nombre del producto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 15),

                    // Precio Unitario (decimal)
                    TextFormField(
                      controller: _unitPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Unitario *',
                        hintText: 'Máximo 100 millones',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: _validateUnitPrice,
                    ),
                    const SizedBox(height: 15),

                    // Stock
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        hintText: 'Máximo 100,000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storage),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateStock,
                    ),
                    const SizedBox(height: 15),

                    // Descripción (opcional)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        hintText: 'Máximo 255 caracteres',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      maxLength: 255,
                    ),
                    const SizedBox(height: 15),

                    // Tipo de Producto (Dropdown)
                    DropdownButtonFormField<String>(
                      value: _selectedProductType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Producto *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "Medicamento",
                          child: Text("Medicamento"),
                        ),
                        DropdownMenuItem(
                          value: "Agroinsumo",
                          child: Text("Agroinsumo"),
                        ),
                        DropdownMenuItem(
                          value: "Alimento",
                          child: Text("Alimento"),
                        ),
                        DropdownMenuItem(
                          value: "Herramienta",
                          child: Text("Herramienta"),
                        ),
                        DropdownMenuItem(
                          value: "Mantenimiento",
                          child: Text("Mantenimiento"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedProductType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Debe seleccionar un tipo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(15),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearForm,
                            child: const Text('Limpiar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
