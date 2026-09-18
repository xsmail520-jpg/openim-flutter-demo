import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprintf/sprintf.dart';

class Permissions {
  Permissions._();

  /// Only checks an already-granted system capability for background calls.
  /// The app does not request this permission automatically during sync/login.
  static Future<bool> checkSystemAlertWindow() async {
    return Permission.systemAlertWindow.isGranted;
  }

  static Future<bool> checkStorage() async {
    return await Permission.storage.isGranted;
  }

  static void camera(Function()? onGranted) async {
    if (await Permission.camera.request().isGranted) {
      onGranted?.call();
    }
    if (await Permission.camera.isPermanentlyDenied ||
        await Permission.camera.isDenied) {
      _showPermissionDeniedDialog(Permission.camera.title);
    }
  }

  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    // Android 13+ writes through MediaStore; requesting MANAGE_EXTERNAL_STORAGE
    // is unnecessary and can strand users in a restricted system settings page.
    if (androidInfo.version.sdkInt >= 33) return true;

    final permission = Permission.storage;
    if (await permission.request().isGranted) return true;
    if (await permission.isPermanentlyDenied || await permission.isDenied) {
      _showPermissionDeniedDialog(permission.title);
    }
    return false;
  }

  static void storage(Function()? onGranted) async {
    if (await requestStoragePermission()) {
      onGranted?.call();
    }
  }

  static void microphone(Function()? onGranted) async {
    if (await Permission.microphone.request().isGranted) {
      onGranted?.call();
    }
    if (await Permission.microphone.isPermanentlyDenied ||
        await Permission.microphone.isDenied) {
      _showPermissionDeniedDialog(Permission.microphone.title);
    }
  }

  static void speech(Function()? onGranted) async {
    if (await Permission.speech.request().isGranted) {
      onGranted?.call();
    }
    if (await Permission.speech.isPermanentlyDenied ||
        await Permission.speech.isDenied) {
      _showPermissionDeniedDialog(Permission.speech.title);
    }
  }

  static void photos(Function()? onGranted) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        storage(onGranted);
      } else {
        if (await Permission.photos.request().isGranted) {
          onGranted?.call();
        }
        if (await Permission.photos.isPermanentlyDenied ||
            await Permission.photos.isDenied) {
          _showPermissionDeniedDialog(Permission.photos.title);
        }
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        onGranted?.call();
      }
      if (await Permission.photos.isPermanentlyDenied ||
          await Permission.photos.isDenied) {
        _showPermissionDeniedDialog(Permission.photos.title);
      }
    }
  }

  static Future<bool> notification() async {
    if (await Permission.notification.request().isGranted) {
      return true;
    }
    if (await Permission.notification.isPermanentlyDenied ||
        await Permission.notification.isDenied) {
      _showPermissionDeniedDialog(Permission.notification.title);
    }

    return false;
  }

  static void cameraAndMicrophone(Function()? onGranted) async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
    ];
    bool isAllGranted = true;
    var msg = '';

    for (var permission in permissions) {
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
      if (!state.isGranted) {
        msg += '${permission.title}、';
      }
    }
    if (isAllGranted) {
      onGranted?.call();
    } else {
      msg = msg.substring(0, msg.length - 1);
      _showPermissionDeniedDialog(msg);
    }
  }

  static Future<bool> media() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
    ];
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        permissions.add(Permission.storage);
      } else {
        permissions.add(Permission.photos);
      }
    } else {
      permissions.add(Permission.photos);
    }

    bool isAllGranted = true;
    var msg = '';

    for (var permission in permissions) {
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
      if (!state.isGranted) {
        msg += '${permission.title}、';
      }
    }

    if (!isAllGranted) {
      msg = msg.substring(0, msg.length - 1);
      _showPermissionDeniedDialog(msg);
    }

    return isAllGranted;
  }

  static Future<Map<Permission, PermissionStatus>> request(
      List<Permission> permissions) async {
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses;
  }

  static void _showPermissionDeniedDialog(String tips) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StrRes.permissionDeniedTitle),
          content: Text(
            sprintf(StrRes.permissionDeniedHint, [tips]),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(StrRes.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(StrRes.determine),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}

extension PermissionExt on Permission {
  String get title {
    switch (this) {
      case Permission.storage:
        return StrRes.externalStorage;
      case Permission.photos:
        return StrRes.gallery;
      case Permission.camera:
        return StrRes.camera;
      case Permission.microphone:
        return StrRes.microphone;
      case Permission.notification:
        return StrRes.notification;
      default:
        return '';
    }
  }
}
