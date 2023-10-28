import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';

import '../../../utils/app_constants.dart';

class EventsCardComponent extends StatelessWidget {
  final String? title;
  final String? description;

  const EventsCardComponent({
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4), color: context.cardColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.validate(), style: boldTextStyle(size: 18)),
          8.height,
          Text(description.validate(), style: secondaryTextStyle()),
          Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  Text(language.date,
                      style: boldTextStyle(
                          color: appStore.isDarkMode ? bodyDark : bodyWhite)),
                  8.height,
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
