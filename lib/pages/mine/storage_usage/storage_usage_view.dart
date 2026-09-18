import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:path_provider/path_provider.dart';

class StorageUsagePage extends StatefulWidget {
  const StorageUsagePage({super.key});

  @override
  State<StorageUsagePage> createState() => _StorageUsagePageState();
}

class _StorageUsagePageState extends State<StorageUsagePage> {
  bool _loading = true;
  int _cacheBytes = 0;
  int _serviceBytes = 0;
  Map<String, int> _breakdown = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<int> _sizeOf(FileSystemEntity entity) async {
    try {
      if (entity is File) return await entity.length();
      if (entity is Directory) {
        var total = 0;
        await for (final child in entity.list(followLinks: false)) {
          total += await _sizeOf(child);
        }
        return total;
      }
    } catch (_) {}
    return 0;
  }

  Future<Map<String, int>> _directoryBreakdown(Directory directory) async {
    final result = <String, int>{};
    if (!await directory.exists()) return result;
    await for (final child in directory.list(followLinks: false)) {
      final name = child.path.split(Platform.pathSeparator).last;
      result[name] = await _sizeOf(child);
    }
    return result;
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final cache = await getApplicationCacheDirectory();
    final documents = await getApplicationDocumentsDirectory();
    final cacheBytes = await _sizeOf(cache);
    final serviceBytes = await _sizeOf(documents);
    final breakdown = await _directoryBreakdown(cache);
    if (!mounted) return;
    setState(() {
      _cacheBytes = cacheBytes;
      _serviceBytes = serviceBytes;
      _breakdown = breakdown;
      _loading = false;
    });
  }

  Future<void> _clearCache() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(StrRes.clearCache),
        content: Text(StrRes.clearCacheConfirm),
        actions: [
          TextButton(onPressed: Get.back, child: Text(StrRes.cancel)),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(StrRes.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final cache = await getApplicationCacheDirectory();
      if (await cache.exists()) {
        await for (final child in cache.list(followLinks: false)) {
          await child.delete(recursive: true);
        }
      }
      IMViews.showToast(StrRes.cacheCleared);
      await _load();
    } catch (_) {
      IMViews.showToast(StrRes.settingsUpdateFailed);
    }
  }

  Future<void> _chooseRetention() async {
    final value = await Get.bottomSheet<int>(
      SafeArea(
        child: Material(
          color: Styles.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _retentionOption(0, StrRes.cacheRetentionForever),
              _retentionOption(7, StrRes.cacheRetentionSevenDays),
              _retentionOption(30, StrRes.cacheRetentionThirtyDays),
            ],
          ),
        ),
      ),
    );
    if (value == null) return;
    await DataSp.putCacheRetentionDays(value);
    if (mounted) setState(() {});
  }

  Widget _retentionOption(int value, String label) => ListTile(
        title: Text(label),
        trailing: DataSp.getCacheRetentionDays() == value
            ? Icon(Icons.check, color: Styles.primary)
            : null,
        onTap: () => Get.back(result: value),
      );

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes ${StrRes.bytesUnit}';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final retention = DataSp.getCacheRetentionDays();
    final retentionLabel = retention == 7
        ? StrRes.cacheRetentionSevenDays
        : retention == 30
            ? StrRes.cacheRetentionThirtyDays
            : StrRes.cacheRetentionForever;
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.dataStorage, showUnderline: true),
      backgroundColor: Styles.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                children: [
                  _row(StrRes.storageUsage, _formatBytes(_cacheBytes)),
                  _row(StrRes.appCache, _formatBytes(_cacheBytes)),
                  _row(StrRes.serviceData, _formatBytes(_serviceBytes),
                      showArrow: false),
                  if (_breakdown.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 6.h),
                      child: Text(StrRes.cacheBreakdown,
                          style: Styles.ts_8E9AB0_14sp),
                    ),
                    ..._breakdown.entries.map((entry) => _row(
                        entry.key, _formatBytes(entry.value),
                        showArrow: false)),
                  ],
                  12.verticalSpace,
                  _row(StrRes.cacheRetention, retentionLabel,
                      onTap: _chooseRetention),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    child: Text(StrRes.cacheRetentionHint,
                        style: Styles.ts_8E9AB0_12sp),
                  ),
                  Container(
                    color: Styles.surface,
                    child: ListTile(
                      title: Text(StrRes.clearCache,
                          style: TextStyle(color: Styles.danger)),
                      trailing:
                          Icon(Icons.delete_outline, color: Styles.danger),
                      onTap: _clearCache,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _row(
    String title,
    String value, {
    bool showArrow = true,
    VoidCallback? onTap,
  }) =>
      Container(
        color: Styles.surface,
        child: ListTile(
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: Styles.ts_8E9AB0_14sp),
              if (showArrow)
                Icon(Icons.chevron_right_rounded,
                    color: Styles.muted, size: 24.w),
            ],
          ),
          onTap: onTap,
        ),
      );
}
