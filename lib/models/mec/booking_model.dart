// To parse this JSON data, do
//
//     final bookingModel = bookingModelFromJson(jsonString);

import 'dart:convert';

import 'package:socialv/models/mec/event_detail_model.dart';

BookingModel bookingModelFromJson(String str) =>
    BookingModel.fromJson(json.decode(str));

String bookingModelToJson(BookingModel data) => json.encode(data.toJson());

class BookingModel {
  String? id;
  String? lastname;
  String? firstname;
  String? indexPlayer;
  String? sexe;
  String? phone;
  String? email;
  String? eventId;
  dynamic? status;
  DateTime? bookDate;
  EventDetailModel? event;

  BookingModel({
    this.id,
    this.lastname,
    this.firstname,
    this.indexPlayer,
    this.sexe,
    this.phone,
    this.email,
    this.eventId,
    this.status,
    this.bookDate,
    this.event,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json["id"],
        lastname: json["lastname"],
        firstname: json["firstname"],
        indexPlayer: json["index_player"],
        sexe: json["sexe"],
        phone: json["phone"],
        email: json["email"],
        eventId: json["event_id"],
        status: json["status"],
        bookDate: DateTime.parse(json["book_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lastname": lastname,
        "firstname": firstname,
        "index_player": indexPlayer,
        "sexe": sexe,
        "phone": phone,
        "email": email,
        "event_id": eventId,
        "status": status,
        "book_date": bookDate!.toIso8601String(),
      };
}
