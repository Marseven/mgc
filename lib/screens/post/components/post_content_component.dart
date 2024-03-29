import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blog/screens/blog_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import '../../../utils/html_widget.dart';

class PostContentComponent extends StatefulWidget {
  final String? postContent;
  final String? postType;
  final bool? hasMentions;
  final int? blogId;

  @override
  State<PostContentComponent> createState() => _PostContentComponentState();

  const PostContentComponent({this.postContent, this.postType, this.hasMentions, this.blogId});
}

class _PostContentComponentState extends State<PostContentComponent> {
  Future<void> onViewBlogPost() async {
    if (widget.blogId != null) {
      appStore.setLoading(true);
      await wpPostById(postId: widget.blogId.validate()).then((value) {
        appStore.setLoading(false);
        if (value.is_restricted.validate()) {
          MembershipPlansScreen().launch(context);
        } else {
          BlogDetailScreen(blogId: widget.blogId.validate(), data: value).launch(context);
        }
      }).catchError((e) {
        toast(language.canNotViewPost);
        appStore.setLoading(false);
      });
    } else {
      toast(language.canNotViewPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (widget.postContent.validate().isNotEmpty) {
          if (widget.postType == PostActivityType.newBlogPost) {
            return InkWell(
              onTap: () async {
                onViewBlogPost();
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: HtmlWidget(postContent: widget.postContent.validateAndFilter(), blogId: widget.blogId),
            );
          } else if (widget.hasMentions.validate() ||
              widget.postContent.validate().contains('href') ||
              widget.postContent.validate().contains('</br>') ||
              widget.postContent.validate().contains('<iframe')) {
            return HtmlWidget(postContent: widget.postContent.validateAndFilter());
          } else {
            return ReadMoreText(
              parseHtmlString(widget.postContent.validateAndFilter()),
              style: primaryTextStyle(),
              trimLines: 3,
              trimMode: TrimMode.Line,
            ).paddingSymmetric(horizontal: 8, vertical: 8);
          }
        } else
          return Offstage();
      },
    );
  }
}
