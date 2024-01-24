import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/mec/booking_model.dart';
import 'package:socialv/models/mec/event_detail_model.dart';
import 'package:socialv/models/mec/price_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/event/screens/ebilling_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:http/http.dart' as http;

class RegisterComponent extends StatefulWidget {
  final int eventId;
  final List<PriceModel> priceList;
  final Future<List<PriceModel>> future;

  RegisterComponent(
      {required this.eventId, required this.future, required this.priceList});

  @override
  State<RegisterComponent> createState() => _RegisterComponentState();
}

class _RegisterComponentState extends State<RegisterComponent> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController index = TextEditingController();
  TextEditingController qty = TextEditingController();
  String? sexe;
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  // Variable pour suivre la sélection
  String? price;

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode indexFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode qtyFocus = FocusNode();

  bool isError = false;
  bool isFetched = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Tarifs", style: boldTextStyle(size: 20)),
              ],
            ),
            10.height,
            Container(
              height: 100,
              child: FutureBuilder<List<PriceModel>>(
                future: widget.future,
                initialData: [],
                builder: (ctx, snap) {
                  if (snap.hasError) {
                    return NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: isError
                          ? language.somethingWentWrong
                          : language.noDataFound,
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center();
                  }

                  if (snap.hasData) {
                    if (snap.data.validate().isEmpty) {
                      return NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: isError
                            ? language.somethingWentWrong
                            : language.noDataFound,
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center();
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: widget.priceList.length,
                          itemBuilder: (context, index) {
                            return RadioListTile(
                              title: Text(
                                  widget.priceList[index].label.toString() +
                                      ' - ' +
                                      widget.priceList[index].price.toString() +
                                      ' FCFA',
                                  style: boldTextStyle(size: 18)),
                              value: widget.priceList[index].id,
                              groupValue: price,
                              onChanged: (value) {
                                setState(() {
                                  price = value;
                                });
                              },
                            );
                          },
                        ),
                      );
                    }
                  }
                  return Offstage();
                },
              ),
            ),
            16.height,
            Container(
              decoration: BoxDecoration(
                borderRadius: radius(defaultAppButtonRadius),
                border: Border.all(
                  color: context.primaryColor
                      .withOpacity(0.5), // Couleur de la première bordure
                  width: 1.0, // Largeur de la première bordure
                ),
              ),
              child: AppTextField(
                focus: qtyFocus,
                nextFocus: firstNameFocus,
                enabled: !appStore.isLoading,
                controller: qty,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context,
                    label: 'Nombre de Réservation',
                    fillColor: context.scaffoldBackgroundColor),
              ),
            ),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: context.width() / 2 - 20,
                  decoration: BoxDecoration(
                    borderRadius: radius(defaultAppButtonRadius),
                    border: Border.all(
                      color: context.primaryColor
                          .withOpacity(0.5), // Couleur de la première bordure
                      width: 1.0, // Largeur de la première bordure
                    ),
                  ),
                  child: AppTextField(
                    focus: firstNameFocus,
                    nextFocus: lastNameFocus,
                    enabled: !appStore.isLoading,
                    controller: firstName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(),
                    maxLines: 1,
                    decoration: inputDecorationFilled(context,
                        label: language.firstName,
                        fillColor: context.scaffoldBackgroundColor),
                  ),
                ),
                Container(
                  width: context.width() / 2 - 20,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: radius(defaultAppButtonRadius),
                    border: Border.all(
                      color: context.primaryColor
                          .withOpacity(0.5), // Couleur de la première bordure
                      width: 1.0, // Largeur de la première bordure
                    ),
                  ),
                  child: AppTextField(
                    focus: lastNameFocus,
                    nextFocus: indexFocus,
                    enabled: !appStore.isLoading,
                    controller: lastName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(),
                    maxLines: 1,
                    decoration: inputDecorationFilled(context,
                        label: language.lastName,
                        fillColor: context.scaffoldBackgroundColor),
                  ),
                ),
              ],
            ),
            16.height,
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor,
                borderRadius: radius(defaultAppButtonRadius),
                border: Border.all(
                  color: context.primaryColor
                      .withOpacity(0.5), // Couleur de la première bordure
                  width: 1.0, // Largeur de la première bordure
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(commonRadius),
                  icon: Icon(Icons.arrow_drop_down,
                      color: appStore.isDarkMode ? bodyDark : bodyWhite),
                  elevation: 8,
                  isExpanded: true,
                  hint: Text("Choisissez le sexe",
                      style: secondaryTextStyle(weight: FontWeight.w600)),
                  items: <String>['Homme', 'Femme'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: sexe,
                  onChanged: (String? newValue) {
                    // Gérer la sélection du sexe ici
                    setState(() {
                      sexe = newValue;
                    });
                  },
                ),
              ),
            ),
            16.height,
            Container(
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: radius(defaultAppButtonRadius),
                border: Border.all(
                  color: context.primaryColor
                      .withOpacity(0.5), // Couleur de la première bordure
                  width: 1.0, // Largeur de la première bordure
                ),
              ),
              child: AppTextField(
                enabled: !appStore.isLoading,
                controller: index,
                focus: indexFocus,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context,
                    label: 'Index', fillColor: context.scaffoldBackgroundColor),
              ),
            ),
            16.height,
            Container(
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: radius(defaultAppButtonRadius),
                border: Border.all(
                  color: context.primaryColor
                      .withOpacity(0.5), // Couleur de la première bordure
                  width: 1.0, // Largeur de la première bordure
                ),
              ),
              child: AppTextField(
                enabled: !appStore.isLoading,
                controller: phone,
                focus: phoneFocus,
                readOnly: false,
                nextFocus: emailFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                textFieldType: TextFieldType.PHONE,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context,
                    label: language.phone,
                    fillColor: context.scaffoldBackgroundColor),
              ),
            ),
            16.height,
            Container(
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: radius(defaultAppButtonRadius),
                border: Border.all(
                  color: context.primaryColor
                      .withOpacity(0.5), // Couleur de la première bordure
                  width: 1.0, // Largeur de la première bordure
                ),
              ),
              child: AppTextField(
                enabled: !appStore.isLoading,
                controller: email,
                focus: emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                textFieldType: TextFieldType.EMAIL,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context,
                    label: language.email,
                    fillColor: context.scaffoldBackgroundColor),
              ),
            ),
            16.height,
            appButton(
              context: context,
              text: "Valider",
              onTap: () => _register(),
            ),
          ],
        ),
      ),
    );
  }

  _register() async {
    appStore.setLoading(true);

    var lastname = lastName.text;
    var firstname = firstName.text;
    var gender = sexe == "Homme" ? "H" : "F";
    var indexPlayer = index.text;
    var _email = email.text;
    var _phone = phone.text;
    var url = Uri.parse(BASE_URL + APIEndPoint.eventRegister);
    print(url);
    var response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          "lastname": lastname,
          "firstname": firstname,
          "sexe": gender.toString(),
          "index_player": indexPlayer,
          "email": _email,
          "phone": _phone,
          "qty": qty.text,
          "price_id": price!,
          "event_id": widget.eventId.toString(),
          "customer_id": appStore.loginUserId,
        }));

    print(json.decode(response.body));
    var result = json.decode(response.body);

    if (result["success"] == true) {
      EventDetailModel event = EventDetailModel();
      BookingModel booking = BookingModel();

      await getEventDetail(eventId: widget.eventId.validate()).then((value) {
        isFetched = true;
        setState(() {});
        event = value;
      }).catchError((e) {
        log('Error: ${e.toString()}');
        isError = true;
        setState(() {});
      });

      await getBooking(booking: result["data"]['book_id']).then((value) {
        isFetched = true;
        setState(() {});
        booking = value;
      }).catchError((e) {
        log('Error: ${e.toString()}');
        isError = true;
        setState(() {});
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text(result["message"], style: TextStyle(fontSize: 16))));
      appStore.setLoading(false);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => EbillingBookScreen(
                    billId: result["data"]['bill_id'],
                    booking: booking,
                    event: event,
                  )));
    } else {
      appStore.setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(result["message"], style: TextStyle(fontSize: 16))));
    }
  }
}
