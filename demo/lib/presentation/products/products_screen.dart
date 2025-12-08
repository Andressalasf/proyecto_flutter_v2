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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  int? _selectedCategoryId;
  List<String> _images = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Validar título
  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'El título es requerido';
    }
    if (value.length < 3) {
      return 'Debe tener al menos 3 caracteres';
    }
    if (value.length > 100) {
      return 'Máximo 100 caracteres';
    }
    return null;
  }

  // Validar precio
  String? _validatePrice(String? value) {
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
    if (price > 999999999) {
      return 'Precio demasiado alto';
    }
    return null;
  }

  // Agregar imagen
  void _addImage() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _images.add(url);
        _imageUrlController.clear();
      });
    }
  }

  // Eliminar imagen
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    setState(() {
      _selectedCategoryId = null;
      _images = [];
    });
  }

  // Guardar producto
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        title: _titleController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        categoryId: _selectedCategoryId ?? 40,
        images: _images.isEmpty
            ? [
                'https://picsum.photos/640/640?r=${DateTime.now().millisecondsSinceEpoch}',
              ]
            : _images,
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al guardar el producto: $e');
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
      drawer: const DrawerWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Título del Producto
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Nombre del producto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 15),

                    // Precio
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio *',
                        hintText: 'Ejemplo: 99.99',
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
                      validator: _validatePrice,
                    ),
                    const SizedBox(height: 15),

                    // Descripción (opcional)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        hintText: 'Descripción detallada del producto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 15),

                    // Categoría (Dropdown - opcional)
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Categoría 1")),
                        DropdownMenuItem(value: 2, child: Text("Categoría 2")),
                        DropdownMenuItem(value: 3, child: Text("Categoría 3")),
                        DropdownMenuItem(value: 4, child: Text("Categoría 4")),
                        DropdownMenuItem(value: 5, child: Text("Categoría 5")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Sección de imágenes
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Imágenes del Producto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _imageUrlController,
                                    decoration: const InputDecoration(
                                      labelText: 'URL de la imagen',
                                      hintText:
                                          'https://ejemplo.com/imagen.jpg',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.link),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: _addImage,
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.indigo,
                                  iconSize: 35,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_images.isNotEmpty) ...[
                              const Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _images.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const Icon(Icons.image),
                                    title: Text(
                                      _images[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
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
