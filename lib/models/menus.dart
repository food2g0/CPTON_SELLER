import 'package:cloud_firestore/cloud_firestore.dart';

class Menus
{
  String? menuID;
  String? sellerUID;
  String? menuTitle;
  String? productsID;
  String? menuInfo;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;


  Menus({
    this.menuID,
    this.sellerUID,
    this.menuTitle,
    this.menuInfo,
    this.publishedDate,
    this.productsID,
    this.status,
    this.thumbnailUrl,
});

  Menus.fromJson(Map<String, dynamic> json)
  {
    menuID = json['menuID'];
    sellerUID = json['sellerUID'];
    menuTitle = json['menuTitle'];
    menuInfo = json['menuInfo'];
    productsID = json['productsID'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
  }

  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["menuID"] = this.menuID;
    data["sellerUID"] = this.sellerUID;
    data["menuTitle"] = this.menuTitle;
    data["productsID"] = this.productsID;
    data["menuInfo"] = this.menuInfo;
    data["publishedDate"] = this.publishedDate;
    data["thumbnailUrl"] = this.thumbnailUrl;
    data["status"] = this.status;

    return data;
  }
}