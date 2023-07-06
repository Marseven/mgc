import 'Notifications.dart';
import 'BmBlockedUsers.dart';

class UserSettingsModel {
  UserSettingsModel({
    this.notifications,
    this.bmBlockedUsers,
  });

  UserSettingsModel.fromJson(dynamic json) {
    notifications = json['notifications'] != null ? Notifications.fromJson(json['notifications']) : null;
    bmBlockedUsers = json['bm_blocked_users'] != null ? BmBlockedUsers.fromJson(json['bm_blocked_users']) : null;
  }

  Notifications? notifications;
  BmBlockedUsers? bmBlockedUsers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (notifications != null) {
      map['notifications'] = notifications!.toJson();
    }
    if (bmBlockedUsers != null) {
      map['bm_blocked_users'] = bmBlockedUsers!.toJson();
    }
    return map;
  }
}
