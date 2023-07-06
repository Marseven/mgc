import 'Permissions.dart';

class Threads {
  Threads({
    this.threadId,
    this.lastMessage,
    this.isHidden,
    this.isDeleted,
    this.subject,
    this.lastTime,
    this.participants,
    this.participantsCount,
    this.type,
    this.title,
    this.image,
    this.url,
    this.meta,
    this.isPinned,
    this.permissions,
    //this.mentions,
    this.unread,
    this.secret_key,
  });

  Threads.fromJson(dynamic json) {
    threadId = json['thread_id'];
    lastMessage = json['lastMessage'];
    isHidden = json['isHidden'];
    isDeleted = json['isDeleted'];
    subject = json['subject'];
    lastTime = json['lastTime'];
    participants = json['participants'] != null ? json['participants'].cast<int>() : [];
    participantsCount = json['participantsCount'];
    type = json['type'];
    title = json['title'];
    image = json['image'];
    url = json['url'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    isPinned = json['isPinned'];
    permissions = json['permissions'] != null ? Permissions.fromJson(json['permissions']) : null;
    mentions = json['mentions'] != null ? (json['mentions'] as List).map((i) => i.fromJson(i)).toList() : null;
    unread = json['unread'];
    secret_key = json['secret_key'];
  }

  int? threadId;
  int? lastMessage;
  int? isHidden;
  int? isDeleted;
  String? subject;
  String? lastTime;
  List<int>? participants;
  int? participantsCount;
  String? type;
  String? title;
  String? image;
  String? url;
  Meta? meta;
  int? isPinned;
  Permissions? permissions;
  List<dynamic>? mentions;
  int? unread;
  String? secret_key;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['thread_id'] = threadId;
    map['lastMessage'] = lastMessage;
    map['isHidden'] = isHidden;
    map['isDeleted'] = isDeleted;
    map['subject'] = subject;
    map['lastTime'] = lastTime;
    map['participants'] = participants;
    map['participantsCount'] = participantsCount;
    map['type'] = type;
    map['title'] = title;
    map['image'] = image;
    map['url'] = url;
    map['secret_key'] = secret_key;
   /* if (this.mentions != null) {
      map['mentions'] = this.mentions!.map((v) => v.toJson()).toList();
    }*/
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    map['isPinned'] = isPinned;
    if (permissions != null) {
      map['permissions'] = permissions!.toJson();
    }
    map['unread'] = unread;
    return map;
  }
}

class Meta {
  Meta({this.allowInvite});

  Meta.fromJson(dynamic json) {
    allowInvite = json['allowInvite'];
  }

  bool? allowInvite;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['allowInvite'] = allowInvite;
    return map;
  }
}
