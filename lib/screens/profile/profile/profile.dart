import 'package:cirilla/constants/constants.dart';
import 'package:cirilla/constants/strings.dart';
import 'package:cirilla/mixins/utility_mixin.dart';
import 'package:cirilla/models/setting/setting.dart';
import 'package:cirilla/store/store.dart';
import 'package:cirilla/utils/conditionals.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'data.dart';

import 'layout_style1.dart';
import 'layout_style2.dart';
import 'layout_style3.dart';
import 'layout_style4.dart';

import 'footer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with Utility {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late SettingStore _settingStore;
  late AuthStore _authStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingStore = Provider.of<SettingStore>(context);
    _authStore = Provider.of<AuthStore>(context);
  }

  void showMessage({String? message}) {
    scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: Colors.green,
        ),
        margin: secondPaddingSmall,
        padding: secondPaddingSmall,
        height: 40,
        child: Center(child: Text(message ?? '')),
      ),
    ));
  }

  dynamic toVariable(String variable) {
    if (variable == "user.id") {
      return _authStore.user?.id ?? "";
    }

    if (variable == "user.displayName") {
      return _authStore.user?.displayName ?? "";
    }

    if (variable == "user.userEmail") {
      return _authStore.user?.userEmail ?? "";
    }

    if (variable == "user.loginType") {
      return _authStore.user?.loginType ?? "";
    }

    if (variable == "user.roles") {
      return _authStore.user?.roles ?? [];
    }

    if (variable == "language") {
      return _settingStore.locale;
    }

    return _authStore.isLogin ? 'true' : 'false';
  }

  List getBlocks(List data) {
    List result = [];
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        dynamic block = data[i];
        dynamic conditional = get(block, ["data", "conditional"], null);
        if (conditional != null && conditional['when_conditionals'] != null && conditional['conditionals'] != null) {
          bool check = conditionalCheck(
            conditional['when_conditionals'],
            conditional['conditionals'],
            [
              "isLogin",
              "language",
              "user.id",
              "user.displayName",
              "user.userEmail",
              "user.loginType",
              "user.roles",
            ],
            toVariable,
          );

          if (check) {
            result.add(block);
          }
        } else {
          result.add(block);
        }
      }
    }
    return result;
  }

  List getItemBlocks(List data) {
    List result = [];
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        dynamic block = data[i];
        dynamic conditional = get(block, ["value", "conditional"], null);
        if (conditional != null && conditional['when_conditionals'] != null && conditional['conditionals'] != null) {
          bool check = conditionalCheck(
            conditional['when_conditionals'],
            conditional['conditionals'],
            [
              "isLogin",
              "language",
              "user.id",
              "user.displayName",
              "user.userEmail",
              "user.loginType",
              "user.roles",
            ],
            toVariable,
          );

          if (check) {
            result.add(block);
          }
        } else {
          result.add(block);
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    String languageKey = _settingStore.languageKey;

    WidgetConfig widgetConfig = _settingStore.data!.screens!['profile']!.widgets!['profilePage']!;

    String layout = widgetConfig.layout ?? Strings.profileLayoutStyle1;

    Map<String, dynamic>? fields = widgetConfig.fields;

    String? textCopyRight = get(fields, ['textCopyRight', languageKey], '© Cirrilla 2020');
    List? socials = get(fields, ['itemSocial'], []);
    List blocksFields = get(fields, ['blocks'], initProfileBlocks);

    // Padding
    Map<String, dynamic>? paddingData = get(widgetConfig.styles, ['padding']);
    EdgeInsetsDirectional padding =
        paddingData != null ? ConvertData.space(paddingData, 'padding') : defaultScreenPadding;

    return ScaffoldMessenger(
      child: Observer(
        builder: (_) {
          List blocks = getBlocks(blocksFields);
          switch (layout) {
            case Strings.profileLayoutStyle2:
              return LayoutStyle2(
                isLogin: _authStore.isLogin,
                user: _authStore.user,
                blocks: blocks,
                getItems: getItemBlocks,
                footer: Footer(
                  copyright: textCopyRight,
                  socials: socials,
                ),
                padding: padding,
              );
            case Strings.profileLayoutStyle3:
              return LayoutStyle3(
                isLogin: _authStore.isLogin,
                user: _authStore.user,
                blocks: blocks,
                getItems: getItemBlocks,
                footer: Footer(
                  copyright: textCopyRight,
                  socials: socials,
                ),
                padding: padding,
              );
            case Strings.profileLayoutStyle4:
              return LayoutStyle4(
                isLogin: _authStore.isLogin,
                user: _authStore.user,
                blocks: blocks,
                getItems: getItemBlocks,
                footer: Footer(
                  copyright: textCopyRight,
                  socials: socials,
                ),
                padding: padding,
              );
            default:
              return LayoutStyle1(
                isLogin: _authStore.isLogin,
                user: _authStore.user,
                blocks: blocks,
                getItems: getItemBlocks,
                footer: Footer(
                  copyright: textCopyRight,
                  socials: socials,
                ),
                padding: padding,
              );
          }
        },
      ),
    );
  }
}
