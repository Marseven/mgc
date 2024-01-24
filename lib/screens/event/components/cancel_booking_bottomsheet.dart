import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';

class CancelBookingBottomSheet extends StatefulWidget {
  final int booking;
  final Function(String)? callback;

  const CancelBookingBottomSheet({required this.booking, this.callback});

  @override
  State<CancelBookingBottomSheet> createState() =>
      _CancelBookingBottomSheetState();
}

class _CancelBookingBottomSheetState extends State<CancelBookingBottomSheet> {
  List<String> cancelBookingList = [
    language.cancelBookingMessageOne,
    language.cancelBookingMessageTwo,
    language.cancelBookingMessageThree,
    language.cancelBookingMessageFour,
    language.cancelBookingMessageFive,
    language.cancelBookingMessageSix
  ];

  String cancelBookingReason = "";
  int cancelBookingIndex = 0;

  @override
  void initState() {
    super.initState();
    cancelBookingReason = cancelBookingList.first;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), color: Colors.white),
          ),
          8.height,
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(language.reasonForCancellation, style: boldTextStyle())
                        .expand(),
                    Icon(Icons.close).onTap(() {
                      finish(context);
                    })
                  ],
                ),
                24.height,
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cancelBookingList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        cancelBookingReason = cancelBookingList[index];
                        print(cancelBookingReason);
                        cancelBookingIndex = index;
                        setState(() {});
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius: radius(4),
                              border: Border.all(color: context.primaryColor),
                              backgroundColor: cancelBookingIndex == index
                                  ? context.primaryColor
                                  : context.cardColor,
                            ),
                            width: 16,
                            height: 16,
                            child: Icon(Icons.done,
                                size: 12, color: context.cardColor),
                            margin: EdgeInsets.only(top: 4),
                          ),
                          4.width,
                          Text(cancelBookingList[index],
                                  style: primaryTextStyle())
                              .paddingLeft(8)
                              .expand(),
                        ],
                      ).paddingSymmetric(vertical: 8),
                    );
                  },
                ),
                24.height,
                AppButton(
                  width: context.width(),
                  textStyle: primaryTextStyle(color: white),
                  text: language.cancelBooking,
                  color: context.primaryColor,
                  onTap: () {
                    finish(context);

                    widget.callback?.call(cancelBookingReason);
                  },
                ),
                20.height,
              ],
            ),
          ).expand(),
        ],
      ),
    );
  }
}
