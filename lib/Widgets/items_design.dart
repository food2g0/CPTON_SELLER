import 'package:cpton_food2go_sellers/Widgets/Dimensions.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:cpton_food2go_sellers/mainScreen/edit_item_screen.dart';
import 'package:flutter/material.dart';
import '../models/items.dart';

class ItemsDesignWidget extends StatefulWidget {
  final Items? model;
  final BuildContext? context;

  const ItemsDesignWidget({Key? key, this.model, this.context});

  @override
  State<ItemsDesignWidget> createState() => _ItemsDesignWidgetState();
}


class _ItemsDesignWidgetState extends State<ItemsDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemsScreen(model: widget.model)));
      },
      splashColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.black87,
          height: 250,
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  widget.model!.thumbnailUrl!,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10),
              // Add some space between the image and text/icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fastfood_outlined,
                    color: Colors.amber,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    widget.model!.productTitle!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // Center the icon and text horizontally
                children: [
                  Icon(
                    Icons.price_check,
                    color: Colors.red,
                    size: Dimensions.font16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Php. ' + widget.model!.productPrice.toString() + '.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> EditItemScreen(item: widget.model!)));
                    },
                    child:Icon(Icons.edit),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors().red, // Set the background color to red
                    ),
                    child: Icon(Icons.delete),
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