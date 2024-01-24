import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:basic_utils/basic_utils.dart';
import 'package:intl/intl.dart';

enum CardType {
  Master,
  Visa,
  Verve,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
  Others,
  Invalid
}

class Helpers {
  static String baseUrl = "https://stg.billing-easy.com";
  static var headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };

  static String generateOtp() {
    var r = Random().nextInt(9999).toString().padLeft(4, '0');
    return r;
  }

  static sendOtp({contact, codeOtp}) async {
    var url = Uri.parse(baseUrl + "user/sendOtp");
    var response = await http.post(url,
        headers: headers,
        body: '{"contact": "$contact", "codeOtp": "$codeOtp" }');

    if (response.statusCode == 200) {
      var resultat = jsonDecode(response.body);
      print(resultat);
    } else {
      print(response.statusCode);
    }
  }

  static String formatNumber(number) {
    var s = StringUtils.reverse(number.round().toString());
    s = StringUtils.addCharAtPosition(s, " ", 3, repeat: true);
    print(s);
    return StringUtils.reverse(s);
  }

  static String statusOrder(status) {
    switch (status) {
      case "pending":
        return "En attente de paiement";
      case "processing":
        return "En cours de traitement";
      case "on-hold":
        return "En attente";
      case "completed":
        return "Complété";
      case "refunded":
        return "Remboursé";
      case "cancelled":
        return "Annulé";
      case "failed":
        return "Échec du paiement";
      case "partially-refunded":
        return "Remboursement partiel";
      default:
        return "Statut Invalide";
    }
  }

  static String formatMoney(amount, thousandSeparator, symbol) {
    var formatMoney =
        NumberFormat.currency(locale: 'eu', decimalDigits: 0, symbol: symbol)
            .format(amount);
    return formatMoney.replaceAll('.', thousandSeparator);
  }

  static double dynamicHeight(context, percent) {
    return MediaQuery.of(context).size.height * percent / 100;
  }

  static double dynamicWidth(context, percent) {
    return MediaQuery.of(context).size.width * percent / 100;
  }

  static String dateToStr(date, format) {
    var formatter = new DateFormat(format);
    return formatter.format(date);
  }

  static bool empty(data) {
    return data == '' ||
        data == null ||
        data == 'null' ||
        data == '00:00' ||
        data == false ||
        data == '0' ||
        data == 0;
  }

  static String? verifyNumberGabon(String? input) {
    String? numero = input;
    if (input == null || input.isEmpty) {
      return "Numéro de téléphone obligatoire";
    }
    if (numero!.isNotEmpty && numero.length == 9) {
      String indica = numero[0] + numero[1] + numero[2];
      switch (indica) {
        case "060":
          return null;
        case "062":
          return null;
        case "065":
          return null;
        case "066":
          return null;
        case "074":
          return null;
        case "076":
          return null;
        case "077":
          return null;
        case "60":
          return null;
        case "62":
          return null;
        case "65":
          return null;
        case "66":
          return null;
        case "74":
          return null;
        case "76":
          return null;
        case "77":
          return null;
        default:
          return "Numéro de téléphone invalide";
      }
    } else {
      return "Numéro de téléphone invalide";
    }
  }

  static String statut(input) {
    int? numero = int.parse(input);

    switch (numero) {
      case 0:
        return "Reçue";
      case 1:
        return "En cours";
      case 2:
        return "Approuvée";
      case 3:
        return "Refusée";
      case 4:
        return "Annulée";
      case 5:
        return "Payée";
      case 6:
        return "Traitée";
      case 7:
        return "Actif";
      case 8:
        return "Désactivé";
      case 9:
        return "Livrée";
      case 10:
        return "Sans Livraison";
      case 11:
        return "Simulation";
      case 12:
        return "Échouée";
      case 13:
        return "Remboursée";
      case 14:
        return "À Régularisé";
      default:
        return "Statut invalide";
    }
  }

  static String getCleanedNumber(String text) {
    RegExp regExp = new RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  static Widget? getCardIcon() {
    Widget? widget;

    widget = new Image.asset(
      'assets/visa.png',
      width: 40.0,
    );

    return widget;
  }

  /// With the card number with Luhn Algorithm
  /// https://en.wikipedia.org/wiki/Luhn_algorithm
  static String? validateCardNum(String? input) {
    if (input == null || input.isEmpty) {
      return "Numéro de carte obligatoire";
    }

    input = getCleanedNumber(input);

    if (input.length < 8) {
      return "Numéro de carte invalide";
    }

    return null;
  }

  static CardType getCardTypeFrmNumber(String input) {
    CardType cardType;
    if (input.startsWith(new RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.Master;
    } else if (input.startsWith(new RegExp(r'[4]'))) {
      cardType = CardType.Visa;
    } else if (input
        .startsWith(new RegExp(r'((506(0|1))|(507(8|9))|(6500))'))) {
      cardType = CardType.Verve;
    } else if (input.startsWith(new RegExp(r'((34)|(37))'))) {
      cardType = CardType.AmericanExpress;
    } else if (input.startsWith(new RegExp(r'((6[45])|(6011))'))) {
      cardType = CardType.Discover;
    } else if (input
        .startsWith(new RegExp(r'((30[0-5])|(3[89])|(36)|(3095))'))) {
      cardType = CardType.DinersClub;
    } else if (input.startsWith(new RegExp(r'(352[89]|35[3-8][0-9])'))) {
      cardType = CardType.Jcb;
    } else if (input.length <= 8) {
      cardType = CardType.Others;
    } else {
      cardType = CardType.Invalid;
    }
    return cardType;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

class LastNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    //buffer.write("**** **** **** ");
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
