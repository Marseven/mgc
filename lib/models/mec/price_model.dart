// To parse this JSON data, do
//
//     final priceModel = priceModelFromJson(jsonString);

import 'dart:convert';

PriceModel priceModelFromJson(String str) =>
    PriceModel.fromJson(json.decode(str));

String priceModelToJson(PriceModel data) => json.encode(data.toJson());

class PriceModel {
  String id;
  String label;
  String description;
  String price;
  String qtyMax;
  String eventId;
  String adminId;
  DateTime dateCreated;

  PriceModel({
    required this.id,
    required this.label,
    required this.description,
    required this.price,
    required this.qtyMax,
    required this.eventId,
    required this.adminId,
    required this.dateCreated,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) => PriceModel(
        id: json["id"],
        label: json["label"],
        description: json["description"],
        price: json["price"],
        qtyMax: json["qty_max"],
        eventId: json["event_id"],
        adminId: json["admin_id"],
        dateCreated: DateTime.parse(json["date_created"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "description": description,
        "price": price,
        "qty_max": qtyMax,
        "event_id": eventId,
        "admin_id": adminId,
        "date_created": dateCreated.toIso8601String(),
      };
}
