import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/mec/price_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/event/components/register_component.dart';

class RegisterScreen extends StatefulWidget {
  final int eventId;

  RegisterScreen({required this.eventId});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isSame = false;
  List<PriceModel> priceList = [];
  Future<List<PriceModel>>? future;

  @override
  void initState() {
    future = getPrices();
    super.initState();
  }

  Future<List<PriceModel>> getPrices({int? eventId}) async {
    appStore.setLoading(true);

    await getPriceList(eventId: widget.eventId).then((value) {
      priceList.addAll(value);

      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return priceList;
  }

  bool isError = false;
  bool isChange = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          title:
              Text("S'inscrire à l'évènement", style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  RegisterComponent(
                    eventId: widget.eventId,
                    future: future!,
                    priceList: priceList,
                  ),
                ],
              ),
            ),
            Observer(
                builder: (_) =>
                    LoadingWidget().center().visible(appStore.isLoading))
          ],
        ),
      ),
    );
  }
}
