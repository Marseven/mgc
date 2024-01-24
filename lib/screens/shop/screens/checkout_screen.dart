import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  final CartModel cartDetails;

  CheckoutScreen({required this.cartDetails});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late CartModel cart;

  bool isError = false;
  bool isChange = false;
  bool isPaymentGatewayLoading = true;

  PaymentModel? selectedPaymentMethod;

  List<PaymentModel> paymentGateways = [];
  BillingAddressModel billingAddress = BillingAddressModel();

  TextEditingController orderNotesController = TextEditingController();

  @override
  void initState() {
    cart = widget.cartDetails;
    billingAddress = widget.cartDetails.billingAddress!;
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
      var bill_id;
      await createOrder(request: request).then((value) async {
        if (orderNotesController.text.isNotEmpty) {
          Map noteRequest = {
            "note": orderNotesController.text.trim(),
            "customer_note": true
          };

          await createOrderNotes(
                  request: noteRequest, orderId: value.id.validate())
              .then((value) {})
              .catchError((e) {
            log('Order Note Error: ${e.toString()}');
          });
        }

        var url = Uri.parse(Helpers.baseUrl + '/api/v1/merchant/e_bills');
        var username = "JOBS";
        var sharedkey = "6fb9b1b9-8119-4142-9cc1-96db5267631e";
        var credentials = username + ':' + sharedkey;
        List<int> mydataint = utf8.encode(credentials);

        var response = await http.post(url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              HttpHeaders.authorizationHeader:
                  'Basic ' + base64.encode(mydataint),
            },
            body: jsonEncode({
              "email": false,
              "sms": false,
              "payer_email": cart.billingAddress!.email.validate().toString(),
              "payer_msisdn": cart.billingAddress!.phone.validate().toString(),
              "amount": cart.totals!.totalPrice.validate(),
              "short_description": "Paiement MGC pour commande N°" +
                  value.id.validate().toString(),
              "external_reference": value.id.validate().toString(),
              "payer_name":
                  cart.billingAddress!.firstName.validate().toString(),
              "expiry_period": 60,
            }));

        var result = jsonDecode(response.body);

        bill_id = result['e_bill']['bill_id'];

        appStore.setLoading(false);
        finish(context);
        EbillingScreen(
          cartDetails: cart,
          bill_id: bill_id,
          order: value,
        ).launch(context).then((value) async {
          if (value ?? false) {
            await getCart();
          }
        });
      }).catchError((e) {
        appStore.setLoading(false);
        print(e.toString());
        toast(e.toString(), print: true);
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
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
          title: Text(language.checkout, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.products, style: boldTextStyle()),
                  16.height.visible(cart.items.validate().isNotEmpty),
                  if (cart.items.validate().isNotEmpty)
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cart.items!.length,
                      itemBuilder: (ctx, index) {
                        CartItemModel cartItem = cart.items![index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cachedImage(
                              cartItem.images.validate().isNotEmpty
                                  ? cartItem.images!.first.src.validate()
                                  : '',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(4),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cartItem.name.validate(),
                                    style: primaryTextStyle()),
                                Text(
                                    '${cartItem.quantity.validate()} * ${getPrice(cartItem.prices!.price.validate())} ${getPrice(cartItem.prices!.currencySymbol.validate())}',
                                    style: secondaryTextStyle()),
                              ],
                            ).expand(),
                            PriceWidget(
                                price: getPrice(
                                        cartItem.totals!.lineTotal.validate())
                                    .toString(),
                                size: 16),
                            16.width,
                            Image.asset(ic_delete,
                                    color: Colors.red,
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.cover)
                                .onTap(() {
                              showConfirmDialogCustom(
                                context,
                                onAccept: (c) {
                                  appStore.setLoading(true);
                                  var count = appStore.wooCart -
                                      cartItem.quantity.validate();
                                  if (count < 0) count = 0;
                                  cartBadge.updateCartCount(count);
                                  appStore.setWooCart(count);
                                  removeCartItem(
                                          productKey: cartItem.key.validate())
                                      .then((value) {
                                    toast(language.itemRemovedSuccessfully);
                                    getCart();
                                    isChange = true;
                                  }).catchError((e) {
                                    appStore.setLoading(false);

                                    toast(e.toString(), print: true);
                                  });
                                },
                                dialogType: DialogType.CONFIRMATION,
                                title: language.removeFromCartConfirmation,
                                positiveText: language.remove,
                              );
                            },
                                    splashColor: Colors.transparent,
                                    highlightColor:
                                        Colors.transparent).paddingSymmetric(
                                    vertical: 4),
                          ],
                        ).paddingSymmetric(vertical: 8);
                      },
                    )
                  else
                    Text(language.yourCartIsCurrentlyEmpty,
                        style: secondaryTextStyle()),
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(commonRadius)),
                    padding: EdgeInsets.only(
                        left: 16, right: 8, bottom: 16, top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${language.total}: ', style: boldTextStyle()),
                        PriceWidget(
                            price:
                                getPrice(cart.totals!.totalPrice.validate())),
                      ],
                    ),
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.billingAddress, style: boldTextStyle()),
                      Image.asset(ic_edit,
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                              color: context.primaryColor)
                          .onTap(() {
                        EditShopDetailsScreen().launch(context).then((value) {
                          if (value ?? false) getCart();
                        });
                      }),
                    ],
                  ),
                  10.height,
                  Wrap(
                    children: [
                      Text('${billingAddress.company}, ',
                              style: secondaryTextStyle())
                          .visible(
                              billingAddress.company.validate().isNotEmpty),
                      Text('${billingAddress.address_1}, ',
                              style: secondaryTextStyle())
                          .visible(
                              billingAddress.address_1.validate().isNotEmpty),
                      Text('${billingAddress.address_2}, ',
                              style: secondaryTextStyle())
                          .visible(
                              billingAddress.address_2.validate().isNotEmpty),
                      Text('${billingAddress.city}, ',
                              style: secondaryTextStyle())
                          .visible(billingAddress.city.validate().isNotEmpty),
                      Text('${billingAddress.state}, ',
                              style: secondaryTextStyle())
                          .visible(billingAddress.state.validate().isNotEmpty),
                      Text('${billingAddress.country}',
                              style: secondaryTextStyle())
                          .visible(
                              billingAddress.country.validate().isNotEmpty),
                    ],
                  ),
                  Text('${language.postCode}: ${billingAddress.postcode}',
                          style: secondaryTextStyle())
                      .visible(billingAddress.postcode.validate().isNotEmpty),
                  Text('${language.phone}: ${billingAddress.phone}',
                          style: secondaryTextStyle())
                      .visible(billingAddress.phone.validate().isNotEmpty),
                  Text('${language.email}: ${billingAddress.email}',
                          style: secondaryTextStyle())
                      .visible(billingAddress.email.validate().isNotEmpty),
                  16.height,
                  Text(language.selectPaymentMethod, style: boldTextStyle()),
                  !isPaymentGatewayLoading
                      ? paymentGateways.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: radius(defaultAppButtonRadius)),
                              margin: EdgeInsets.symmetric(vertical: 16),
                              padding: EdgeInsets.all(16),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: paymentGateways.length,
                                itemBuilder: (ctx, index) {
                                  if (paymentGateways[index].id.validate() ==
                                      'ebilling') {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                                selectedPaymentMethod ==
                                                        paymentGateways[index]
                                                    ? Icons.radio_button_checked
                                                    : Icons.radio_button_off,
                                                color: context.primaryColor,
                                                size: 20),
                                            8.width,
                                            Text(
                                                paymentGateways[index]
                                                    .title
                                                    .toString()
                                                    .validate(),
                                                style: primaryTextStyle()),
                                          ],
                                        ),
                                        Container(
                                          child: Text(
                                              paymentGateways[index]
                                                  .description
                                                  .validate(),
                                              style:
                                                  secondaryTextStyle(size: 12)),
                                          decoration: BoxDecoration(
                                              color: context
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                                  radius(commonRadius)),
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.only(top: 4),
                                        ).visible(selectedPaymentMethod ==
                                            paymentGateways[index])
                                      ],
                                    ).onTap(() {
                                      selectedPaymentMethod =
                                          paymentGateways[index];
                                      setState(() {});
                                    },
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent);
                                  } else {
                                    return Offstage();
                                  }
                                },
                              ),
                            )
                          : Text(language.paymentGatewaysNotFound,
                              style: secondaryTextStyle())
                      : ThreeBounceLoadingWidget(),
                  16.height,
                  Text(language.placeOrderText, style: secondaryTextStyle()),
                  16.height,
                  RichText(
                    text: TextSpan(
                      text: '${language.addOrderNotes} ',
                      style: boldTextStyle(),
                      children: <TextSpan>[
                        TextSpan(
                            text: '(${language.optional})',
                            style: secondaryTextStyle(size: 12)),
                      ],
                    ),
                  ),
                  10.height,
                  Text(language.notesAboutYourOrder,
                      style: secondaryTextStyle()),
                  16.height,
                  AppTextField(
                    controller: orderNotesController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    textFieldType: TextFieldType.MULTILINE,
                    textStyle: boldTextStyle(),
                    minLines: 3,
                    maxLines: 3,
                    decoration: inputDecorationFilled(context,
                        fillColor: context.cardColor, label: 'Notes'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language.pleaseEnterDescription;
                      }
                      return null;
                    },
                  ),
                  16.height,
                  appButton(
                    context: context,
                    text: language.placeOrder,
                    onTap: () async {
                      if (cart.items.validate().isNotEmpty) {
                        if (cart.billingAddress!.address_1.validate().isNotEmpty ||
                            cart.billingAddress!.address_2
                                .validate()
                                .isNotEmpty ||
                            cart.billingAddress!.city.validate().isNotEmpty) {
                          placeOrder();
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
