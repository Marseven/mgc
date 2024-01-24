import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/cart_badge_model.dart';
import 'package:socialv/models/mec/event_detail_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/event/screens/register_screen.dart';
import 'package:socialv/screens/shop/screens/cart_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/app_constants.dart';

class EventDetailScreen extends StatefulWidget {
  final int id;

  const EventDetailScreen({required this.id});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

EventDetailModel event = EventDetailModel();
EventDetailModel mainEvent = EventDetailModel();

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isError = false;
  bool isFetched = false;
  bool isLoading = false;

  PageController pageController = PageController();

  int count = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });

    appStore.setLoading(true);

    await getEventDetail(eventId: widget.id.validate()).then((value) {
      isFetched = true;
      setState(() {});
      event = value;
      appStore.setLoading(false);
    }).catchError((e) {
      log('Error: ${e.toString()}');
      isError = true;
      setState(() {});
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    pageController.dispose();
    super.dispose();
  }

  late CartBadge cartBadge;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          if (isFetched) {
            DateTime dateS = DateTime.parse(event.start.toString());
            String start = DateFormat('dd-MM-yyyy').format(dateS);
            DateTime dateE = DateTime.parse(event.end.toString());
            String end = DateFormat('dd-MM-yyyy').format(dateE);
            return Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder:
                      ((BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        expandedHeight: context.height() * 0.3,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: SizedBox(
                            height: context.height() * 0.3,
                            width: context.width(),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                cachedImage(
                                  event.featuredImage!.full.validate(),
                                  height: context.height() * 0.3,
                                  width: context.width(),
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                          collapseMode: CollapseMode.parallax,
                        ),
                        backgroundColor: context.scaffoldBackgroundColor,
                        leading: BackButton(
                          color: context.iconColor,
                          onPressed: () async {
                            finish(context);
                          },
                        ),
                        title: Text(event.title.validate(),
                                style: boldTextStyle(
                                    size: 25,
                                    weight: FontWeight.w900,
                                    color: appColorPrimary))
                            .visible(innerBoxIsScrolled),
                        actions: [
                          IconButton(
                            onPressed: () {
                              CartScreen().launch(context);
                            },
                            icon: Image.asset(ic_cart,
                                width: 24,
                                height: 24,
                                color: context.primaryColor,
                                fit: BoxFit.cover),
                          ).visible(innerBoxIsScrolled),
                        ],
                      ),
                    ];
                  }),
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title.validate(),
                                style: boldTextStyle(
                                    size: 25,
                                    weight: FontWeight.w900,
                                    color: appColorPrimary))
                            .paddingSymmetric(horizontal: 16, vertical: 8),
                        16.height,
                        if (event.content.validate().isNotEmpty)
                          Text(parseHtmlString(event.content),
                                  style: secondaryTextStyle())
                              .paddingSymmetric(horizontal: 16),
                        Divider(),
                        16.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${language.date} de début : ',
                                style: boldTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite,
                                    size: 14)),
                            Text(start,
                                style: primaryTextStyle(
                                    color: context.primaryColor, size: 15)),
                          ],
                        ).paddingSymmetric(horizontal: 16),
                        16.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${language.date} de fin : ',
                                style: boldTextStyle(
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite,
                                    size: 14)),
                            Text(end,
                                style: primaryTextStyle(
                                    color: context.primaryColor, size: 15)),
                          ],
                        ).paddingSymmetric(horizontal: 16),
                        16.height,
                        if (event.categories != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${language.category}: ',
                                  style: boldTextStyle(
                                      color: appStore.isDarkMode
                                          ? bodyDark
                                          : bodyWhite,
                                      size: 14)),
                              Text(event.categories!.name.validate(),
                                  style: primaryTextStyle(
                                      color: context.primaryColor, size: 15)),
                            ],
                          ).paddingSymmetric(horizontal: 16),
                        16.height,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              Share.share(
                                  'Découvrez nos prochains tournois et évènement sur la plateforme officielle de Manga Golf Club (https://mangagolfclub.com/accueil/#Event)');
                            },
                            icon: Icon(
                              // <-- Icon
                              Icons.share,
                              size: 24.0,
                            ),
                            backgroundColor: context.primaryColor,
                            label: Text(
                              'Partager',
                              style: primaryTextStyle(
                                  color: Colors.white, size: 15),
                            ), // <-- Text
                          ),
                        ),
                        16.height,
                      ],
                    ),
                  ),
                ),
                LoadingWidget().center().visible(appStore.isLoading),
              ],
            );
          } else if (isError) {
            return NoDataWidget(
              imageWidget: NoDataLottieWidget(),
              title:
                  isError ? language.somethingWentWrong : language.noDataFound,
            ).center();
          } else {
            return LoadingWidget().center();
          }
        },
      ),
      bottomNavigationBar: Container(
        color: context.cardColor,
        padding: EdgeInsets.only(left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              shapeBorder: RoundedRectangleBorder(borderRadius: radius(0)),
              child: TextIcon(
                text: 'S\'inscrire',
                textStyle: boldTextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.symmetric(vertical: 8),
              onTap: () async {
                RegisterScreen(
                  eventId: event.id.toInt(),
                ).launch(context);
              },
              elevation: 0,
              color: context.primaryColor,
            ).expand(),
          ],
        ),
      ),
    );
  }
}
