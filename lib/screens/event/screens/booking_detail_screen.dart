import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/mec/booking_model.dart';
import 'package:socialv/models/mec/event_detail_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/event/components/cancel_booking_bottomsheet.dart';
import 'package:socialv/screens/event/screens/event_detail_screen.dart';
import 'package:socialv/screens/shop/components/ebilling_component.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class BookingDetailScreen extends StatefulWidget {
  final EventDetailModel event;
  final BookingModel booking;

  const BookingDetailScreen({
    required this.event,
    required this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool isChange = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> onDeleteBooking() async {
    showConfirmDialogCustom(
      context,
      onAccept: (c) {
        ifNotTester(() {
          appStore.setLoading(true);
          deleteBooking(booking: widget.booking.id.validate().toInt())
              .then((value) {
            toast(language.orderDeletedSuccessfully);
            appStore.setLoading(false);

            finish(context, true);
          }).catchError((e) {
            appStore.setLoading(false);

            toast(e.toString(), print: true);
          });
        });
      },
      dialogType: DialogType.CONFIRMATION,
      title: language.deleteBookingConfirmation,
      positiveText: language.yes,
      negativeText: language.no,
    );
  }

  Future<void> onCancelBooking() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CancelBookingBottomSheet(
          booking: widget.booking.id.validate().toInt(),
          callback: (text) {
            showConfirmDialogCustom(
              context,
              onAccept: (c) {
                ifNotTester(() {
                  appStore.setLoading(true);
                  cancelBooking(booking: widget.booking.id.validate().toInt())
                      .then((value) {
                    toast(language.orderCancelledSuccessfully);

                    appStore.setLoading(false);
                    isChange = true;
                    setState(() {});
                  }).catchError((e) {
                    appStore.setLoading(false);
                    toast(e.toString(), print: true);
                  });
                });
              },
              dialogType: DialogType.CONFIRMATION,
              title: language.cancelOrderConfirmation,
              positiveText: language.yes,
              negativeText: language.no,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateS = DateTime.parse(widget.event.start.toString());
    String start = DateFormat('dd-MM-yyyy').format(dateS);
    DateTime dateE = DateTime.parse(widget.event.end.toString());
    String end = DateFormat('dd-MM-yyyy').format(dateE);
    DateTime dateB = DateTime.parse(widget.booking.bookDate.toString());
    String bookdate = DateFormat('dd MMMM yyyy', 'fr_FR').format(dateB);
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
          title:
              Text('Détails de la Réservation', style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
          actions: [
            Theme(
              data: Theme.of(context).copyWith(useMaterial3: false),
              child: PopupMenuButton(
                enabled: !appStore.isLoading,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(commonRadius)),
                onSelected: (val) async {
                  if (val == 1) {
                    onDeleteBooking();
                  } else {
                    onCancelBooking();
                  }
                },
                icon: Icon(Icons.more_horiz),
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Image.asset(ic_delete,
                            width: 20,
                            height: 20,
                            color: Colors.red,
                            fit: BoxFit.cover),
                        8.width,
                        Text('Supprimer la réservation',
                            style: primaryTextStyle()),
                      ],
                    ),
                  ),
                  if (widget.booking.status != OrderStatus.cancelled &&
                      widget.booking.status != OrderStatus.refunded &&
                      widget.booking.status != OrderStatus.completed &&
                      widget.booking.status != OrderStatus.trash &&
                      widget.booking.status != OrderStatus.failed)
                    PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Image.asset(ic_close_square,
                              width: 20,
                              height: 20,
                              color: Colors.red,
                              fit: BoxFit.cover),
                          8.width,
                          Text('Annuler la réservation',
                              style: primaryTextStyle()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Statut de la réservation', style: boldTextStyle()),
                      Text(
                        Helpers.statusOrder(widget.booking.status)
                            .capitalizeFirstLetter(),
                        style: boldTextStyle(
                            color: context.primaryColor, size: 18),
                      ),
                    ],
                  ),
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(defaultAppButtonRadius)),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Numéro de la Réservation:',
                                style: primaryTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite)),
                            8.width,
                            Text(widget.booking.id.validate().toString(),
                                    style: primaryTextStyle())
                                .expand(),
                          ],
                        ),
                        8.height,
                        Row(
                          children: [
                            Text('${language.date}:',
                                style: primaryTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite)),
                            8.width,
                            Text(bookdate.toString(), style: primaryTextStyle())
                                .expand(),
                          ],
                        ),
                        8.height,
                        Row(
                          children: [
                            Text('${language.email}:',
                                style: primaryTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite)),
                            8.width,
                            Text(appStore.loginEmail, style: primaryTextStyle())
                                .expand(),
                          ],
                        ),
                        8.height,
                        // Row(
                        //   children: [
                        //     Text('${language.paymentMethod}:',
                        //         style: primaryTextStyle(
                        //             color: appStore.isDarkMode
                        //                 ? bodyDark
                        //                 : bodyWhite)),
                        //     8.width,
                        //     Text(widget.booking.paymentMethodTitle.validate(),
                        //             style: primaryTextStyle(),
                        //             maxLines: 1,
                        //             overflow: TextOverflow.ellipsis)
                        //         .expand(),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  16.height,
                  Text('Évènement :', style: boldTextStyle()),
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(defaultAppButtonRadius)),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            cachedImage(
                              widget.event.featuredImage!.full.validate(),
                              height: 30,
                              width: 30,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(commonRadius),
                            8.width,
                            Text(
                              '${widget.event.title.validate()}',
                              style: primaryTextStyle(
                                  color: appStore.isDarkMode
                                      ? bodyDark
                                      : bodyWhite),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).expand(),
                          ],
                        ).paddingSymmetric(vertical: 6).onTap(() {
                          EventDetailScreen(
                                  id: widget.event.id.validate().toInt())
                              .launch(context);
                        }),
                        10.height,
                        Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Début de l\'évènement:',
                                style: boldTextStyle()),
                            Text('Fin de l\'évènement:',
                                style: boldTextStyle()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(start, style: boldTextStyle()),
                            Text(end, style: boldTextStyle()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Text('Information de la Réservation :',
                      style: boldTextStyle()),
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(defaultAppButtonRadius)),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${language.name}:',
                                style: primaryTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite)),
                            8.width,
                            Text(
                                widget.booking.firstname.validate().toString() +
                                    ' ' +
                                    widget.booking.lastname
                                        .validate()
                                        .toString(),
                                style: primaryTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Genre :',
                                style: primaryTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite)),
                            8.width,
                            Text(
                                widget.booking.sexe.validate().toString() == 'H'
                                    ? 'Homme'
                                    : 'Femme',
                                style: primaryTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Index du Joueur :',
                                style: primaryTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite)),
                            8.width,
                            Text('${widget.booking.indexPlayer.validate().toString()}',
                                    style: primaryTextStyle())
                                .expand(),
                          ],
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${language.phone}:',
                                style: primaryTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite)),
                            8.width,
                            Text(
                                widget.booking.phone
                                    .validate()
                                    .toString()
                                    .capitalizeFirstLetter(),
                                style: primaryTextStyle()),
                          ],
                        ),
                        8.height,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Observer(
                builder: (ctx) => LoadingWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
