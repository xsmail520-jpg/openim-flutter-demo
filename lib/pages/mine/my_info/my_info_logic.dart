import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as date_picker;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/login/login_logic.dart';
import 'package:openim/pages/mine/edit_my_info/edit_my_info_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';

class MyInfoLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final loginType = LoginType.fromRawValue(DataSp.getLoginType());

  void editMyName() => AppNavigator.startEditMyInfo();

  void editEnglishName() => AppNavigator.startEditMyInfo(
        attr: EditAttr.englishName,
      );

  void editTel() => AppNavigator.startEditMyInfo(
        attr: EditAttr.telephone,
      );

  void editMobile() => AppNavigator.startEditMyInfo(
        attr: EditAttr.mobile,
      );

  void editEmail() =>
      AppNavigator.startEditMyInfo(attr: EditAttr.email, maxLength: 30);

  void copyID() => IMUtils.copy(text: OpenIM.iMManager.userID);

  void changePassword() => AppNavigator.startChangePassword();

  Future<void> editPersonalIntro() async {
    final controller =
        TextEditingController(text: imLogic.userInfo.value.ex ?? '');
    final value = await Get.dialog<String>(
      AlertDialog(
        title: Text(StrRes.personalIntro),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 200,
          maxLines: 4,
          decoration: InputDecoration(hintText: StrRes.introEditHint),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(StrRes.cancel)),
          FilledButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: Text(StrRes.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    try {
      await OpenIM.iMManager.userManager.setSelfInfo(ex: value);
      imLogic.userInfo.update((info) => info?.ex = value);
    } catch (_) {
      IMViews.showToast(StrRes.settingsUpdateFailed);
    }
  }

  void openPhotoSheet() {
    IMViews.openPhotoSheet(
        onData: (path, url) async {
          if (url != null) {
            LoadingView.singleton.wrap(
              asyncFunction: () => Apis.updateUserInfo(
                      userID: OpenIM.iMManager.userID, faceURL: url)
                  .then((value) => imLogic.userInfo.update((val) {
                        val?.faceURL = url;
                      })),
            );
          }
        },
        quality: 15);
  }

  void openDatePicker() {
    var appLocale = Get.locale;
    var isZh = appLocale!.languageCode.toLowerCase().contains("zh");
    date_picker.DatePicker.showDatePicker(
      Get.context!,
      locale: isZh ? date_picker.LocaleType.zh : date_picker.LocaleType.en,
      maxTime: DateTime.now(),
      currentTime: DateTime.fromMillisecondsSinceEpoch(
          imLogic.userInfo.value.birth ?? 0),
      theme: date_picker.DatePickerTheme(
        cancelStyle: Styles.ts_0C1C33_17sp,
        doneStyle: Styles.ts_0089FF_17sp,
        itemStyle: Styles.ts_0C1C33_17sp,
      ),
      onConfirm: (dateTime) {
        _updateBirthday(dateTime.millisecondsSinceEpoch ~/ 1000);
      },
    );
  }

  void selectGender() {
    Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.man,
            onTap: () => _updateGender(1),
          ),
          SheetItem(
            label: StrRes.woman,
            onTap: () => _updateGender(2),
          ),
        ],
      ),
    );
  }

  void _updateGender(int gender) {
    LoadingView.singleton.wrap(
      asyncFunction: () =>
          Apis.updateUserInfo(userID: OpenIM.iMManager.userID, gender: gender)
              .then((value) => imLogic.userInfo.update((val) {
                    val?.gender = gender;
                  })),
    );
  }

  void _updateBirthday(int birthday) {
    LoadingView.singleton.wrap(
      asyncFunction: () => Apis.updateUserInfo(
        userID: OpenIM.iMManager.userID,
        birth: birthday * 1000,
      ).then((value) => imLogic.userInfo.update((val) {
            val?.birth = birthday * 1000;
          })),
    );
  }

  @override
  void onReady() {
    _queryMyFullIno();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _queryMyFullIno() async {
    final info = await LoadingView.singleton.wrap(
      asyncFunction: () => Apis.queryMyFullInfo(),
    );
    if (null != info) {
      imLogic.userInfo.update((val) {
        val?.nickname = info.nickname;
        val?.faceURL = info.faceURL;
        val?.gender = info.gender;
        val?.phoneNumber = info.phoneNumber;
        val?.birth = info.birth;
        val?.email = info.email;
      });
    }
  }

  static _trimNullStr(String? value) => IMUtils.emptyStrToNull(value);
}
