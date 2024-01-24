import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/cart_badge_model.dart';
import 'package:socialv/models/mec/booking_model.dart';
import 'package:socialv/models/mec/event_detail_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/models/woo_commerce/payment_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/event/screens/booking_detail_screen.dart';
import 'package:socialv/screens/event/screens/ebilling_screen.dart';
import 'package:socialv/screens/settings/screens/edit_shop_details_screen.dart';
import 'package:socialv/screens/shop/components/ebilling_component.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class VisaBookScreen extends StatefulWidget {
  final String billId;
  final BookingModel booking;
  final EventDetailModel event;

  VisaBookScreen({
    required this.billId,
    required this.booking,
    required this.event,
  });

  @override
  State<VisaBookScreen> createState() => _VisaBookScreenState();
}

enum Operator { airtelmoney, moovmoney, visamastercard }

class _VisaBookScreenState extends State<VisaBookScreen> {
  late CartModel cart;

  bool isError = false;
  bool isChange = false;
  bool isPaymentGatewayLoading = true;

  PaymentModel? selectedPaymentMethod;

  List<PaymentModel> paymentGateways = [];

  final TextEditingController airtelmoney = TextEditingController();
  final TextEditingController moovmoney = TextEditingController();

  var billId;
  var event;
  var booking;
  var url = Uri.parse(Helpers.baseUrl + '/api/v1/merchant/e_bills');
  var username = "JOBS";
  var sharedkey = "6fb9b1b9-8119-4142-9cc1-96db5267631e";

  Timer? _check_timer;
  int _start = 300;

  @override
  void initState() {
    event = widget.event;
    billId = widget.billId;
    booking = widget.booking;
    print(billId);
    super.initState();
    init();
  }

  Future<void> init() async {
    isPaymentGatewayLoading = true;
    setState(() {});

    await getPaymentMethods().then((value) {
      paymentGateways.addAll(value);
      selectedPaymentMethod =
          value.firstWhere((element) => element.id == 'ebilling');
      isPaymentGatewayLoading = false;
      setState(() {});
    }).catchError((e) {
      isPaymentGatewayLoading = false;
      toast(e.toString(), print: true);
      setState(() {});
    });
  }

  Future<void> getCart({String? orderBy}) async {
    appStore.setLoading(true);

    await getCartDetails().then((value) {
      cart = value;
      billingAddress = value.billingAddress!;
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void checkBilling() async {
    var url = Uri.parse(Helpers.baseUrl + '/api/v1/merchant/e_bills/' + billId);

    var credentials = username + ':' + sharedkey;
    List<int> mydataint = utf8.encode(credentials);
    var response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Basic ' + base64.encode(mydataint),
    });

    var result = jsonDecode(response.body);
    print(result);

    if (result["state"] == "processed" || result["state"] == "paid") {
      _check_timer!.cancel();

      cart.items!.forEach((element) {
        removeCartItem(productKey: element.key.validate()).then((value) {
          log('removed');
        }).catchError((e) {
          //
        });
      });

      cart.coupons!.forEach((coupon) {
        removeCoupon(code: coupon.code.validate()).then((value) {
          log('Coupon removed');
        }).catchError((e) {
          log('error remove coupon: ${e.toString()}');
        });
      });

      cartBadge.updateCartCount(0);
      appStore.setWooCart(0);

      appStore.setLoading(false);
      finish(context);
      finish(context);

      BookingDetailScreen(
        booking: booking,
        event: event,
      ).launch(context);

      //message
      toast('Commande payée avec succès.');
    } else {
      _start = _start - 10;
    }

    if (_start == 0) {
      _check_timer!.cancel();
      setState(() {
        _start = 300;
      });
      EbillingBookScreen(
        event: event,
        billId: billId,
        booking: booking,
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    airtelmoney.dispose();
    moovmoney.dispose();
    _check_timer!.cancel();
    super.dispose();
  }

  late CartBadge cartBadge;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialisez myState en utilisant Provider
    cartBadge = Provider.of<CartBadge>(context);
  }

  @override
  Widget build(BuildContext context) {
    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(
                'https://staging.billing-easy.net?invoice=$billId&operator=ORABANK_NG&redirect=1')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://staging.billing-easy.net?invoice=$billId&operator=ORABANK_NG&redirect=1'));

    return WillPopScope(
        onWillPop: () {
          finish(context, isChange);
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.iconColor),
              onPressed: () {
                finish(context, isChange);
              },
            ),
            titleSpacing: 0,
            title: Text(language.paymentMethod, style: boldTextStyle(size: 22)),
            elevation: 0,
            centerTitle: true,
          ),
          body: WebViewWidget(controller: controller),
        ));
  }
}
//     .catchError((e) {
// isPaymentGatewayLoading = false;
// toast(e.toString(), print: true);
// setState(() {});
// });
