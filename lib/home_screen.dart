//represents the necessary imports required for this application.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';

//represents the main screen of the application where the food items and order operations are portrayed.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //represents the controller for the target cost input field.
  final TextEditingController _targetCostController = TextEditingController();
  //selected date for the order.
  DateTime _selectedDate = DateTime.now();
  //represents the list to store the food items retrieved from the database.
  List<Map<String, dynamic>> _foodItems = [];
  //represents the list to keep track of selected food items.
  List<bool> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    //fetch all of the food items when the screen is initialized
    _fetchFoodItems();
  }

  //represents the method that fetches all food items from the database.
  Future<void> _fetchFoodItems() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.queryAllFoodItems();
    setState(() {
      _foodItems = data;
      _selectedItems = List.filled(data.length, false);
    });
  }

  //represents the method to save the order with selected food items and target cost.
  Future<void> _saveOrder() async {
    final targetCost = _targetCostController.text.isNotEmpty
        ? double.tryParse(_targetCostController.text)
        : null;
    if (targetCost == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid target cost.')));
      return;
    }

    final selectedItems = _foodItems
        .asMap()
        .entries
        .where((entry) => _selectedItems[entry.key])
        .map((entry) => entry.value['name'] as String)
        .toList();
    final totalCost = _foodItems
        .asMap()
        .entries
        .where((entry) => _selectedItems[entry.key])
        .map((entry) => entry.value['cost'] as double)
        .fold<double>(0.0, (a, b) => a + b);

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one food item.')));
      return;
    }

    if (totalCost > targetCost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Total cost exceeds the target cost.')));
      return;
    }

    final dbHelper = DatabaseHelper();
    final existingOrder = await dbHelper.queryOrderByDate(DateFormat('yyyy-MM-dd').format(_selectedDate));

    final order = {
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'total_cost': totalCost,
      'items': selectedItems.join(', '),
    };

    if (existingOrder != null) {
      //update the existing order.
      await dbHelper.updateOrder(order, existingOrder['id']);
    } else {
      //insert a new order.
      await dbHelper.insertOrder(order);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order saved successfully!')));
  }


  //represents a method to show a dialog to add a new food item.
  void _showAddFoodItemDialog() {
    final _nameController = TextEditingController();
    final _costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _costController,
                decoration: InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text;
                final cost = double.tryParse(_costController.text);
                if (name.isNotEmpty && cost != null) {
                  final dbHelper = DatabaseHelper();
                  await dbHelper.insertFoodItem({'name': name, 'cost': cost});
                  //refreshes the list after adding a new food item.
                  await _fetchFoodItems();
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  //represents a method to show dialog to update an existing food item.
  void _showUpdateFoodItemDialog(int id, String name, double cost) {
    final _nameController = TextEditingController(text: name);
    final _costController = TextEditingController(text: cost.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _costController,
                decoration: InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedName = _nameController.text;
                final updatedCost = double.tryParse(_costController.text);
                if (updatedName.isNotEmpty && updatedCost != null) {
                  final dbHelper = DatabaseHelper();
                  await dbHelper.updateFoodItem({
                    'id': id,
                    'name': updatedName,
                    'cost': updatedCost,
                  });
                  //refreshes the list after updating a food item.
                  await _fetchFoodItems();
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  //represents a method to show a dialog to query order plans by date.
  void _showQueryOrderDialog() {
    final _queryDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title of the section.
          title: Text('Query Order Plan'),
          content: TextField(
            controller: _queryDateController,
            decoration: InputDecoration(labelText: 'Date (yyyy-MM-dd)'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final date = _queryDateController.text;
                final dbHelper = DatabaseHelper();
                final order = await dbHelper.queryOrderByDate(date);
                Navigator.of(context).pop();
                if (order != null) {
                  _showOrderDetailsDialog(order);
                } else {
                  //message if there is no order for the inputted date.
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No order found for the selected date.')));
                }
              },
              child: Text('Query'),
            ),
          ],
        );
      },
    );
  }

  //represents a method to show the order details in a dialog.
  void _showOrderDetailsDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title for the "Order Details" section.
          title: Text('Order Details'),
          //represents the order details.
          content: Text('Date: ${order['date']}\nTotal Cost: ${order['total_cost']}\nItems: ${order['items']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title that shows on the top banner in the application.
        title: Text('Food Ordering App by RR'),
        //colour attribute for the application title.
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showQueryOrderDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    });
                  },
                  //text for the "Select Date" section on the home screen.
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _targetCostController,
              decoration: InputDecoration(
                //represents the label for the "Target Cost per Day" section on the home screen.
                labelText: 'Target Cost per Day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Checkbox(
                      value: _selectedItems[index],
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedItems[index] = value!;
                        });
                      },
                    ),
                    //shows the details for the different food items (food name and cost)
                    title: Text(_foodItems[index]['name']),
                    subtitle: Text('\$${_foodItems[index]['cost']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showUpdateFoodItemDialog(
                              _foodItems[index]['id'],
                              _foodItems[index]['name'],
                              _foodItems[index]['cost'],
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            final dbHelper = DatabaseHelper();
                            await dbHelper.deleteFoodItem(_foodItems[index]['id']);
                            subtitle: Text('\$${_foodItems[index]['cost'].toStringAsFixed(2)}');
                            _fetchFoodItems(); // Refresh the list
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveOrder,
              //represents the button for saving the order.
              child: Text('Save Order'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodItemDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
