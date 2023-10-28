import 'package:socialv/models/pmp_models/payment_gateway_model.dart';

class GeneralSettingsModel {
  GeneralSettingsModel({
    this.isAccountVerificationRequire,
    this.isPaidMembershipEnable,
  });

  GeneralSettingsModel.fromJson(dynamic json) {
    isAccountVerificationRequire = json['is_account_verification_require'];
    isPaidMembershipEnable = json['is_paid_membership_enable'];
  }

  int? isAccountVerificationRequire;
  bool? isPaidMembershipEnable;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['is_account_verification_require'] = isAccountVerificationRequire;
    map['is_paid_membership_enable'] = isPaidMembershipEnable;
    return map;
  }
}
