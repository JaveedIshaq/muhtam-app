import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:flutter/material.dart';

import 'widgets/widgets.dart';

class BPActivityCreateScreen extends StatelessWidget with AppBarMixin, SnackMixin {
  static const routeName = '/buddypress-activity-create';

  final String? mentionName;
  final Function? callback;

  const BPActivityCreateScreen({
    super.key,
    this.mentionName,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;

    return Scaffold(
      appBar: baseStyleAppBar(context, title: translate("buddypress_create_activity"), enableIconClose: true),
      body: GestureDetector(
        onTap: () {
          if (FocusScope.of(context).hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: ActivityFormWidget(
          mentionName: mentionName,
          callback: () {
            if (callback != null) {
              callback!.call();
            } else {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }

            showSuccess(context, translate("buddypress_create_activity_success"));
          },
        ),
      ),
    );
  }
}