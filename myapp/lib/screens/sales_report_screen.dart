import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../components/widgets/background_widget.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_helper.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Sale> _sales = [];
  double _totalSalesAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshSales();
  }

  void _refreshSales() async {
    final sales = await _databaseHelper.getSales();
    double totalAmount = sales.fold(0, (sum, sale) => sum + sale.totalAmount);

    setState(() {
      _sales = sales;
      _totalSalesAmount = totalAmount;
    });
  }

  void _clearSales() async {
    await _databaseHelper.deleteAllSales();
    _refreshSales(); 
  }

  @override
  Widget build(BuildContext context) {
    
    final numberFormat = NumberFormat('#,###.##');
   
    final dateFormat = DateFormat('yyyy-MM-dd'); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearSales,
          ),
        ],
      ),
      body: BackgroundWidget(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Sales Amount: \$${numberFormat.format(_totalSalesAmount)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _sales.length,
                itemBuilder: (context, index) {
                  final sale = _sales[index];
                  return FutureBuilder(
                    future: _databaseHelper.getProducts(),
                    builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final product = snapshot.data?.firstWhere(
                          (p) => p.id == sale.productId,
                          orElse: () => Product(name: 'Unknown', quantity: 0, price: 0.0),
                        );
                        return ListTile(
                          title: Text(product?.name ?? 'Unknown Product'),
                          subtitle: Text(
                            'Quantity Sold: ${sale.quantitySold}, '
                            'Total Amount: \$${numberFormat.format(sale.totalAmount)}, '
                            'Date: ${dateFormat.format(sale.saleDate)}' 
                          ),
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}