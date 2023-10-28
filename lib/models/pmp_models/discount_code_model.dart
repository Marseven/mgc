import 'package:socialv/models/pmp_models/membership_model.dart';

class DiscountCodeList {
  bool? status;
  String? message;
  List<DiscountCode>? data;

  DiscountCodeList({this.status, this.message, this.data});

  factory DiscountCodeList.fromJson(Map<String, dynamic> json) {
    return DiscountCodeList(
      status: json['status'],
      message: json['message'],
      data: json['data'] != '{}' ? (json['data'] as List).map((i) => DiscountCode.fromJson(i)).toList() : null,
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

class DiscountCode {
  DiscountCode({
    this.id,
    this.code,
    this.starts,
    this.expires,
    this.uses,
    this.plans,
  });

  DiscountCode.fromJson(dynamic json) {
    id = json['id'];
    code = json['code'];
    starts = json['starts'];
    expires = json['expires'];
    uses = json['uses'];
    plans = json['plans'] != null ? (json['plans'] as List).map((i) => MembershipModel.fromJson(i)).toList() : null;
  }

  int? id;
  String? code;
  String? starts;
  String? expires;
  int? uses;
  List<MembershipModel>? plans;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['code'] = code;
    map['starts'] = starts;
    map['expires'] = expires;
    map['uses'] = uses;
    if (map['plans'] != null) {
      map['plans'] = this.plans!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
