import 'dart:ui';

import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class LanguageSetupLogic extends GetxController {
  final isFollowSystem = false.obs;
  final isChinese = false.obs;
  final isEnglish = false.obs;
  final isTraditionalChinese = false.obs;
  final isVietnamese = false.obs;

  @override
  void onInit() {
    _initLanguageSetting();
    super.onInit();
  }

  void _initLanguageSetting() {
    var language = DataSp.getLanguage() ?? 0;
    switch (language) {
      case 1:
        isFollowSystem.value = false;
        isChinese.value = true;
        isEnglish.value = false;
        isTraditionalChinese.value = false;
        isVietnamese.value = false;
        break;
      case 2:
        isFollowSystem.value = false;
        isChinese.value = false;
        isEnglish.value = true;
        isTraditionalChinese.value = false;
        isVietnamese.value = false;
        break;
      case 3:
        isFollowSystem.value = false;
        isChinese.value = false;
        isEnglish.value = false;
        isTraditionalChinese.value = true;
        isVietnamese.value = false;
        break;
      case 4:
        isFollowSystem.value = false;
        isChinese.value = false;
        isEnglish.value = false;
        isTraditionalChinese.value = false;
        isVietnamese.value = true;
        break;
      default:
        isFollowSystem.value = true;
        isChinese.value = false;
        isEnglish.value = false;
        isTraditionalChinese.value = false;
        isVietnamese.value = false;
        break;
    }
  }

  void switchLanguage(index) async {
    await DataSp.putLanguage(index);
    switch (index) {
      case 1:
        isFollowSystem.value = false;
        isChinese.value = true;
        isEnglish.value = false;
        isTraditionalChinese.value = false;
        isVietnamese.value = false;
        Get.updateLocale(const Locale('zh', 'CN'));
        break;
      case 2:
        isFollowSystem.value = false;
        isChinese.value = false;
        isEnglish.value = true;
        isTraditionalChinese.value = false;
        isVietnamese.value = false;
        Get.updateLocale(const Locale('en', 'US'));
        break;
      case 3:
        isFollowSystem.value = false;
        isChinese.value = false;
        isEnglish.value = false;
        isTraditionalChinese.value = true;
        isVietnamese.value = false;
        Get.updateLocale(const Locale('zh', 'TW'));
        break;
      case 4:
        isFollowSystem.value = false;
        isChinese.value = false;
        isEnglish.value = false;
        isTraditionalChinese.value = false;
        isVietnamese.value = true;
        Get.updateLocale(const Locale('vi', 'VN'));
        break;
      default:
        isFollowSystem.value = true;
        isChinese.value = false;
        isEnglish.value = false;
        isTraditionalChinese.value = false;
        isVietnamese.value = false;
        Get.updateLocale(window.locale);
        break;
    }
  }
}
