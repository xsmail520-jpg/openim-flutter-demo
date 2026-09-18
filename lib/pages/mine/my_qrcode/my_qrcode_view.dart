import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/pages/contacts/select_contacts/select_contacts_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrCodePage extends StatefulWidget {
  const MyQrCodePage({super.key});

  @override
  State<MyQrCodePage> createState() => _MyQrCodePageState();
}

class _MyQrCodePageState extends State<MyQrCodePage> {
  final _captureKey = GlobalKey();
  bool _busy = false;

  String get _userID => OpenIM.iMManager.userID;

  Future<ui.Image?> _captureImage() async {
    await WidgetsBinding.instance.endOfFrame;
    final renderObject = _captureKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;
    return renderObject.toImage(pixelRatio: 3);
  }

  Future<Uint8List?> _capturePng() async {
    final image = await _captureImage();
    if (image == null) return null;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final image = await _captureImage();
      if (image == null) {
        IMViews.showToast(StrRes.qrcodeSaveFailed);
        return;
      }
      try {
        await HttpUtil.saveImage(image);
      } finally {
        image.dispose();
      }
      IMViews.showToast(StrRes.qrcodeSaved);
    } catch (_) {
      IMViews.showToast(StrRes.qrcodeSaveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    final selected = await AppNavigator.startSelectContacts(
      action: SelAction.forward,
      ex: StrRes.qrcodeShareTitle,
    );
    if (selected is! Map || selected['checkedList'] is! Iterable) return;
    final bytes = await _capturePng();
    if (bytes == null) {
      IMViews.showToast(StrRes.qrcodeSaveFailed);
      return;
    }

    setState(() => _busy = true);
    try {
      final path = await IMUtils.createTempFile(
        dir: 'qr',
        name: 'my_qr_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await File(path).writeAsBytes(bytes, flush: true);
      var sent = 0;
      for (final info in (selected['checkedList'] as Iterable)) {
        final userID = IMUtils.convertCheckedToUserID(info);
        final groupID = IMUtils.convertCheckedToGroupID(info);
        if ((userID == null || userID.isEmpty) &&
            (groupID == null || groupID.isEmpty)) continue;
        final message = await OpenIM.iMManager.messageManager
            .createImageMessageFromFullPath(imagePath: path);
        await OpenIM.iMManager.messageManager.sendMessage(
          message: message,
          userID: userID,
          groupID: groupID,
          offlinePushInfo: Config.offlinePushInfo,
        );
        sent++;
      }
      IMViews.showToast(
          sent == 0 ? StrRes.qrcodeNoRecipient : StrRes.qrcodeShared);
    } catch (_) {
      IMViews.showToast(StrRes.qrcodeShareFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = OpenIM.iMManager.userInfo;
    final nickname = user.nickname ?? _userID;
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.myQrcode, showUnderline: true),
      backgroundColor: Styles.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 28.h),
        child: Column(
          children: [
            RepaintBoundary(
              key: _captureKey,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 22.h),
                decoration: BoxDecoration(
                  color: Styles.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Styles.divider),
                ),
                child: Column(
                  children: [
                    AvatarView(
                      width: 72.w,
                      height: 72.h,
                      url: user.faceURL,
                      text: nickname,
                      textStyle: Styles.ts_FFFFFF_17sp,
                    ),
                    12.verticalSpace,
                    Text(
                      nickname,
                      style: TextStyle(
                        color: Styles.ink,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.verticalSpace,
                    Text('${StrRes.imchatID}：$_userID',
                        style: Styles.ts_8E9AB0_14sp),
                    22.verticalSpace,
                    QrImageView(
                      data: '${Config.friendScheme}$_userID',
                      version: QrVersions.auto,
                      size: 230.w,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                    14.verticalSpace,
                    Text(StrRes.qrcodeHint,
                        style: Styles.ts_8E9AB0_13sp,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            18.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(StrRes.saveQrcode),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _share,
                    icon: const Icon(Icons.share_rounded),
                    label: Text(StrRes.shareQrcode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
