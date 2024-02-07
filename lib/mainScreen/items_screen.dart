import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../Widgets/customers_drawer.dart';
import '../Widgets/items_design.dart';
import '../Widgets/progress_bar.dart';
import '../colors.dart';
import '../global/global.dart';
import '../models/items.dart';
import '../models/menus.dart';
import '../uploadScreen/items_upload_screen.dart';

class ItemsScreen extends StatefulWidget
{
final Menus? model;

  ItemsScreen({this.model});


  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}



class _ItemsScreenState extends State<ItemsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white1,
      appBar: AppBar(
      backgroundColor: AppColors().red,
      automaticallyImplyLeading: true,
      actions: [
        IconButton(
          onPressed: ()
        {
          Navigator.push(context, MaterialPageRoute(builder: (c) => ItemsUploadScreen(model: widget.model)));
        },
          icon: Container(
            width: 32,
            height: 32,
            child: Image.asset('images/icons/add-post.png',color: Colors.white,),
          ),

        ),
      ],


      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // Adjust the height as needed
        child: Container(
          height: 40,
          color: Colors.black,
          child: Center(
            child:
            Text(
            "My "+  widget.model!.menuTitle!.toString() + "'s Products",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontFamily: "Poppins",

              ),
            ),

          ),
        ),
      ),
    ),
      drawer: CustomersDrawer(),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .doc(sharedPreferences!
                .getString("sellersUID"))
                .collection("menus")
                .doc(widget.model!.menuID)
                .collection("items").snapshots(),
            builder: (context, snapshot)
            {
              return !snapshot.hasData ? SliverToBoxAdapter(
                child: Center(child: circularProgress(),),
              )
                  : SliverStaggeredGrid.countBuilder(
                crossAxisCount: 2,
                staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                itemBuilder: (context, index)
                {
                  Items model = Items.fromJson(
                    snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                  );
                  return ItemsDesignWidget(
                    model: model,
                    context: context,
                  ) ;
                },
                itemCount: snapshot.data!.docs.length,
              );

            },
          ),
        ],

      ),



    );
  }
}
