import 'package:flutter/material.dart';
import '../mainScreen/items_screen.dart';
import '../models/menus.dart';

class InfoDesignWidget extends StatefulWidget {
  final Menus? model;
  final BuildContext? context;

  const InfoDesignWidget({super.key, this.model, this.context});

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemsScreen(model: widget.model)));
      },
      splashColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.black87,
          height: 150,
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, // Set a fixed width for the image
                height: 100, // Set a fixed height for the image
                child: Image.network(
                  widget.model!.thumbnailUrl!,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10), // Add some space between the image and text/icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fastfood_outlined, // Replace with your desired icon
                    color: Colors.amber, // Customize icon color
                    size: 20, // Customize icon size
                  ),
                  SizedBox(width: 4), // Add some space between the icon and text
                  Text(
                    widget.model!.menuTitle!, // Replace with your desired text
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
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