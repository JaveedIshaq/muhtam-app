import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/screens/press/constants.dart';
import 'package:cirilla/store/store.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ui.dart';

import '../../better_messages/better_messages.dart';
import '../buddypress.dart';
import '../mixins/mixins.dart';
import '../widgets/widgets.dart';

class MemberAppbarStyle1Widget extends StatefulWidget {
  final BPMember? member;
  final String? banner;
  final Function(int? id, String slug)? callback;

  const MemberAppbarStyle1Widget({
    Key? key,
    required this.member,
    this.banner,
    this.callback,
  }) : super(key: key);

  @override
  State<MemberAppbarStyle1Widget> createState() => _MemberAppbarStyle1WidgetState();
}

class _MemberAppbarStyle1WidgetState extends State<MemberAppbarStyle1Widget>
    with AppBarMixin, BPMemberMixin, LoadingMixin, TransitionMixin {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    AuthStore authStore = Provider.of<AuthStore>(context);
    SettingStore settingStore = Provider.of<SettingStore>(context);

    double width = MediaQuery.of(context).size.width;
    double height = width * 375 / 200 < 200 ? width * 375 / 200 : 200;

    double heightPlus = authStore.isLogin && authStore.user?.id != widget.member?.id?.toString() ? 190 : 100;

    double heightView = height + heightPlus;

    return SliverPersistentHeader(
      pinned: false,
      floating: false,
      delegate: StickyTabBarDelegate(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: heightPlus),
              child: buildBanner(
                banner: widget.banner ??
                    "https://www.simplilearn.com/ice9/free_resources_article_thumb/what_is_image_Processing.jpg",
                shimmerWidth: double.infinity,
                shimmerHeight: double.infinity,
                loading: false,
              ),
            ),
            Positioned(
              child: AppBar(
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20),
                  child: leadingPined(),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 20,
              right: 20,
              child: buildMember(
                context,
                member: widget.member,
                authStore: authStore,
                settingStore: settingStore,
                translate: translate,
                theme: theme,
              ),
            ),
          ],
        ),
        height: heightView,
      ),
    );
  }

  Widget buildMember(
    BuildContext context, {
    BPMember? member,
    required AuthStore authStore,
    required SettingStore settingStore,
    required TranslateType translate,
    required ThemeData theme,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 90,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
          ),
          child: buildImage(data: member, shimmerSize: 80),
        ),
        const SizedBox(height: 12),
        buildMentionName(data: member, theme: theme),
        Text(member?.name ?? "User", style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        buildDate(data: member, theme: theme, translate: translate),
        if (authStore.isLogin && authStore.user?.id != member?.id?.toString()) ...[
          const SizedBox(height: 16),
          MemberButtonFriendSlugWidget(
            id: widget.member?.id,
            slug: widget.member?.friendshipStatusSlug ?? "not_friends",
            callback: widget.callback,
            onRenderChild: (String title, Function onClick, bool loading) {
              return renderButton(
                title: title,
                onPress: () => onClick(),
                loading: loading,
                theme: theme,
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: renderButton(
                  title: translate("buddypress_publish_message"),
                  onPress: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) {
                          return BPActivityListScreen(
                            store: settingStore,
                            args: {
                              "mentionName": widget.member?.mentionName,
                            },
                          );
                        },
                        transitionsBuilder: slideTransition,
                      ),
                    );
                  },
                  theme: theme,
                  secondaryColor: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: renderButton(
                  title: translate("buddypress_private_message"),
                  onPress: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) {
                          if (messagePlugin == "BetterMessages") {
                            return BMMessageListScreen(
                              store: settingStore,
                              args: {
                                "send": widget.member,
                              },
                            );
                          }
                          return BPMessageListScreen(
                            store: settingStore,
                            args: {
                              "send": widget.member,
                            },
                          );
                        },
                        transitionsBuilder: slideTransition,
                      ),
                    );
                  },
                  theme: theme,
                  secondaryColor: true,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget renderButton({
    required String title,
    required VoidCallback onPress,
    bool loading = false,
    bool secondaryColor = false,
    required ThemeData theme,
  }) {
    ButtonStyle? style = secondaryColor
        ? ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
          )
        : null;
    return SizedBox(
      height: 34,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? () {} : onPress,
        style: style,
        child: loading ? entryLoading(context, color: secondaryColor ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary) : Text(title),
      ),
    );
  }
}
