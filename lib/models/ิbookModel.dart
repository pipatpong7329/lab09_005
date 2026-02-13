// To parse this JSON data, do
//
//     final bookModel = bookModelFromJson(jsonString);

import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

class BookModel {
    int id;
    String productName;
    int productType;
    int price;

    BookModel({
        required this.id,
        required this.productName,
        required this.productType,
        required this.price,
    });

    factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        id: json["id"],
        productName: json["product_name"],
        productType: json["product_type"],
        price: json["price"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "product_type": productType,
        "price": price,
    };
}
