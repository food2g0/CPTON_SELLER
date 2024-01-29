import 'package:cloud_firestore/cloud_firestore.dart';

class Items
{
  String? menuID;
  String? sellersUID;
  String? productsID;
  String? productTitle;
  String? productDescription;
  String? status;
  int? productPrice;
  int? productQuantity;
  Timestamp? publishedDate;
  String? thumbnailUrl;

  Items
      ({
    this.menuID,
    this.sellersUID,
    this.productsID,
    this.productTitle,
    this.productDescription,
    this.status,
    this.productPrice,
    this.productQuantity,
    this.publishedDate,
    this.thumbnailUrl,
  });

  Items.fromJson(Map<String, dynamic> json)
  {
    menuID = json['menuID'];
    sellersUID = json['sellersUID'];
    productsID = json['productsID'];
    productTitle= json['productTitle'];
    productDescription= json['productDescription'];
    status = json['status'];
    productPrice = json['productPrice'];
    productQuantity = json['productQuantity'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
  }


  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["menuID"] = this.menuID;
    data["sellerUID"] = this.sellersUID;
    data["productsID"] = this.productsID;
    data["productTitle"] = this.productTitle;
    data["productDescription"] = this.productDescription;
    data["productPrice"] = this.productPrice;
    data["productQuantity"] = this.productQuantity;
    data["publishedDate"] = this.publishedDate;
    data["thumbnailUrl"] = this.thumbnailUrl;
    data["status"] = this.status;

    return data;
  }
  Items copyWith({
    String? menuID,
    String? sellersUID,
    String? productsID,
    String? productTitle,
    String? productDescription,
    String? status,
    int? productPrice,
    int? productQuantity,
    Timestamp? publishedDate,
    String? thumbnailUrl,
  }) {
    return Items(
      menuID: menuID ?? this.menuID,
      sellersUID: sellersUID ?? this.sellersUID,
      productsID: productsID ?? this.productsID,
      productTitle: productTitle ?? this.productTitle,
      productDescription: productDescription ?? this.productDescription,
      status: status ?? this.status,
      productPrice: productPrice ?? this.productPrice,
      productQuantity: productQuantity ?? this.productQuantity,
      publishedDate: publishedDate ?? this.publishedDate,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

