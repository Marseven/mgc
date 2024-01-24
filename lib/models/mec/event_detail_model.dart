// To parse this JSON data, do
//
//     final eventDetailModel = eventDetailModelFromJson(jsonString);

import 'dart:convert';

EventDetailModel eventDetailModelFromJson(String str) =>
    EventDetailModel.fromJson(json.decode(str));

String eventDetailModelToJson(EventDetailModel data) =>
    json.encode(data.toJson());

class EventDetailModel {
  String? id;
  String? title;
  String? content;
  DateTime? start;
  DateTime? end;
  FeaturedImage? featuredImage;
  Categories? categories;

  EventDetailModel({
    this.id,
    this.title,
    this.content,
    this.start,
    this.end,
    this.featuredImage,
    this.categories,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) =>
      EventDetailModel(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        featuredImage: FeaturedImage.fromJson(json["featuredImage"]),
        categories: Categories.fromJson(json["categories"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "start":
            "${start!.year.toString().padLeft(4, '0')}-${start!.month.toString().padLeft(2, '0')}-${start!.day.toString().padLeft(2, '0')}",
        "end":
            "${end!.year.toString().padLeft(4, '0')}-${end!.month.toString().padLeft(2, '0')}-${end!.day.toString().padLeft(2, '0')}",
        "featuredImage": featuredImage?.toJson(),
        "categories": categories?.toJson(),
      };
}

class Categories {
  int id;
  String name;
  String icon;
  String color;

  Categories({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Categories.fromJson(Map<String, dynamic> json) => Categories(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "color": color,
      };
}

class FeaturedImage {
  String thumbnail;
  String thumblist;
  String gridsquare;
  String meccarouselthumb;
  String medium;
  String large;
  String full;
  String tileview;

  FeaturedImage({
    required this.thumbnail,
    required this.thumblist,
    required this.gridsquare,
    required this.meccarouselthumb,
    required this.medium,
    required this.large,
    required this.full,
    required this.tileview,
  });

  factory FeaturedImage.fromJson(Map<String, dynamic> json) => FeaturedImage(
        thumbnail: json["thumbnail"],
        thumblist: json["thumblist"],
        gridsquare: json["gridsquare"],
        meccarouselthumb: json["meccarouselthumb"],
        medium: json["medium"],
        large: json["large"],
        full: json["full"],
        tileview: json["tileview"],
      );

  Map<String, dynamic> toJson() => {
        "thumbnail": thumbnail,
        "thumblist": thumblist,
        "gridsquare": gridsquare,
        "meccarouselthumb": meccarouselthumb,
        "medium": medium,
        "large": large,
        "full": full,
        "tileview": tileview,
      };
}
