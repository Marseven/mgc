import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/models/mec/booking_model.dart';
import 'package:socialv/models/mec/event_detail_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/event/screens/booking_detail_screen.dart';
import 'package:socialv/screens/shop/components/ebilling_component.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<BookingModel> bookingList = [];
  late Future<List<BookingModel>> future;
  late EventDetailModel event;

  List<FilterModel> filterOptions = getOrderStatus();
  FilterModel? dropDownValue;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getBookings();

    super.initState();
  }

  Future<List<BookingModel>> getBookings({String? status}) async {
    appStore.setLoading(true);

    await getBookingList(status: status == null ? OrderStatus.any : status)
        .then((value) {
      if (mPage == 1) bookingList.clear();

      mIsLastPage = value.length != 20;
      bookingList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    await fetchEventDetailsForBookings(bookingList);

    return bookingList;
  }

  Future<void> fetchEventDetailsForBookings(
      List<BookingModel> bookingList) async {
    appStore.setLoading(true);
    for (var booking in bookingList) {
      try {
        EventDetailModel event =
            await getEventDetail(eventId: booking.eventId.toInt());
        setState(() {
          booking.event = event; // Ajoutez l'événement à l'objet Booking
        });
      } catch (e) {
        isError = true;
        setState(() {});
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      }
    }
    appStore.setLoading(false);
  }

  Future<void> onRefresh() async {
    isError = false;
    mPage = 1;
    future = getBookings();
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
          titleSpacing: 0,
          title: Text('Mes Réservations', style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            FutureBuilder<List<BookingModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: isError
                        ? language.somethingWentWrong
                        : language.noDataFound,
                    onRetry: () {
                      onRefresh();
                    },
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
                      onRetry: () {
                        onRefresh();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center();
                  } else {
                    return AnimatedListView(
                      shrinkWrap: true,
                      slideConfiguration: SlideConfiguration(
                        delay: 80.milliseconds,
                        verticalOffset: 300,
                      ),
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: bookingList.length,
                      itemBuilder: (context, index) {
                        print(Helpers.statusOrder(bookingList[index].status));
                        DateTime dateB = DateTime.parse(
                            bookingList[index].bookDate.toString());
                        String bookdate =
                            DateFormat('dd MMMM yyyy', 'fr_FR').format(dateB);
                        DateTime dateS = DateTime.parse(
                            bookingList[index].event!.start.toString());
                        String start = DateFormat('dd-MM-yyyy').format(dateS);
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            BookingDetailScreen(
                                    booking: bookingList[index],
                                    event: bookingList[index].event!)
                                .launch(context)
                                .then((value) {
                              if (value ?? false) {
                                mPage = 1;
                                getBookings();
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: radius(defaultAppButtonRadius)),
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('N° de la Réservation: ',
                                            style: boldTextStyle(size: 14)),
                                        Text(
                                            bookingList[index]
                                                .id
                                                .validate()
                                                .toString(),
                                            style: secondaryTextStyle()),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('${language.date}: ',
                                            style: boldTextStyle(size: 14)),
                                        Text(bookdate,
                                            style: secondaryTextStyle()),
                                      ],
                                    ),
                                    10.height,
                                    Row(
                                      children: [
                                        cachedImage(
                                          bookingList[index]
                                              .event!
                                              .featuredImage!
                                              .full
                                              .validate(),
                                          height: 30,
                                          width: 30,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(
                                            commonRadius),
                                        10.width,
                                        Text('${bookingList[index].event!.title.validate()}',
                                                style: secondaryTextStyle())
                                            .expand(),
                                      ],
                                    ).paddingSymmetric(vertical: 4),
                                    Divider(height: 28),
                                    Row(
                                      children: [
                                        Text('Date de l\'évènement : ',
                                            style: boldTextStyle()),
                                        Text(start, style: boldTextStyle()),
                                      ],
                                    ),
                                  ],
                                ),
                                Align(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: context.primaryColor,
                                        borderRadius: radius(4)),
                                    child: Text(
                                        Helpers.statusOrder(
                                                bookingList[index].status)
                                            .capitalizeFirstLetter(),
                                        style: secondaryTextStyle(
                                            color: Colors.white)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                  ),
                                  alignment: Alignment.topRight,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          future = getBookingList();
                        }
                      },
                    ).paddingTop(80);
                  }
                }
                return Offstage();
              },
            ),
            Align(
              child: Container(
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: radius(commonRadius)),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<FilterModel>(
                      borderRadius: BorderRadius.circular(commonRadius),
                      icon: Icon(Icons.arrow_drop_down,
                          color: appStore.isDarkMode ? bodyDark : bodyWhite),
                      elevation: 8,
                      style: primaryTextStyle(),
                      onChanged: (FilterModel? newValue) {
                        dropDownValue = newValue!;

                        mPage = 1;
                        future = getBookings(status: newValue.value);

                        setState(() {});
                      },
                      hint: Text(language.orderStatus,
                          style: primaryTextStyle(
                              color:
                                  appStore.isDarkMode ? bodyDark : bodyWhite)),
                      items: filterOptions.map<DropdownMenuItem<FilterModel>>(
                          (FilterModel value) {
                        return DropdownMenuItem<FilterModel>(
                          value: value,
                          child: Text(value.title.validate(),
                              style: primaryTextStyle()),
                        );
                      }).toList(),
                      value: dropDownValue,
                    ),
                  ),
                ),
                margin: EdgeInsets.all(16),
              ),
              alignment: Alignment.topRight,
            ),
            Observer(
              builder: (_) {
                if (appStore.isLoading) {
                  return Positioned(
                    bottom: mPage != 1 ? 10 : null,
                    child: LoadingWidget(
                        isBlurBackground: mPage == 1 ? true : false),
                  );
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
