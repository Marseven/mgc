import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/request_verification_dialog.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blockReport/blocked_accounts.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/screens/membership/screens/my_membership_screen.dart';
import 'package:socialv/screens/profile/screens/edit_profile_screen.dart';
import 'package:socialv/screens/settings/components/change_theme_dialog.dart';
import 'package:socialv/screens/settings/screens/change_password_screen.dart';
import 'package:socialv/screens/settings/screens/coupon_list_screen.dart';
import 'package:socialv/screens/settings/screens/edit_shop_details_screen.dart';
import 'package:socialv/screens/settings/screens/language_screen.dart';
import 'package:socialv/screens/settings/screens/notification_settings.dart';
import 'package:socialv/screens/settings/screens/profile_visibility_screen.dart';
import 'package:socialv/screens/settings/screens/safe_content_settings_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import 'send_invitations_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    int themeModeIndex = getIntAsync(SharePreferencesKey.APP_THEME,
        defaultValue: AppThemeMode.ThemeModeSystem);

    window.onPlatformBrightnessChanged = () {
      if (themeModeIndex == AppThemeMode.ThemeModeSystem) {
        appStore.toggleDarkMode(
            value:
                MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        finish(context, isUpdate);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.settings, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
        ),
        body: Observer(
          builder: (_) => Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SettingSection(
                      title: Text(language.appSetting.toUpperCase(),
                          style: boldTextStyle(color: context.primaryColor)),
                      headingDecoration:
                          BoxDecoration(color: context.cardColor),
                      items: [
                        SettingItemWidget(
                          title: language.appTheme,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_dark_mode,
                              height: 18,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () async {
                            await showGeneralDialog(
                              context: context,
                              transitionDuration: Duration(milliseconds: 250),
                              barrierColor: Colors.black26,
                              transitionBuilder: (ctx, a1, a2, widget) {
                                return Transform.scale(
                                  scale: a1.value,
                                  child: Opacity(
                                    opacity: a1.value,
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 3,
                                          sigmaY: 3,
                                          tileMode: TileMode.repeated),
                                      child: ChangeThemeDialog(
                                        voidCallback: () {
                                          finish(ctx);
                                        },
                                        width: ctx.width(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              pageBuilder: (context, animation1, animation2) =>
                                  Offstage(),
                            );
                          },
                        ),
                        // SettingItemWidget(
                        //   title: language.appLanguage,
                        //   titleTextStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                        //   leading: Image.asset(ic_network, height: 16, width: 16, color: context.primaryColor, fit: BoxFit.cover),
                        //   trailing: Icon(Icons.arrow_forward_ios, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 16),
                        //   onTap: () {
                        //     LanguageScreen().launch(context);
                        //   },
                        // ),
                        SettingItemWidget(
                          title: language.contentSafety,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_shield_done,
                              height: 18,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            SafeContentSettingsScreen().launch(context);
                          },
                        ),
                      ],
                    ),
                    SettingSection(
                      title: Text(
                          '${language.account.toUpperCase()} ${language.settings.toUpperCase()}',
                          style: boldTextStyle(color: context.primaryColor)),
                      headingDecoration:
                          BoxDecoration(color: context.cardColor),
                      items: [
                        if (pmpStore.pmpEnable)
                          SettingItemWidget(
                            title: language.membership,
                            titleTextStyle: primaryTextStyle(
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite),
                            leading: Image.asset(ic_ticket_star,
                                height: 18,
                                width: 18,
                                color: context.primaryColor,
                                fit: BoxFit.cover),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite,
                                size: 16),
                            onTap: () {
                              if (!appStore.isLoading) {
                                MyMembershipScreen().launch(context);
                              }
                            },
                          ),
                        SettingItemWidget(
                          title: language.editProfile,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_edit,
                              height: 16,
                              width: 16,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading)
                              EditProfileScreen().launch(context).then((value) {
                                isUpdate = value;
                              });
                          },
                        ),
                        if (appStore.showWoocommerce == 1 &&
                            appStore.isShopEnable == 1)
                          SettingItemWidget(
                            title: language.editShopDetails,
                            titleTextStyle: primaryTextStyle(
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite),
                            leading: Image.asset(ic_bag,
                                height: 18,
                                width: 18,
                                color: context.primaryColor,
                                fit: BoxFit.cover),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite,
                                size: 16),
                            onTap: () {
                              if (!appStore.isLoading)
                                EditShopDetailsScreen()
                                    .launch(context)
                                    .then((value) {
                                  isUpdate = value;
                                });
                            },
                          ),
                        if (appStore.showWoocommerce == 1)
                          SettingItemWidget(
                            title: language.coupons,
                            titleTextStyle: primaryTextStyle(
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite),
                            leading: Image.asset(ic_coupon,
                                height: 18,
                                width: 18,
                                color: context.primaryColor,
                                fit: BoxFit.cover),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite,
                                size: 16),
                            onTap: () {
                              CouponListScreen().launch(context);
                            },
                          ),
                        SettingItemWidget(
                          title: language.changePassword,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_lock,
                              height: 18,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading)
                              ChangePasswordScreen().launch(context);
                          },
                        ),
                        SettingItemWidget(
                          title: language.notificationSettings,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_notification,
                              height: 18,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading)
                              NotificationSettings().launch(context);
                          },
                        ),
                        SettingItemWidget(
                          title: language.profileVisibility,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_profile,
                              height: 18,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading)
                              ProfileVisibilityScreen().launch(context);
                          },
                        ),
                      ],
                    ),
                    SettingSection(
                      title: Text(language.about.toUpperCase(),
                          style: boldTextStyle(color: context.primaryColor)),
                      headingDecoration:
                          BoxDecoration(color: context.cardColor),
                      items: [
                        SnapHelperWidget<PackageInfoData>(
                          future: getPackageInfo(),
                          onSuccess: (d) => SettingItemWidget(
                            title: language.rateUs,
                            titleTextStyle: primaryTextStyle(
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite),
                            leading: Image.asset(ic_star,
                                height: 18,
                                width: 18,
                                color: context.primaryColor,
                                fit: BoxFit.cover),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite,
                                size: 16),
                            onTap: () {
                              if (isAndroid) {
                                log('$playStoreBaseURL${d.packageName}');
                                launchUrl(
                                    Uri.parse(
                                        '$playStoreBaseURL${d.packageName}'),
                                    mode: LaunchMode.externalApplication);
                              } else if (isIOS) {
                                launchUrl(Uri.parse(IOS_APP_LINK),
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                        SettingItemWidget(
                          title: language.shareApp,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_send,
                              height: 18,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading) onShareTap(context);
                          },
                        ),
                        SettingItemWidget(
                          title: language.privacyPolicy,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_shield_done,
                              height: 16,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading)
                              openWebPage(context, url: PRIVACY_POLICY_URL);
                          },
                        ),
                        SettingItemWidget(
                          title: language.termsCondition,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_document,
                              height: 18,
                              width: 18,
                              color: context.primaryColor,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading)
                              openWebPage(context,
                                  url: TERMS_AND_CONDITIONS_URL);
                          },
                        ),
                        SettingItemWidget(
                          title: language.helpSupport,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_question_circle,
                              height: 18,
                              width: 18,
                              color: appColorPrimary,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            if (!appStore.isLoading)
                              openWebPage(context, url: SUPPORT_URL);
                          },
                        ),
                      ],
                    ),
                    SettingSection(
                      title: Text(language.manageAccount.toUpperCase(),
                          style: boldTextStyle(color: context.primaryColor)),
                      headingDecoration:
                          BoxDecoration(color: context.cardColor),
                      items: [
                        SettingItemWidget(
                          title: language.invitations,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_message,
                              height: 18,
                              width: 18,
                              color: appColorPrimary,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            SendInvitationsScreen().launch(context);
                          },
                        ),
                        SettingItemWidget(
                          title: language.blockedAccounts,
                          titleTextStyle: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite),
                          leading: Image.asset(ic_close_square,
                              height: 18,
                              width: 18,
                              color: appColorPrimary,
                              fit: BoxFit.cover),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: appStore.isDarkMode ? bodyDark : bodyWhite,
                              size: 16),
                          onTap: () {
                            BlockedAccounts().launch(context);
                          },
                        ),
                        Observer(
                          builder: (_) => SettingItemWidget(
                            title: language.requestVerification,
                            titleTextStyle: primaryTextStyle(
                                color:
                                    appStore.isDarkMode ? bodyDark : bodyWhite),
                            leading: Image.asset(ic_tick_square,
                                height: 18,
                                width: 18,
                                color: appColorPrimary,
                                fit: BoxFit.cover),
                            trailing: appStore.verificationStatus ==
                                        VerificationStatus.accepted ||
                                    appStore.verificationStatus ==
                                        VerificationStatus.pending
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: appStore.verificationStatus ==
                                                VerificationStatus.accepted
                                            ? appGreenColor
                                            : context.primaryColor,
                                        borderRadius: radius(4)),
                                    child: Text(
                                        appStore.verificationStatus
                                            .capitalizeFirstLetter(),
                                        style: secondaryTextStyle(
                                            color: Colors.white)),
                                  )
                                : Offstage(),
                            onTap: () {
                              if (appStore.verificationStatus ==
                                      VerificationStatus.rejected ||
                                  appStore.verificationStatus.isEmpty) {
                                if (pmpStore.pmpEnable) {
                                  if (pmpStore.pmpMembership != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return RequestVerificationDialog();
                                      },
                                    );
                                  } else {
                                    MembershipPlansScreen().launch(context);
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return RequestVerificationDialog();
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SettingItemWidget(
                          title: language.deleteAccount,
                          titleTextStyle:
                              primaryTextStyle(color: Colors.redAccent),
                          leading: Image.asset(ic_delete,
                              height: 18,
                              width: 18,
                              color: Colors.redAccent,
                              fit: BoxFit.cover),
                          onTap: () {
                            showConfirmDialogCustom(
                              context,
                              onAccept: (c) {
                                ifNotTester(() async {
                                  appStore.setLoading(true);
                                  await deleteAccount().then((value) {
                                    toast(value.message);
                                    appStore.setVerificationStatus(
                                        VerificationStatus.pending);
                                    logout(context, setId: false);
                                  }).catchError((e) {
                                    appStore.setLoading(false);
                                    toast(e.toString());
                                  });
                                });
                              },
                              dialogType: DialogType.DELETE,
                              title: language.deleteAccountConfirmation,
                            );
                          },
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        showConfirmDialogCustom(
                          context,
                          primaryColor: appColorPrimary,
                          title: language.logoutConfirmation,
                          onAccept: (s) {
                            logout(context);
                          },
                        );
                      },
                      child: Text(language.logout,
                          style: boldTextStyle(color: context.primaryColor)),
                    ).paddingAll(16),
                    30.height,
                  ],
                ),
              ),
              LoadingWidget().center().visible(appStore.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
