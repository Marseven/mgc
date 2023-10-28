import 'package:socialv/models/pmp_models/membership_model.dart';

class LevelsList {
  bool? status;
  String? message;
  List<MembershipModel>? data;

  LevelsList({this.status, this.message, this.data});

  factory LevelsList.fromJson(Map<String, dynamic> json) {
    return LevelsList(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? (json['data'] as List).map((i) => MembershipModel.fromJson(i)).toList() : null,
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
