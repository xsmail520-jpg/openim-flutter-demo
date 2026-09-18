import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/pages/contacts/contacts_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScannedTarget {
  const ScannedTarget.user(this.id) : isGroup = false;
  const ScannedTarget.group(this.id) : isGroup = true;

  final String id;
  final bool isGroup;
}

ScannedTarget? parseScannedTarget(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme.toLowerCase() != 'io.openim.app') return null;
  final segments = uri.pathSegments.where((item) => item.isNotEmpty).toList();
  if (segments.length < 2) return null;
  final kind = segments.first.toLowerCase();
  final id = Uri.decodeComponent(segments[1]).trim();
  if (id.isEmpty) return null;
  if (kind == 'addfriend') return ScannedTarget.user(id);
  if (kind == 'joingroup') return ScannedTarget.group(id);
  return null;
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _qrKey = GlobalKey(debugLabel: 'OpenIMScan');
  QRViewController? _controller;
  bool _handled = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }

  void _onCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((barcode) {
      final code = barcode.code;
      if (code != null) _handleCode(code);
    });
  }

  Future<void> _handleCode(String code) async {
    if (_handled) return;
    final target = parseScannedTarget(code);
    if (target == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(StrRes.scanUnsupported)),
        );
      }
      return;
    }

    _handled = true;
    await _controller?.pauseCamera();
    if (!mounted) return;
    Get.back();
    final bridge = PackageBridge.scanBridge ??
        (Get.isRegistered<ContactsLogic>() ? Get.find<ContactsLogic>() : null);
    if (target.isGroup) {
      bridge?.scanOutGroupID(target.id);
    } else {
      bridge?.scanOutUserID(target.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(StrRes.scanTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _onCreated,
            onPermissionSet: (_, granted) {
              if (!granted && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(StrRes.cameraPermissionRequired)),
                );
              }
            },
            overlay: QrScannerOverlayShape(
              borderColor: Styles.primary,
              borderRadius: 12.r,
              borderLength: 34.w,
              borderWidth: 6.w,
              cutOutSize: 250.w,
            ),
          ),
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 42.h,
            child: Text(
              StrRes.scanHint,
              textAlign: TextAlign.center,
              style: Styles.ts_FFFFFF_14sp,
            ),
          ),
          Positioned(
            right: 18.w,
            bottom: 34.h,
            child: Row(
              children: [
                IconButton(
                  color: Colors.white,
                  tooltip: StrRes.flipCamera,
                  icon: const Icon(Icons.flip_camera_android_rounded),
                  onPressed: () => _controller?.flipCamera(),
                ),
                IconButton(
                  color: Colors.white,
                  tooltip: StrRes.toggleFlash,
                  icon: const Icon(Icons.flash_on_rounded),
                  onPressed: () => _controller?.toggleFlash(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
