import 'dart:convert';

EventMediaModel eventMediaModelFromJson(String str) =>
    EventMediaModel.fromJson(json.decode(str));

String eventMediaModelToJson(EventMediaModel data) =>
    json.encode(data.toJson());

class EventMediaModel {
  int id;
  DateTime date;
  DateTime dateGmt;
  Caption guid;
  DateTime modified;
  DateTime modifiedGmt;
  String slug;
  String status;
  String type;
  String link;
  Caption title;
  int author;
  String commentStatus;
  String pingStatus;
  String template;
  Meta meta;
  List<dynamic> acf;
  Caption description;
  Caption caption;
  String altText;
  String mediaType;
  MimeType mimeType;
  MediaDetails mediaDetails;
  int post;
  String sourceUrl;
  Links links;

  EventMediaModel({
    required this.id,
    required this.date,
    required this.dateGmt,
    required this.guid,
    required this.modified,
    required this.modifiedGmt,
    required this.slug,
    required this.status,
    required this.type,
    required this.link,
    required this.title,
    required this.author,
    required this.commentStatus,
    required this.pingStatus,
    required this.template,
    required this.meta,
    required this.acf,
    required this.description,
    required this.caption,
    required this.altText,
    required this.mediaType,
    required this.mimeType,
    required this.mediaDetails,
    required this.post,
    required this.sourceUrl,
    required this.links,
  });

  factory EventMediaModel.fromJson(Map<String, dynamic> json) =>
      EventMediaModel(
        id: json["id"],
        date: DateTime.parse(json["date"]),
        dateGmt: DateTime.parse(json["date_gmt"]),
        guid: Caption.fromJson(json["guid"]),
        modified: DateTime.parse(json["modified"]),
        modifiedGmt: DateTime.parse(json["modified_gmt"]),
        slug: json["slug"],
        status: json["status"],
        type: json["type"],
        link: json["link"],
        title: Caption.fromJson(json["title"]),
        author: json["author"],
        commentStatus: json["comment_status"],
        pingStatus: json["ping_status"],
        template: json["template"],
        meta: Meta.fromJson(json["meta"]),
        acf: List<dynamic>.from(json["acf"].map((x) => x)),
        description: Caption.fromJson(json["description"]),
        caption: Caption.fromJson(json["caption"]),
        altText: json["alt_text"],
        mediaType: json["media_type"],
        mimeType: mimeTypeValues.map[json["mime_type"]]!,
        mediaDetails: MediaDetails.fromJson(json["media_details"]),
        post: json["post"],
        sourceUrl: json["source_url"],
        links: Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date.toIso8601String(),
        "date_gmt": dateGmt.toIso8601String(),
        "guid": guid.toJson(),
        "modified": modified.toIso8601String(),
        "modified_gmt": modifiedGmt.toIso8601String(),
        "slug": slug,
        "status": status,
        "type": type,
        "link": link,
        "title": title.toJson(),
        "author": author,
        "comment_status": commentStatus,
        "ping_status": pingStatus,
        "template": template,
        "meta": meta.toJson(),
        "acf": List<dynamic>.from(acf.map((x) => x)),
        "description": description.toJson(),
        "caption": caption.toJson(),
        "alt_text": altText,
        "media_type": mediaType,
        "mime_type": mimeTypeValues.reverse[mimeType],
        "media_details": mediaDetails.toJson(),
        "post": post,
        "source_url": sourceUrl,
        "_links": links.toJson(),
      };
}

class Caption {
  String rendered;

  Caption({
    required this.rendered,
  });

  factory Caption.fromJson(Map<String, dynamic> json) => Caption(
        rendered: json["rendered"],
      );

  Map<String, dynamic> toJson() => {
        "rendered": rendered,
      };
}

class Links {
  List<About> self;
  List<About> collection;
  List<About> about;
  List<Author> author;
  List<Author> replies;

