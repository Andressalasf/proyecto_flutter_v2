import 'package:demo/presentation/widget/layout/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

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

  @override
  void dispose() {
    _productIdController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _unitPriceController.dispose();
    _stockController.dispose();
    super.dispose();
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

  // Validar precio unitario (decimal, máximo 100 millones)
  String? _validateUnitPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    final price = double.tryParse(value);
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

  // Validar descripción (opcional, máximo 255 caracteres)
  String? _validateDescription(String? value) {
    if (value != null && value.length > 255) {
      return 'Máximo 255 caracteres';
    }
    return null;
  }

  // Validar stock (máximo 100000)
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
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 4),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  // Mostrar éxito con SnackBar
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
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
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
    _productIdController.clear();
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

      final result = await _apiService.createProduct(product);

      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess && result.data != null) {
        _showSuccess('Producto creado exitosamente!\nID: ${result.data!.id}');
        _clearForm();
      } else {
        _showError(result.error ?? 'No se pudo crear el producto');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Producto', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: DrawerWidget(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ID del Producto
                    TextFormField(
                      controller: _productIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID del Producto *',
                        hintText: 'PROD-1, PROD-123, PROD-00000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.tag),
                      ),
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
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
                      validator: _validateDescription,
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
                        DropdownMenuItem(value: "Medicamento", child: Text("Medicamento")),
                        DropdownMenuItem(value: "Agroinsumo", child: Text("Agroinsumo")),
                        DropdownMenuItem(value: "Alimento", child: Text("Alimento")),
                        DropdownMenuItem(value: "Herramienta", child: Text("Herramienta")),
                        DropdownMenuItem(value: "Mantenimiento", child: Text("Mantenimiento")),
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