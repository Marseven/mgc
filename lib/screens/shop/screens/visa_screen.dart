import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/cart_badge_model.dart';
import 'package:socialv/models/woo_commerce/billing_address_model.dart';
import 'package:socialv/models/woo_commerce/cart_item_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/models/woo_commerce/payment_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/settings/screens/edit_shop_details_screen.dart';
import 'package:socialv/screens/shop/components/ebilling_component.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/screens/ebilling_screen.dart';
import 'package:socialv/screens/shop/screens/order_detail_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class VisaScreen extends StatefulWidget {
  final CartModel cartDetails;
  final bill_id;
  final order;

  VisaScreen(
      {required this.cartDetails, required this.bill_id, required this.order});

  @override
  State<VisaScreen> createState() => _VisaScreenState();
}

enum Operator { airtelmoney, moovmoney, visamastercard }

class _VisaScreenState extends State<VisaScreen> {
  late CartModel cart;

  bool isError = false;
  bool isChange = false;
  bool isPaymentGatewayLoading = true;

  PaymentModel? selectedPaymentMethod;

  List<PaymentModel> paymentGateways = [];

  final TextEditingController airtelmoney = TextEditingController();
  final TextEditingController moovmoney = TextEditingController();

  bool _isLoading = false;
  bool _retry = false;

  var bill_id;
  var order;
  var url = Uri.parse(Helpers.baseUrl + '/api/v1/merchant/e_bills');
  var username = "JOBS";
  var sharedkey = "6fb9b1b9-8119-4142-9cc1-96db5267631e";

  Operator? _operator = Operator.airtelmoney;

  Timer? _check_timer;
  int _start = 300;

  @override
  void initState() {
    cart = widget.cartDetails;
    billingAddress = widget.cartDetails.billingAddress!;
    bill_id = widget.bill_id;
    order = widget.order;
    print(bill_id);
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
    var url =
        Uri.parse(Helpers.baseUrl + '/api/v1/merchant/e_bills/' + bill_id);

    var credentials = username + ':' + sharedkey;
    List<int> mydataint = utf8.encode(credentials);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Basic ' + base64.encode(mydataint),
    });

    var result = jsonDecode(response.body);
    print(result);

    if (result["state"] == "processed" || result["state"] == "paid") {
      setState(() {
        _isLoading = false;
      });
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

      await getOrderList(status: OrderStatus.any).then((value) {
        value.forEach((element) {
          if (element.id == order.id) {
            setState(() {
              order = element;
            });
          }
        });
      }).catchError((e) {
        isError = true;
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });

      cartBadge.updateCartCount(0);
      appStore.setWooCart(0);

      appStore.setLoading(false);
      finish(context);
      finish(context);

      OrderDetailScreen(orderDetails: order).launch(context);

      //message
      toast('Commande payée avec succès.');
    } else {
      _start = _start - 10;
    }

    if (_start == 0) {
      _check_timer!.cancel();
      setState(() {
        _isLoading = false;
        _retry = true;
        _start = 300;
      });
      EbillingScreen(
        cartDetails: cart!,
        bill_id: bill_id,
        order: order,
      ).launch(context).then((value) async {
        if (value ?? false) {
          await getCart();
        }
      });
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
                'https://test.billing-easy.net?invoice=$bill_id&operator=ORABANK_NG&redirect=1')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://test.billing-easy.net?invoice=$bill_id&operator=ORABANK_NG&redirect=1'));

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
