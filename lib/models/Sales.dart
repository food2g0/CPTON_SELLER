import 'package:cloud_firestore/cloud_firestore.dart';

class Sales {
  final int saleVal;
  final String saleYear;
  final String colorVal;

  Sales(this.colorVal, this.saleVal, this.saleYear);

  Sales.fromMap(Map<String, dynamic> map)
      : assert(map['saleVal'] != null),
        assert(map['saleYear'] != null),
        saleVal = (map['saleVal'] as num).toInt(),

        colorVal = _parseColorValue(map['colorVal']), // Ensure colorVal is a valid color
        saleYear = map['saleYear'];

  static String _parseColorValue(dynamic colorVal) {
    if (colorVal is String && colorVal.startsWith("0x")) {
      // If colorVal is already a hexadecimal string, return it as is
      return colorVal;
    } else if (colorVal is int) {
      // If colorVal is an integer, convert it to a hexadecimal string
      return "0xFF${colorVal.toRadixString(16)}";
    } else {
      // If colorVal is neither a string nor an integer, return a default color
      return "0xFF000000"; // Default to black color
    }
  }

  @override
  String toString() => "Record<$saleVal:$saleYear:$colorVal>";

  // Fetch sales data from Firestore
  static Future<List<Sales>> fetchSalesData() async {
    List<Sales> salesList = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sales') // Adjust the collection name as needed
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot snapshot in querySnapshot.docs) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          Sales sales = Sales.fromMap(data);
          salesList.add(sales);
        }
      }
    } catch (e) {
      print("Error fetching sales data: $e");
    }
    return salesList;
  }
}
