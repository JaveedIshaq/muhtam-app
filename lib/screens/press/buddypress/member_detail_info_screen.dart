import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:cirilla/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'models/models.dart';
import 'mixins/mixins.dart';

class BPMemberDetailInfoScreen extends StatelessWidget with AppBarMixin, BPGroupMixin {
  final BPMember? member;

  const BPMemberDetailInfoScreen({super.key, this.member});

  Widget buildRow({required String title, required Widget content, required ThemeData theme, bool enableDivider = true}) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(title, style: theme.textTheme.titleSmall),
                ),
              ),
              const VerticalDivider(width: 30, thickness: 1),
              Expanded(
                flex: 3,
                child:  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [content],
                    )
                ),
              )
            ],
          ),
        ),
        if (enableDivider) const Divider(height: 1, thickness: 1)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    TextStyle textStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    Style style = Style(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      fontFamily: textStyle.fontFamily,
      fontSize: FontSize(textStyle.fontSize),
      fontWeight: textStyle.fontWeight,
      color: textStyle.color,
    );

    return Scaffold(
      appBar: baseStyleAppBar(context, title: translate("buddypress_profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate("buddypress_info"), style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            buildRow(
              title: translate("buddypress_name"),
              content: Text(member?.name ?? "",  style: theme.textTheme.bodyMedium),
              theme: theme,
            ),
            buildRow(
              title: translate("buddypress_username"),
              content: Text("@${member?.userLogin}",  style: theme.textTheme.bodyMedium),
              theme: theme,
            ),
            buildRow(
              title: translate("buddypress_avatar"),
              content: CirillaCacheImage(member?.avatar, width: 150, height: 150),
              theme: theme,
            ),
            buildRow(
              title: translate("buddypress_last_active"),
              content: Text(member?.lastActive ?? translate("buddypress_no_active"),  style: theme.textTheme.bodyMedium),
              theme: theme,
            ),
            if (member?.profile?.isNotEmpty == true)
              ...member!.profile!.map((e) {
                List<BPMemberProfileField> fields = e.fields?.where((element) => element.value?.isNotEmpty == true).toList() ?? [];

                if (fields.isEmpty) {
                  return Container();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name ?? "", style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ...fields.map((field) {
                        return buildRow(
                          title: field.name ?? "",
                          content: CirillaHtml(
                            html: field.value ?? "",
                            style: {
                              "html": style,
                              "body": style,
                              "div": style,
                              "p": style,
                            },
                          ),
                          theme: theme,
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}