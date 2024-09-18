import 'package:flutter/material.dart';
import '../components/widgets/background_widget.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_helper.dart';

class SellProductScreen extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onSaleCompleted;

  const SellProductScreen({super.key, required this.products, required this.onSaleCompleted});

  @override
  _SellProductScreenState createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Product? _selectedProduct;
  int _quantitySold = 1;
  double _discountPercentage = 0.0; // Nuevo campo para el porcentaje de descuento

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Product'),
      ),
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<Product>(
                hint: const Text('Select Product'),
                value: _selectedProduct,
                onChanged: (Product? newValue) {
                  setState(() {
                    _selectedProduct = newValue;
                  });
                },
                items: widget.products.map<DropdownMenuItem<Product>>((Product product) {
                  return DropdownMenuItem<Product>(
                    value: product,
                    child: Text(product.name),
                  );
                }).toList(),
              ),
              if (_selectedProduct != null)
                Column(
                  children: [
                    Text('Available Quantity: ${_selectedProduct!.quantity}'),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity Sold'),
                      onChanged: (value) {
                        setState(() {
                          _quantitySold = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Discount (%)'),
                      onChanged: (value) {
                        setState(() {
                          _discountPercentage = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedProduct != null && _quantitySold > 0) {
                    final product = _selectedProduct!;
                    final newQuantity = product.quantity - _quantitySold;
                    if (newQuantity < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not enough stock!')),
                      );
                      return;
                    }

                    final discountAmount = (product.price * _discountPercentage) / 100;
                    final discountedPrice = product.price - discountAmount;
                    final totalAmount = discountedPrice * _quantitySold;

                    final sale = Sale(
                      productId: product.id!,
                      quantitySold: _quantitySold,
                      totalAmount: totalAmount,
                      discountPercentage: _discountPercentage, // Incluye el porcentaje de descuento
                      saleDate: DateTime.now(), id: null,
                    );

                    await _databaseHelper.insertSale(sale);
                    await _databaseHelper.updateProductQuantity(product.id!, newQuantity);

                    widget.onSaleCompleted();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Complete Sale'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}