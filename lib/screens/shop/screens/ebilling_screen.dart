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
import 'package:socialv/screens/shop/screens/order_detail_screen.dart';
import 'package:socialv/screens/shop/screens/visa_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:http/http.dart' as http;

class EbillingScreen extends StatefulWidget {
  final CartModel cartDetails;
  final bill_id;
  final order;

  EbillingScreen(
      {required this.cartDetails, required this.bill_id, required this.order});

  @override
  State<EbillingScreen> createState() => _EbillingScreenState();
}

enum Operator { airtelmoney, moovmoney, visamastercard }

class _EbillingScreenState extends State<EbillingScreen> {
  late CartModel cart;

  bool isError = false;
  bool isChange = false;
  bool isPaymentGatewayLoading = true;

  int mPage = 1;
  bool mIsLastPage = false;

  PaymentModel? selectedPaymentMethod;

  List<PaymentModel> paymentGateways = [];

  final TextEditingController airtelmoney = TextEditingController();
  final TextEditingController moovmoney = TextEditingController();

  bool _isLoading = false;
  bool _retry = false;

  var bill_id;
  var order;
  var msisdn;
  var payment_system_name;
  var url = Uri.parse(Helpers.baseUrl + '/api/v1/merchant/e_bills');
  var username = "JOBS";
  var sharedkey = "6fb9b1b9-8119-4142-9cc1-96db5267631e";

  Operator? _operator = Operator.airtelmoney;

  Timer? _check_timer;
  int _start = 80;

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

