import 'package:flutter/material.dart';
import '../components/widgets/background_widget.dart';
import '../models/product.dart';
import '../services/database_helper.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _supplierPriceController = TextEditingController(); // Controlador para el precio del proveedor
  final TextEditingController _profitController = TextEditingController(); // Controlador para el porcentaje de ganancia
  bool _isProfitEnabled = false; // Switch para activar/desactivar ganancia automática

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _quantityController.text = widget.product!.quantity.toString();
      _priceController.text = widget.product!.price.toString();
    }
  }

  void _calculatePriceWithProfit() {
    final supplierPrice = double.tryParse(_supplierPriceController.text) ?? 0.0;
    final profitPercentage = double.tryParse(_profitController.text) ?? 0.0;

    if (_isProfitEnabled && supplierPrice > 0 && profitPercentage > 0) {
      // Calcula el precio con la ganancia aplicada
      final newPrice = supplierPrice * (1 + profitPercentage / 100);
      _priceController.text = newPrice.toStringAsFixed(2);
    }
  }

  Future<void> _saveProduct() async {
  final String name = _nameController.text;
  final int quantity = int.tryParse(_quantityController.text) ?? 0;
  final double price = double.tryParse(_priceController.text) ?? 0.0;

  if (name.isNotEmpty && quantity > 0 && price > 0) {
    final product = Product(
      id: widget.product?.id,
      name: name,
      quantity: quantity,
      price: price,
    );

    if (widget.product == null) {
      // Inserta el nuevo producto
      await _databaseHelper.insertProduct(product);
    } else {
      // Actualiza el producto existente
      await _databaseHelper.updateProduct(product);
    }

    // Enviar true para indicar éxito al guardar/editar el producto
    Navigator.pop(context, true);
  } else {
    // Muestra un mensaje de error si los campos no son válidos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields correctly')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              if (_isProfitEnabled)
                TextField(
                  controller: _supplierPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Supplier Price'),
                  onChanged: (value) {
                    if (_isProfitEnabled) {
                      _calculatePriceWithProfit();
                    }
                  },
                ),
              SwitchListTile(
                title: const Text('Enable Profit Calculation'),
                value: _isProfitEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isProfitEnabled = value;
                    if (!value) {
                      // Si se desactiva, limpiar el campo del precio del proveedor
                      _supplierPriceController.clear();
                      _profitController.clear();
                    }
                  });
                },
              ),
              if (_isProfitEnabled)
                TextField(
                  controller: _profitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Profit Percentage',
                  ),
                  onChanged: (value) {
                    _calculatePriceWithProfit();
                  },
                ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Final Price'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct, // Llama a la función para guardar el producto
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
