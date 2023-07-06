import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../main.dart';
import '../../../../models/messages/Messages.dart';
import '../../../../network/messages_repository.dart';
import '../../../../utils/cached_network_image.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common.dart';
import '../../../../utils/images.dart';

enum ChatScreenNavigationBarComponentCallbacks { SetState, PickFile, GetThread }

// ignore: must_be_immutable
class ChatScreenBottomNavigationBarComponent extends StatefulWidget {
  Messages? replyMessage;
  bool? isEditMessage;
  final Function(ChatScreenNavigationBarComponentCallbacks)? callback;
  TextEditingController message;
  final int threadId;

  ChatScreenBottomNavigationBarComponent({Key? key, this.replyMessage, this.isEditMessage, this.callback, required this.message, required this.threadId}) : super(key: key);

  @override
  State<ChatScreenBottomNavigationBarComponent> createState() => _ChatScreenBottomNavigationBarComponentState();
}

class _ChatScreenBottomNavigationBarComponentState extends State<ChatScreenBottomNavigationBarComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: context.cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyMessage != null)
            Container(
              decoration: BoxDecoration(color: context.cardColor, border: Border.symmetric(horizontal: BorderSide(color: context.dividerColor))),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      widget.replyMessage = null;
                      widget.callback?.call(ChatScreenNavigationBarComponentCallbacks.SetState);
                    },
                    icon: Icon(Icons.cancel_outlined, color: context.iconColor),
                  ),
                  SizedBox(
                    width: context.width() * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.isEditMessage.validate() ? 'Edit Message' : 'Reply to Message', style: boldTextStyle(size: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
                        Text(widget.replyMessage!.message.validate(), style: secondaryTextStyle(size: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          8.width,
          Row(
            children: [
              IconButton(
                icon: cachedImage(ic_hyperlink, height: 24, width: 24, fit: BoxFit.cover, color: context.iconColor),
                onPressed: () {
                  widget.callback?.call(ChatScreenNavigationBarComponentCallbacks.PickFile);
                },
              ),
              TextField(
                controller: widget.message,
                decoration: InputDecoration(
                  hintText: 'Write a message',
                  hintStyle: secondaryTextStyle(size: 16),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ).expand(),
              IconButton(
                onPressed: () {
                  ifNotTester(() {
                    if (widget.message.text.isNotEmpty) {
                      if (widget.isEditMessage.validate() && widget.replyMessage != null) {
                        editMessage(
                          messageId: widget.replyMessage!.messageId.validate(),
                          message: widget.message.text,
                          threadId: widget.threadId,
                        ).then((value) {
                          widget.replyMessage = null;
                          widget.callback?.call(ChatScreenNavigationBarComponentCallbacks.GetThread);
                        }).catchError(onError);
                      } else {
                        sendMessage(
                          threadId: widget.threadId,
                          message: widget.message.text,
                          messageId: widget.replyMessage != null ? widget.replyMessage!.messageId.validate() : null,
                          //isFile:
                        ).then((value) {
                          widget.replyMessage = null;

                          widget.callback?.call(ChatScreenNavigationBarComponentCallbacks.GetThread);
                        }).catchError(onError);
                      }

                      widget.message.clear();
                      hideKeyboard(context);
                    }
                  });
                },
                icon: cachedImage(ic_send, color: appStore.isDarkMode ? bodyDark : bodyWhite, width: 24, height: 24, fit: BoxFit.cover),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