  Future<void> placeOrder() async {
    ifNotTester(() async {
      Map request = {
        "payment_method": selectedPaymentMethod!.id,
        "payment_method_title": selectedPaymentMethod!.title,
        "set_paid": false,
        'customer_id': appStore.loginUserId,
        'status': "pending",
        "billing": cart.billingAddress!.toJson(),
        "shipping": cart.shippingAddress!.toJson(),
        "line_items": cart.items!.map((e) {
          return {"product_id": e.id, "quantity": e.quantity};
        }).toList(),
        "shipping_lines": [
          {
            "method_id": "flat_rate",
            "method_title": "Flat Rate",
            "total": getPrice(cart.totals!.totalPrice.validate())
          }
        ]
      };

      appStore.setLoading(true);

      await createOrder(request: request).then((value) async {
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

        appStore.setLoading(false);
        finish(context);
        finish(context);
        OrderDetailScreen(orderDetails: value).launch(context);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
    });
  }

  void _payer(context) async {
    setState(() {
      _isLoading = true;
    });
    var credentials = username + ':' + sharedkey;
    List<int> mydataint = utf8.encode(credentials);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_operator == Operator.airtelmoney) {
      var check_number = Helpers.verifyNumberGabon(airtelmoney.text);
      if (check_number == null) {
        msisdn = airtelmoney.text;
        payment_system_name = "airtelmoney";
        var url = Uri.parse(Helpers.baseUrl +
            '/api/v1/merchant/e_bills/' +
            bill_id +
            '/ussd_push');

        var response = await http.post(url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              HttpHeaders.authorizationHeader:
                  'Basic ' + base64.encode(mydataint),
            },
            body: jsonEncode(<String, String>{
              "payment_system_name": payment_system_name,
              "payer_msisdn": msisdn,
            }));

        print(json.decode(response.body));

        _check_timer = Timer.periodic(
            const Duration(seconds: 10), (Timer t) => checkBilling());

        if (_start == 0) {
          _check_timer!.cancel();
          setState(() {
            _isLoading = false;
            _start = 80;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(check_number, style: TextStyle(fontSize: 16))));
      }
    } else if (_operator == Operator.moovmoney) {
      var check_number = Helpers.verifyNumberGabon(moovmoney.text);
      if (check_number == null) {
        msisdn = moovmoney.text;
        payment_system_name = "moovmoney4";
        var url = Uri.parse(Helpers.baseUrl +
            '/api/v1/merchant/e_bills/' +
            bill_id +
            '/ussd_push');

        var response = await http.post(url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              HttpHeaders.authorizationHeader:
                  'Basic ' + base64.encode(mydataint),
            },
            body: jsonEncode(<String, String>{
              "payment_system_name": payment_system_name,
              "payer_msisdn": msisdn,
            }));

        print(json.decode(response.body));

        _check_timer = Timer.periodic(
            const Duration(seconds: 10), (Timer t) => checkBilling());

        if (_start == 0) {
          _check_timer!.cancel();
          setState(() {
            _isLoading = false;
            _start = 80;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(check_number, style: TextStyle(fontSize: 16))));
      }
    } else if (_operator == Operator.visamastercard) {
      VisaScreen(
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

  void checkBilling() async {
    var url =
        Uri.parse(Helpers.baseUrl + '/api/v1/merchant/e_bills/' + bill_id);

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

      cartBadge.updateCartCount(0);
      appStore.setWooCart(0);

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
        _start = 80;
      });
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     backgroundColor: Colors.redAccent,
      //     content: Text(
      //         result["message"] + " Veuillez réessayer s'il vous plaît !",
      //         style: TextStyle(fontSize: 16))));
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
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(defaultAppButtonRadius)),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile<Operator>(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/am.png',
                                height: 75,
                                width: 75,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Airtel Money',
                                      style: TextStyle(
                                              color: appStore.isDarkMode
                                                  ? bodyDark
                                                  : bodyWhite)
                                          .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: Operator.airtelmoney,
                          groupValue: _operator,
                          onChanged: (Operator? value) {
                            setState(() {
                              _operator = value;
                            });
                          },
                        ),
                        _operator == Operator.airtelmoney
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Color.fromARGB(255, 232, 234, 236),
                                      border: Border.all(
                                          color:
                                              Color.fromRGBO(243, 246, 249, 1),
                                          width: 1)),
                                  margin: EdgeInsets.symmetric(vertical: 5.0),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: TextFormField(
                                    controller: airtelmoney,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                        color: appStore.isDarkMode
                                            ? bodyWhite
                                            : bodyWhite),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(9),
                                    ],
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.phone,
                                          color: appColorPrimary),
                                      hintText: "077XXXXXX",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 156, 156, 167)),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 2,
                              ),
                      ],
                    ),
                  ),
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(defaultAppButtonRadius)),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile<Operator>(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/mm.png',
                                height: 75,
                                width: 75,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Moov Money',
                                      style: TextStyle(
                                              color: appStore.isDarkMode
                                                  ? bodyDark
                                                  : bodyWhite)
                                          .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: Operator.moovmoney,
                          groupValue: _operator,
                          onChanged: (Operator? value) {
                            setState(() {
                              _operator = value;
                            });
                          },
                        ),
                        _operator == Operator.moovmoney
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Color.fromARGB(255, 232, 234, 236),
                                      border: Border.all(
                                          color:
                                              Color.fromRGBO(243, 246, 249, 1),
                                          width: 1)),
                                  margin: EdgeInsets.symmetric(vertical: 5.0),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: TextFormField(
                                    controller: moovmoney,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                        color: appStore.isDarkMode
                                            ? bodyWhite
                                            : bodyWhite),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(9),
                                    ],
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.phone,
                                          color: appColorPrimary),
                                      hintText: "066XXXXXX",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 156, 156, 167)),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 2,
                              ),
                      ],
                    ),
                  ),
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(defaultAppButtonRadius)),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile<Operator>(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/vm.png',
                                height: 75,
                                width: 75,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Visa & Mastercard',
                                      style: TextStyle(
                                              color: appStore.isDarkMode
                                                  ? bodyDark
                                                  : bodyWhite)
                                          .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: Operator.visamastercard,
                          groupValue: _operator,
                          onChanged: (Operator? value) {
                            setState(() {
                              _operator = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  10.height,
                  _isLoading
                      ? ThreeBounceLoadingWidget()
                      : appButton(
                          context: context,
                          text: !_retry ? "Payer" : "Réessayer",
                          onTap: () async {
                            if (cart.items.validate().isNotEmpty) {
                              if (cart.billingAddress!.address_1.validate().isNotEmpty ||
                                  cart.billingAddress!.address_2
                                      .validate()
                                      .isNotEmpty ||
                                  cart.billingAddress!.city
                                      .validate()
                                      .isNotEmpty) {
                                _payer(context);
                              } else {
                                toast(language.pleaseEnterValidBilling);
                              }
                            } else {
                              toast(language.yourCartIsCurrentlyEmpty);
                            }
                          },
                        ),
                  50.height,
                ],
              ).paddingSymmetric(horizontal: 16),
            ),
            Observer(
                builder: (_) =>
                    LoadingWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
//     .catchError((e) {
// isPaymentGatewayLoading = false;
// toast(e.toString(), print: true);
// setState(() {});
// });
