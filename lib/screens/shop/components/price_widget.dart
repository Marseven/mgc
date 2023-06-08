import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../main.dart';

class PriceWidget extends StatelessWidget {
  final String? salePrice;
  final String? regularPrice;
  final String? priceHtml;
  final String? price;
  final bool showDiscountPercentage;
  final int? size;
  final int? offSize;

  const PriceWidget({
    Key? key,
    this.salePrice,
    this.regularPrice,
    this.priceHtml,
    this.price,
    this.showDiscountPercentage = false,
    this.size,
    this.offSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (salePrice.validate().isNotEmpty && regularPrice.validate().isNotEmpty) {
      if (salePrice.validate() != regularPrice.validate())
        return RichText(
          text: TextSpan(
            text: '${regularPrice.validate()} ${appStore.wooCurrency}',
            style: secondaryTextStyle(
                decoration: TextDecoration.lineThrough,
                fontFamily: fontFamily,
                size: size ?? 14),
            children: <TextSpan>[
              TextSpan(
                  text: '  ${salePrice.validate()} ${appStore.wooCurrency} ',
                  style: boldTextStyle(
                      color: appStore.isDarkMode ? bodyDark : bodyWhite,
                      decoration: TextDecoration.none,
                      size: size ?? 14)),
              if (showDiscountPercentage)
                TextSpan(
                    text:
                        '   ${(((regularPrice.toInt() - salePrice.toInt()) / regularPrice.toInt()) * 100).round()}% ${language.off}',
                    style: boldTextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.none,
                        fontFamily: fontFamily,
                        size: offSize ?? 12)),
            ],
          ),
        );
      else
        return Text('${price.validate()} ${appStore.wooCurrency}',
            style: boldTextStyle(
                decoration: TextDecoration.none,
                color: appStore.isDarkMode ? bodyDark : bodyWhite,
                size: size ?? 14));
    } else if (priceHtml != null
        ? parseHtmlString(priceHtml).contains('–')
        : false) {
      return Text(parseHtmlString(priceHtml),
          style: boldTextStyle(
              color: appStore.isDarkMode ? bodyDark : bodyWhite,
              size: size ?? 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis);
    } else {
      return Text('${price.validate()} ${appStore.wooCurrency}',
          style: boldTextStyle(
              decoration: TextDecoration.none,
              color: appStore.isDarkMode ? bodyDark : bodyWhite,
              size: size ?? 14));
    }
  }
}
