class PaymentList {
  bool? status;
  String? message;
  List<PaymentGatewayModel>? data;

  PaymentList({this.status, this.message, this.data});

  factory PaymentList.fromJson(Map<String, dynamic> json) {
    return PaymentList(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? (json['data'] as List).map((i) => PaymentGatewayModel.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (data['data'] != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentGatewayModel {
  PaymentGatewayModel({
    this.enable,
    this.mode,
    this.name,
    this.testing,
    this.live,
  });

  PaymentGatewayModel.fromJson(dynamic json) {
    enable = json['enable'];
    mode = json['mode'];
    name = json['name'];
    testing = json['testing'] != null ? PaymentKeyModel.fromJson(json['testing']) : null;
    live = json['live'] != null ? PaymentKeyModel.fromJson(json['live']) : null;
  }

  int? enable;
  String? mode;
  String? name;
  PaymentKeyModel? testing;
  PaymentKeyModel? live;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['enable'] = enable;
    map['mode'] = mode;
    map['name'] = name;
    if (testing != null) {
      map['testing'] = testing!.toJson();
    }
    if (live != null) {
      map['live'] = live!.toJson();
    }
    return map;
  }
}

class PaymentKeyModel {
  PaymentKeyModel({
    this.url,
    this.key,
    this.publicKey,
  });

  PaymentKeyModel.fromJson(dynamic json) {
    url = json['url'];
    key = json['key'];
    publicKey = json['public_key'];
  }

  String? url;
  String? key;
  String? publicKey;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['key'] = key;
    map['public_key'] = publicKey;
    return map;
  }
}
