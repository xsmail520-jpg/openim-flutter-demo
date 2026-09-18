import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'create_group_logic.dart';

class CreateGroupPage extends StatelessWidget {
  final logic = Get.find<CreateGroupLogic>();

  CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: TitleBar.back(
          title: StrRes.createGroup,
          showUnderline: true,
        ),
        backgroundColor: Styles.background,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 12.h, bottom: 20.h),
                  child: Column(
                    children: [
                      _buildGroupBaseInfoView(),
                      12.verticalSpace,
                      _buildGroupMemberView(),
                    ],
                  ),
                ),
              ),
              _buildActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  /// 群基础资料使用连续表单分区，头像与名称输入保持同一视觉基线。
  Widget _buildGroupBaseInfoView() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Obx(
          () => Row(
            children: [
              if (logic.faceURL.isNotEmpty)
                AvatarView(
                  width: 52.w,
                  height: 52.h,
                  url: logic.faceURL.value,
                  onTap: logic.selectAvatar,
                )
              else
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: logic.selectAvatar,
                    borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                    child: Container(
                      width: 52.w,
                      height: 52.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Styles.background,
                        border: Border.all(
                          color: Styles.divider,
                          width: Styles.dividerWidth,
                        ),
                        borderRadius:
                            BorderRadius.circular(Styles.radiusSmall.r),
                      ),
                      child: ImageRes.cameraGray.toImage
                        ..width = 28.w
                        ..height = 28.h,
                    ),
                  ),
                ),
              12.horizontalSpace,
              Expanded(
                child: TextField(
                  style: Styles.ts_0C1C33_17sp,
                  autofocus: true,
                  controller: logic.nameCtrl,
                  inputFormatters: [LengthLimitingTextInputFormatter(16)],
                  decoration: InputDecoration(
                    hintStyle: Styles.ts_8E9AB0_17sp,
                    hintText: StrRes.plsEnterGroupNameHint,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Styles.divider,
                        width: Styles.dividerWidth,
                      ),
                      borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Styles.primary,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// 成员区以表头和名单网格分层，人数状态始终与成员内容对齐。
  Widget _buildGroupMemberView() => Obx(() => Container(
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: 44.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: const BoxDecoration(
                border: BorderDirectional(
                  bottom: BorderSide(
                    color: Styles.divider,
                    width: Styles.dividerWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  StrRes.groupMember.toText
                    ..style = Styles.ts_0C1C33_17sp_semibold,
                  const Spacer(),
                  sprintf(StrRes.nPerson, [logic.allList.length]).toText
                    ..style = Styles.ts_8E9AB0_14sp,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logic.length(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 6.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 64.w / 76.h,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return logic.itemBuilder(
                    index: index,
                    builder: (info) => Column(
                      children: [
                        AvatarView(
                          width: 48.w,
                          height: 48.h,
                          url: info.faceURL,
                          text: info.nickname,
                          textStyle: Styles.ts_FFFFFF_14sp,
                        ),
                        4.verticalSpace,
                        (info.nickname ?? '').toText
                          ..style = Styles.ts_8E9AB0_12sp
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis,
                      ],
                    ),
                    addButton: () => const SizedBox.shrink(),
                    delButton: () => const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ],
        ),
      ));

  Widget _buildActionBar() => Container(
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: BorderDirectional(
            top: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
        child: Button(
          text: StrRes.completeCreation,
          onTap: logic.completeCreation,
        ),
      );
}