  Links({
    required this.self,
    required this.collection,
    required this.about,
    required this.author,
    required this.replies,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: List<About>.from(json["self"].map((x) => About.fromJson(x))),
        collection:
            List<About>.from(json["collection"].map((x) => About.fromJson(x))),
        about: List<About>.from(json["about"].map((x) => About.fromJson(x))),
        author:
            List<Author>.from(json["author"].map((x) => Author.fromJson(x))),
        replies:
            List<Author>.from(json["replies"].map((x) => Author.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": List<dynamic>.from(self.map((x) => x.toJson())),
        "collection": List<dynamic>.from(collection.map((x) => x.toJson())),
        "about": List<dynamic>.from(about.map((x) => x.toJson())),
        "author": List<dynamic>.from(author.map((x) => x.toJson())),
        "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
      };
}

class About {
  String href;

  About({
    required this.href,
  });

  factory About.fromJson(Map<String, dynamic> json) => About(
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
      };
}

class Author {
  bool embeddable;
  String href;

  Author({
    required this.embeddable,
    required this.href,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        embeddable: json["embeddable"],
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "embeddable": embeddable,
        "href": href,
      };
}

class MediaDetails {
  int width;
  int height;
  String file;
  int filesize;
  Map<String, Size> sizes;
  ImageMeta imageMeta;

  MediaDetails({
    required this.width,
    required this.height,
    required this.file,
    required this.filesize,
    required this.sizes,
    required this.imageMeta,
  });

  factory MediaDetails.fromJson(Map<String, dynamic> json) => MediaDetails(
        width: json["width"],
        height: json["height"],
        file: json["file"],
        filesize: json["filesize"],
        sizes: Map.from(json["sizes"])
            .map((k, v) => MapEntry<String, Size>(k, Size.fromJson(v))),
        imageMeta: ImageMeta.fromJson(json["image_meta"]),
      );

  Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "file": file,
        "filesize": filesize,
        "sizes": Map.from(sizes)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "image_meta": imageMeta.toJson(),
      };
}

class ImageMeta {
  String aperture;
  String credit;
  String camera;
  String caption;
  String createdTimestamp;
  String copyright;
  String focalLength;
  String iso;
  String shutterSpeed;
  String title;
  String orientation;
  List<dynamic> keywords;

  ImageMeta({
    required this.aperture,
    required this.credit,
    required this.camera,
    required this.caption,
    required this.createdTimestamp,
    required this.copyright,
    required this.focalLength,
    required this.iso,
    required this.shutterSpeed,
    required this.title,
    required this.orientation,
    required this.keywords,
  });

  factory ImageMeta.fromJson(Map<String, dynamic> json) => ImageMeta(
        aperture: json["aperture"],
        credit: json["credit"],
        camera: json["camera"],
        caption: json["caption"],
        createdTimestamp: json["created_timestamp"],
        copyright: json["copyright"],
        focalLength: json["focal_length"],
        iso: json["iso"],
        shutterSpeed: json["shutter_speed"],
        title: json["title"],
        orientation: json["orientation"],
        keywords: List<dynamic>.from(json["keywords"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "aperture": aperture,
        "credit": credit,
        "camera": camera,
        "caption": caption,
        "created_timestamp": createdTimestamp,
        "copyright": copyright,
        "focal_length": focalLength,
        "iso": iso,
        "shutter_speed": shutterSpeed,
        "title": title,
        "orientation": orientation,
        "keywords": List<dynamic>.from(keywords.map((x) => x)),
      };
}

class Size {
  String file;
  int width;
  int height;
  int? filesize;
  MimeType mimeType;
  String sourceUrl;
  bool? uncropped;

  Size({
    required this.file,
    required this.width,
    required this.height,
    this.filesize,
    required this.mimeType,
    required this.sourceUrl,
    this.uncropped,
  });

  factory Size.fromJson(Map<String, dynamic> json) => Size(
        file: json["file"],
        width: json["width"],
        height: json["height"],
        filesize: json["filesize"],
        mimeType: mimeTypeValues.map[json["mime_type"]]!,
        sourceUrl: json["source_url"],
        uncropped: json["uncropped"],
      );

  Map<String, dynamic> toJson() => {
        "file": file,
        "width": width,
        "height": height,
        "filesize": filesize,
        "mime_type": mimeTypeValues.reverse[mimeType],
        "source_url": sourceUrl,
        "uncropped": uncropped,
      };
}

enum MimeType { IMAGE_JPEG }

final mimeTypeValues = EnumValues({"image/jpeg": MimeType.IMAGE_JPEG});

class Meta {
  int bbpTopicCount;
  int bbpReplyCount;
  int bbpTotalTopicCount;
  int bbpTotalReplyCount;
  int bbpVoiceCount;
  int bbpAnonymousReplyCount;
  int bbpTopicCountHidden;
  int bbpReplyCountHidden;
  int bbpForumSubforumCount;
  String webnusSmReadyStyle;
  String webnusSmStyle;
  String webnusSmControlsValues;
  String webnusSmFontsCollection;
  String webnusSmFontsLinks;

  Meta({
    required this.bbpTopicCount,
    required this.bbpReplyCount,
    required this.bbpTotalTopicCount,
    required this.bbpTotalReplyCount,
    required this.bbpVoiceCount,
    required this.bbpAnonymousReplyCount,
    required this.bbpTopicCountHidden,
    required this.bbpReplyCountHidden,
    required this.bbpForumSubforumCount,
    required this.webnusSmReadyStyle,
    required this.webnusSmStyle,
    required this.webnusSmControlsValues,
    required this.webnusSmFontsCollection,
    required this.webnusSmFontsLinks,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        bbpTopicCount: json["_bbp_topic_count"],
        bbpReplyCount: json["_bbp_reply_count"],
        bbpTotalTopicCount: json["_bbp_total_topic_count"],
        bbpTotalReplyCount: json["_bbp_total_reply_count"],
        bbpVoiceCount: json["_bbp_voice_count"],
        bbpAnonymousReplyCount: json["_bbp_anonymous_reply_count"],
        bbpTopicCountHidden: json["_bbp_topic_count_hidden"],
        bbpReplyCountHidden: json["_bbp_reply_count_hidden"],
        bbpForumSubforumCount: json["_bbp_forum_subforum_count"],
        webnusSmReadyStyle: json["_webnus_sm_ready_style"],
        webnusSmStyle: json["_webnus_sm_style"],
        webnusSmControlsValues: json["_webnus_sm_controls_values"],
        webnusSmFontsCollection: json["_webnus_sm_fonts_collection"],
        webnusSmFontsLinks: json["_webnus_sm_fonts_links"],
      );

  Map<String, dynamic> toJson() => {
        "_bbp_topic_count": bbpTopicCount,
        "_bbp_reply_count": bbpReplyCount,
        "_bbp_total_topic_count": bbpTotalTopicCount,
        "_bbp_total_reply_count": bbpTotalReplyCount,
        "_bbp_voice_count": bbpVoiceCount,
        "_bbp_anonymous_reply_count": bbpAnonymousReplyCount,
        "_bbp_topic_count_hidden": bbpTopicCountHidden,
        "_bbp_reply_count_hidden": bbpReplyCountHidden,
        "_bbp_forum_subforum_count": bbpForumSubforumCount,
        "_webnus_sm_ready_style": webnusSmReadyStyle,
        "_webnus_sm_style": webnusSmStyle,
        "_webnus_sm_controls_values": webnusSmControlsValues,
        "_webnus_sm_fonts_collection": webnusSmFontsCollection,
        "_webnus_sm_fonts_links": webnusSmFontsLinks,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
