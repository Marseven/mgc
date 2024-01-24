import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/mec/event_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/dashboard_screen.dart';
import 'package:socialv/screens/event/components/events_card_component.dart';
import 'package:socialv/screens/event/screens/event_detail_screen.dart';
import 'package:html/parser.dart';

import '../../../utils/app_constants.dart';

class EventsFragment extends StatefulWidget {
  final ScrollController controller;

  const EventsFragment({super.key, required this.controller});

  @override
  State<EventsFragment> createState() => _EventsFragment();
}

class _EventsFragment extends State<EventsFragment> {
  List<EventModel> eventsList = [];
  late Future<List<EventModel>> future;

  TextEditingController searchController = TextEditingController();

  int mPage = 1;
  bool mIsLastPage = false;

  bool hasShowClearTextIcon = false;
  bool isError = false;

  @override
  void initState() {
    future = getEvents();
    super.initState();

    widget.controller.addListener(() {
      /// pagination
      if (selectedIndex == 2) {
        if (widget.controller.position.pixels ==
            widget.controller.position.maxScrollExtent) {
          if (!mIsLastPage) {
            mPage++;
            setState(() {});

            future = getEvents();
          }
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        hasShowClearTextIcon = false;
        setState(() {});
      }
    });

    LiveStream().on(RefreshForumsFragment, (p0) {
      appStore.setLoading(true);
      eventsList.clear();
      mPage = 1;
      setState(() {});
      future = getEvents();
    });
  }

  void showClearTextIcon() {
    if (!hasShowClearTextIcon) {
      hasShowClearTextIcon = true;
      setState(() {});
    } else {
      return;
    }
  }

  Future<List<EventModel>> getEvents() async {
    appStore.setLoading(true);
    await getEventList(page: mPage, keyword: searchController.text)
        .then((value) {
      if (mPage == 1) eventsList.clear();
      mIsLastPage = value.length != PER_PAGE;
      eventsList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return eventsList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    searchController.dispose();
    LiveStream().dispose(RefreshForumsFragment);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.height,
        Container(
          width: context.width() - 32,
          margin: EdgeInsets.only(left: 16, right: 8),
          decoration: BoxDecoration(
              color: context.cardColor, borderRadius: radius(commonRadius)),
          child: AppTextField(
            controller: searchController,
            textFieldType: TextFieldType.USERNAME,
            onFieldSubmitted: (text) {
              mPage = 1;
              future = getEvents();
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: language.searchHere,
              hintStyle: secondaryTextStyle(),
              prefixIcon: Image.asset(
                ic_search,
                height: 16,
                width: 16,
                fit: BoxFit.cover,
                color: appStore.isDarkMode ? bodyDark : bodyWhite,
              ).paddingAll(16),
              suffixIcon: hasShowClearTextIcon
                  ? IconButton(
                      icon: Icon(Icons.cancel,
                          color: appStore.isDarkMode ? bodyDark : bodyWhite,
                          size: 18),
                      onPressed: () {
                        hideKeyboard(context);
                        hasShowClearTextIcon = false;
                        searchController.clear();

                        mPage = 1;
                        getEvents();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            FutureBuilder<List<EventModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return SizedBox(
                    height: context.height() * 0.5,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: isError
                          ? language.somethingWentWrong
                          : language.noDataFound,
                      onRetry: () {
                        LiveStream().emit(RefreshForumsFragment);
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center(),
                  );
                }

                if (snap.hasData) {
                  if (snap.data.validate().isEmpty) {
                    return SizedBox(
                      height: context.height() * 0.5,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: isError
                            ? language.somethingWentWrong
                            : language.noDataFound,
                        onRetry: () {
                          LiveStream().emit(RefreshForumsFragment);
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    );
                  } else {
                    return AnimatedListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      slideConfiguration: SlideConfiguration(
                          delay: 80.milliseconds, verticalOffset: 300),
                      padding: EdgeInsets.only(
                          left: 16, right: 16, bottom: 50, top: 16),
                      itemCount: eventsList.length,
                      itemBuilder: (context, index) {
                        EventModel data = eventsList[index];
                        print(data);
                        // Date à formater
                        DateTime dateS = DateTime.parse(data.start.toString());
                        String start = DateFormat('dd-MM-yyyy').format(dateS);
                        DateTime dateE = DateTime.parse(data.end.toString());
                        String end = DateFormat('dd-MM-yyyy').format(dateE);
                        var description = parse(data.content.rendered);
                        String parsedstring = description.documentElement!.text;
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            EventDetailScreen(
                              id: data.id.validate(),
                            ).launch(context).then((value) {
                              if (value ?? false) {
                                mPage = 1;
                                future = getEvents();
                              }
                            });
                          },
                          child: EventsCardComponent(
                            title: data.title.rendered,
                            description: parsedstring.length > 100
                                ? parsedstring.substring(0, 100) + '...'
                                : parsedstring,
                            start: start,
                            end: end,
                            picture: data.featureImage,
                          ),
                        );
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          future = getEvents();
                        }
                      },
                    );
                  }
                }
                return Offstage();
              },
            ),
            Observer(
              builder: (_) {
                if (appStore.isLoading) {
                  if (mPage != 1) {
                    return Positioned(
                      bottom: 10,
                      child: LoadingWidget(isBlurBackground: false),
                    );
                  } else {
                    return LoadingWidget(isBlurBackground: false)
                        .paddingTop(context.height() * 0.3);
                  }
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
