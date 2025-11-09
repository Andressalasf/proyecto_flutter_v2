import 'package:demo/presentation/widget/layout/drawer_widget.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';

class ListProducts extends StatefulWidget {
  const ListProducts({super.key});
  static const String name = "list_products";
  
  @override
  State<ListProducts> createState() => _ListProductsState();
}

class _ListProductsState extends State<ListProducts> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Cargar productos
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.getProducts();
      
      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess && result.data != null) {
        setState(() {
          _products = result.data!;
        });
      } else {
        _showError(result.error ?? 'Error al cargar productos');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  // Mostrar error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // Mostrar detalles
  void _showDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${product.id ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Product ID: ${product.productId ?? 'N/A'}'),
            const SizedBox(height: 5),
            Text('Precio: \$${product.unitPrice}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Text('Stock: ${product.stock} unidades', style: const TextStyle(color: Colors.blue)),
            Text('Tipo: ${product.productType}'),
            const SizedBox(height: 10),
            const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No hay productos'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo,
                          child: Text(
                            product.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.description, maxLines: 2),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  '\$${product.unitPrice}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Stock: ${product.stock}',
                                  style: TextStyle(
                                    color: product.stock > 0 ? Colors.blue : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showDetails(product),
                      ),
                    );
                  },
                ),
    );
  }
}