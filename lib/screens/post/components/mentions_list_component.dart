import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/members/member_response.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/constants.dart';
import 'package:html_unescape/html_unescape.dart';

class MentionsListComponent extends StatefulWidget {
  final List<MemberResponse> mentionsMemberList;
  final Function(String)? callback;

  const MentionsListComponent(
      {required this.mentionsMemberList, this.callback});

  @override
  State<MentionsListComponent> createState() => _MentionsListComponentState();
}

class _MentionsListComponentState extends State<MentionsListComponent> {
  @override
  void initState() {
    super.initState();
  }

  var unescape = HtmlUnescape();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: context.scaffoldBackgroundColor,
          borderRadius: radius(commonRadius)),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.mentionsMemberList.length,
        itemBuilder: (ctx, index) {
          MemberResponse member = widget.mentionsMemberList[index];
          return InkWell(
            onTap: () {
              widget.callback
                  ?.call(unescape.convert(member.mentionName.validate()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('@' + unescape.convert(member.mentionName.validate()),
                        style: boldTextStyle(
                            size: 14, color: context.primaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)
                    .expand(),
                TextIcon(
                  text: unescape.convert(member.name.validate()),
                  textStyle: secondaryTextStyle(),
                  suffix: cachedImage(member.avatarUrls!.full.validate(),
                          height: 20, width: 20, fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(4),
                  maxLine: 1,
                  expandedText: true,
                ).expand(),
              ],
            ).paddingSymmetric(vertical: 2),
          );
        },
      ),
    );
  }
}
