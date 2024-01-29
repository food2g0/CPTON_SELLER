import 'package:flutter/material.dart';
import '../Service/items_service.dart';
import '../models/items.dart';


class EditItemScreen extends StatefulWidget {
  final Items item;

  EditItemScreen({required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final ItemsService _itemsService = ItemsService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.productTitle!;
    descriptionController.text = widget.item.productDescription!;
    priceController.text = widget.item.productPrice.toString();
    quantityController.text = widget.item.productQuantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            ElevatedButton(
              onPressed: () => _updateItemDetails(),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateItemDetails() {
    final updatedItem = widget.item.copyWith(
      productTitle: titleController.text,
      productDescription: descriptionController.text,
      productPrice: int.parse(priceController.text),
      productQuantity: int.parse(quantityController.text),
    );

    _itemsService.updateItemData(updatedItem);

    // Optionally, you can show a confirmation message to the user.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Item details updated successfully!'),
    ));
  }
}
