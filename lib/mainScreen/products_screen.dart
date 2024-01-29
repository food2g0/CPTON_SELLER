import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../Widgets/info_design.dart';
import '../Widgets/progress_bar.dart';
import '../global/global.dart';
import '../models/menus.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.red[900],
        automaticallyImplyLeading: true,
        actions: [
          IconButton(onPressed: (){},
            icon: Container(
              width: 26,
              height: 26,
              child: Image.asset('images/icons/bubble-chat.png',color: Colors.white,),
            ),)
        ],

        title: Text(
          sharedPreferences!.getString("sellersName")!,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // Adjust the height as needed
          child: Container(
            height: 40,
            color: Colors.black,
            child: Center(
              child:
              Text(
                "My Menus",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontFamily: "Poppins",

                ),
              ),

            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .doc(sharedPreferences!
                .getString("sellersUID"))
                .collection("menus").orderBy("publishedDate", descending: true).snapshots(),
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
                  Menus model = Menus.fromJson(
                    snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                  );
                  return InfoDesignWidget(
                    model: model,
                    context: context,
                  ) ;
                },
                itemCount: snapshot.data!.docs.length,
              );

            },
          ),
        ],
      )

    );
  }
}
