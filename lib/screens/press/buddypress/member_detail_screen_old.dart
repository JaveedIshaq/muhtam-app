import 'package:cirilla/constants/constants.dart';
import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/store/store.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../better_messages/better_messages.dart';
import '../constants.dart';
import 'activity_list_screen.dart';
import 'member_detail_info_screen.dart';
import 'message_list_screen.dart';

import 'models/models.dart';
import 'stores/stores.dart';
import 'widgets/widgets.dart';

class BPMemberDetailScreen extends StatefulWidget {
  static const routeName = '/buddypress-member-detail';

  final Map? args;
  final SettingStore? store;

  const BPMemberDetailScreen({
    super.key,
    this.store,
    this.args,
  });

  @override
  State<BPMemberDetailScreen> createState() => _BPMemberDetailScreenState();
}

class _BPMemberDetailScreenState extends State<BPMemberDetailScreen> with AppBarMixin, SnackMixin, LoadingMixin {
  BPMember? _member;
  bool _loading = false;

  @override
  void initState() {
    if (widget.args?["member"] is BPMember) {
      _member = widget.args?["member"];
    } else if (ConvertData.stringToInt(widget.args?["id"]) != 0) {
      getMember(ConvertData.stringToInt(widget.args?["id"]));
    }
    super.initState();
  }

  void getMember(int id) async {
    try {
      setState(() {
        _loading = true;
      });
      BPMember? data = await widget.store?.requestHelper.getMember(
          id: id,
          queryParameters: {
            "populate_extras": true
          }
      );
      setState(() {
        _loading = false;
        if (data is BPMember) {
          _member = data;
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;

    if (_loading && _member?.id == null) {
      return Scaffold(
        appBar: baseStyleAppBar(context, title: _member?.name ?? ""),
        body: Center(
          child: buildLoading(context, isLoading: _loading),
        ),
      );
    }

    if (_member?.id == null) {
      return Scaffold(
        appBar: baseStyleAppBar(context, title: _member?.name ?? ""),
        body: Center(
          child: Text(translate("buddypress_member_no")),
        ),
      );
    }

    return _ContentMember(
      member: _member!,
      store: widget.store,
    );
  }
}

class _ContentMember extends StatefulWidget {
  final BPMember member;
  final SettingStore? store;

  const _ContentMember({
    required this.member,
    this.store,
  });

  @override
  State<_ContentMember> createState() => _ContentMemberState();
}

class _ContentMemberState extends State<_ContentMember> with AppBarMixin, LoadingMixin {
  late AuthStore _authStore;

  late BPActivityStore _activityStore;

  final ScrollController _controller = ScrollController();
  final _popupMenu = GlobalKey<PopupMenuButtonState>();

  @override
  void initState() {
    _controller.addListener(_onScroll);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthStore>(context);
    _activityStore = BPActivityStore(
      widget.store!.requestHelper,
      userId: widget.member.id,
      displayComments: "stream",
    )..getActivities();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _activityStore.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients || _activityStore.loading || !_activityStore.canLoadMore) return;
    final thresholdReached = _controller.position.extentAfter < endReachedThreshold;

    if (thresholdReached) {
      _activityStore.getActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;

    return Observer(
      builder: (_) {
        bool loading = _activityStore.loading;
        List<BPActivity> activities = _activityStore.activities;
        List<BPActivity> emptyActivity = List.generate(_activityStore.perPage, (index) => BPActivity()).toList();

        List<BPActivity> data = loading && activities.isEmpty ? emptyActivity : activities;

        return Scaffold(
          appBar: baseStyleAppBar(
              context,
              title: widget.member.name ?? "",
              actions: [
                PopupMenuButton<int>(
                  key: _popupMenu,
                  // Callback that sets the selected popup menu item.
                  onSelected: (int item) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) {
                          switch (item) {
                            case 2:
                              if (messagePlugin == "BetterMessages") {
                                return BMMessageListScreen(
                                  store: widget.store,
                                );
                              }
                              return BPMessageListScreen(
                                store: widget.store,
                              );
                            case 4:
                              return BPActivityListScreen(
                                store: widget.store,
                                args: {
                                  "mentionName": widget.member.mentionName,
                                },
                              );
                            case 5:
                              if (messagePlugin == "BetterMessages") {
                                return BMMessageListScreen(
                                  store: widget.store,
                                  args: {
                                    "send": widget.member,
                                  },
                                );
                              }
                              return BPMessageListScreen(
                                store: widget.store,
                                args: {
                                  "send": widget.member,
                                },
                              );
                            default:
                              return BPMemberDetailInfoScreen(
                                member: widget.member,
                              );
                          }
                        },
                      ),
                    );
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text(translate("buddypress_profile")),
                    ),
                    if (_authStore.isLogin && _authStore.user?.id == "${widget.member.id}")
                      PopupMenuItem<int>(
                        value: 2,
                        child: Text(translate("buddypress_message_list")),
                      ),
                    // PopupMenuItem<int>(
                    //   value: 3,
                    //   child: Text("Friends"),
                    // ),
                    if (_authStore.isLogin && _authStore.user?.id != "${widget.member.id}") ...[
                      PopupMenuItem<int>(
                        value: 4,
                        child: Text(translate("buddypress_publish_message")),
                      ),
                      PopupMenuItem<int>(
                        value: 5,
                        child: Text(translate("buddypress_private_message")),
                      )
                    ],
                  ],
                  position: PopupMenuPosition.under,
                  // offset: const Offset(0, 12),
                ),
                const SizedBox(width: 6),
              ],
          ),
          body: CustomScrollView(
            controller: _controller,
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: _activityStore.refresh,
                builder: buildAppRefreshIndicator,
              ),
              if (data.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (_, index) => ActivityItemWidget(
                        activity: data[index],
                        callback: (_) => _activityStore.refresh(),
                      ),
                      childCount: data.length,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Center(
                    child: Text(translate("buddypress_empty")),
                  ),
                ),
              if (loading && activities.isNotEmpty)
                SliverToBoxAdapter(
                  child: buildLoading(context, isLoading: _activityStore.canLoadMore),
                ),
            ],
          ),
        );
      },
    );
  }
}