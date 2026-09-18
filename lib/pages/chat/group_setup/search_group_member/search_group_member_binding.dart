import 'package:get/get.dart';

import 'search_group_member_logic.dart';

class SearchGroupMemberBinding extends Bindings {
  /// 为每次群成员搜索路由创建独立控制器。
  @override
  void dependencies() {
    Get.lazyPut(() => SearchGroupMemberLogic());
  }
}
