import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/cart_badge_model.dart';
import 'package:socialv/models/woo_commerce/cart_item_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/auth/screens/sign_in_screen.dart';
import 'package:socialv/screens/dashboard_screen.dart';
import 'package:socialv/screens/post/screens/single_post_screen.dart';

import '../utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  final int? activityId;

  const SplashScreen({this.activityId});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

List<CartItemModel> cartItemList = [];

class _SplashScreenState extends State<SplashScreen> {
  CartModel? cart;
  bool isError = false;

  int total = 0;

  late CartBadge cartBadge;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialisez myState en utilisant Provider
    cartBadge = Provider.of<CartBadge>(context);
  }

  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
    init();
    getCart();
  }

  void getCart() async {
    var count = 0;
    await getCartDetails().then((value) {
      cart = value;
      cartItemList.addAll(value.items.validate());
    }).catchError((e) {
      isError = true;
      toast(e.toString(), print: true);
    });

    cartItemList.forEach((element) {
      setState(() {
        count = count + element.quantity!.toInt();
      });
    });
    cartBadge.updateCartCount(count);
    appStore.setWooCart(count);
  }

  Future<void> init() async {
    getGeneralSettings();

    afterBuildCreated(() {
      appStore.setLanguage(getStringAsync(SharePreferencesKey.LANGUAGE,
          defaultValue: Constants.defaultLanguage));

      int themeModeIndex = getIntAsync(SharePreferencesKey.APP_THEME,
          defaultValue: AppThemeMode.ThemeModeSystem);
      if (themeModeIndex == AppThemeMode.ThemeModeSystem) {
        appStore.toggleDarkMode(
            value:
                MediaQuery.of(context).platformBrightness != Brightness.light,
            isFromMain: true);
      }
    });

    if (await isAndroid12Above()) {
      await 500.milliseconds.delay;
    } else {
      await 2.seconds.delay;
    }

    if (widget.activityId != null) {
      if (appStore.isLoggedIn) {
        SinglePostScreen(postId: widget.activityId.validate())
            .launch(context, isNewTask: true);
      } else {
        SignInScreen(activityId: widget.activityId.validate())
            .launch(context, isNewTask: true);
      }
    } else if (appStore.isLoggedIn && !isTokenExpire) {
      DashboardScreen().launch(context, isNewTask: true);
    } else {
      SignInScreen().launch(context, isNewTask: true);
    }
  }

  Future<void> getGeneralSettings() async {
    await generalSettings().then((value) {
      appStore
          .setAuthVerificationEnable(value.isAccountVerificationRequire == 1);
      pmpStore.setPmpEnable(value.isPaidMembershipEnable.validate());
    }).catchError(onError);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                50.height,
                Image.asset(
                  APP_ICON,
                  height: 100,
                  width: 104,
                  fit: BoxFit.cover,
                ),
                10.width,
                Text(APP_NAME,
                    style: boldTextStyle(color: appColorSecondary, size: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
