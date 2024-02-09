import 'package:cirilla/constants/color_block.dart';
import 'package:cirilla/models/models.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cirilla/constants/styles.dart';

import '../profile/button_signin.dart';
import '../profile/user_content.dart';
import '../profile/block_item_list.dart';
import '../widgets/icon_notification.dart';

const colorAppbar = ColorBlock.white;

class LayoutStyle2 extends StatelessWidget {
  final bool isLogin;
  final Widget? footer;
  final List blocks;
  final List Function(List) getItems;
  final ShowMessageType? showMessage;
  final EdgeInsetsGeometry? padding;
  final User? user;

  const LayoutStyle2({
    super.key,
    this.isLogin = false,
    this.blocks = const [],
    required this.getItems,
    this.user,
    this.footer,
    this.showMessage,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (isLogin)
            buildAppbar(
              content: Padding(
                padding: const EdgeInsets.only(bottom: itemPaddingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: UserContent(
                        user: user,
                        type: UserContentType.container,
                        padding: const EdgeInsets.only(
                          left: layoutPadding,
                          right: layoutPadding,
                        ),
                        backgroundColor: Colors.transparent,
                        color: colorAppbar,
                      ),
                    ),
                    const IconNotification(color: colorAppbar),
                  ],
                ),
              ),
              toolbarHeight: 110,
              theme: theme,
            )
          else
            buildAppbar(
              content: Padding(
                padding: const EdgeInsets.only(bottom: itemPaddingMedium),
                child: Text(
                  translate('profile_txt'),
                  style: theme.appBarTheme.titleTextStyle?.copyWith(color: colorAppbar),
                ),
              ),
              theme: theme,
              toolbarHeight: 80,
            ),
          SliverPadding(
            padding: padding ?? EdgeInsets.zero,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isLogin) ...[
                    ButtonSignin(
                      pad: itemPaddingMedium,
                      showMessage: showMessage,
                    ),
                    const SizedBox(height: 40),
                    // BlockItemList(blocks: logoutBlock),
                  ],
                  BlockItemList(blocks: blocks, getItems: getItems),
                  if (footer != null) ...[
                    const SizedBox(height: itemPaddingSmall),
                    footer!,
                  ],
                  const SizedBox(height: itemPaddingLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar buildAppbar({
    required Widget content,
    required ThemeData theme,
    required double toolbarHeight,
  }) {
    return SliverAppBar(
      toolbarHeight: toolbarHeight,
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          content,
          PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: theme.primaryColor,
    );
  }
}
