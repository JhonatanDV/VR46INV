import 'package:flutter/material.dart';
import 'add_edit_product_screen.dart';
import 'sell_product_screen.dart';
import 'sales_report_screen.dart'; // Asegúrate de que esta ruta sea correcta
import '../models/product.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshProducts();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _refreshProducts() async {
    final products = await _databaseHelper.getProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
    });
  }

  void _deleteProduct(int id) async {
    await _databaseHelper.deleteProduct(id);
    _refreshProducts();
  }

  void _sellProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellProductScreen(
          products: _filteredProducts,
          onSaleCompleted: () {
            _refreshProducts(); // Actualiza los productos después de una venta
          },
        ),
      ),
    );
    if (result != null) {
      _refreshProducts();
    }
  }

  void _viewSalesReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SalesReportScreen(),
      ),
    );
    _refreshProducts(); // Opcional: actualiza los productos después de regresar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sell),
            onPressed: _sellProduct,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _viewSalesReport, // Botón para ver el reporte de ventas
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.yellow, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('Quantity: ${product.quantity}, Price: \$${product.price}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.quantity < 5)
                            const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 24.0,
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProduct(product.id ?? 0),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditProductScreen(
                              product: product,
                            ),
                          ),
                        );
                        if (result != null) {
                          _refreshProducts();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditProductScreen(),
            ),
          );
          if (result != null) {
            _refreshProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
