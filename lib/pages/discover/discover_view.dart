import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../scan/scan_view.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _applets = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final applets = await Apis.findApplets();
      if (!mounted) return;
      final sorted = [...applets];
      sorted.sort((a, b) =>
          (a['priority'] as num? ?? 0).compareTo(b['priority'] as num? ?? 0));
      setState(() {
        _applets = sorted;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = StrRes.discoverLoadFailed;
      });
    }
  }

  String? _safeHttpUrl(dynamic value) {
    final raw = '$value'.trim();
    if (raw.isEmpty || raw == 'null') return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri.toString();
  }

  String? _resolveIcon(dynamic value) {
    final raw = '$value'.trim();
    if (raw.isEmpty || raw == 'null') return null;
    final direct = _safeHttpUrl(raw);
    if (direct != null) return direct;
    if (!raw.startsWith('/')) return null;
    final base = Uri.tryParse(Config.imApiUrl);
    return base?.resolve(raw).toString();
  }

  void _openApplet(Map<String, dynamic> applet) {
    final url = _safeHttpUrl(applet['url']);
    if (url == null) {
      IMViews.showToast(StrRes.linkUnavailable);
      return;
    }
    Get.to(() => H5Container(
          url: url,
          title: '${applet['name'] ?? StrRes.openLink}',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      appBar: TitleBar.workbench(showUnderline: true),
      body: RefreshIndicator(
        color: Styles.primary,
        onRefresh: _load,
        child: _loading
            ? ListView(children: [
                SizedBox(height: 220.h),
                const Center(child: CircularProgressIndicator()),
              ])
            : _error != null
                ? ListView(children: [
                    SizedBox(height: 180.h),
                    Center(child: Text(_error!)),
                  ])
                : ListView(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    children: [
                      _buildScanEntry(),
                      if (_applets.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 8.h),
                          child: Text(StrRes.discoverApps,
                              style: Styles.ts_8E9AB0_14sp),
                        ),
                        ..._applets.map(_buildApplet),
                      ] else
                        Padding(
                          padding: EdgeInsets.only(top: 120.h),
                          child: Center(
                            child: Text(StrRes.discoverEmpty,
                                style: Styles.ts_8E9AB0_14sp),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildScanEntry() => Material(
        color: Styles.surface,
        child: InkWell(
          onTap: () => Get.to(() => const ScanPage()),
          child: Container(
            constraints: BoxConstraints(minHeight: 64.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Styles.divider),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner_rounded,
                    color: Styles.primary, size: 26.w),
                14.horizontalSpace,
                Expanded(
                  child:
                      Text(StrRes.discoverScan, style: Styles.ts_0C1C33_17sp),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Styles.muted, size: 24.w),
              ],
            ),
          ),
        ),
      );

  Widget _buildApplet(Map<String, dynamic> applet) {
    final name = '${applet['name'] ?? ''}'.trim();
    final url = _safeHttpUrl(applet['url']);
    final icon = _resolveIcon(applet['icon']);
    return Material(
      color: Styles.surface,
      child: InkWell(
        onTap: url == null ? null : () => _openApplet(applet),
        child: Container(
          constraints: BoxConstraints(minHeight: 68.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Styles.divider)),
          ),
          child: Row(
            children: [
              _buildIcon(icon, name),
              12.horizontalSpace,
              Expanded(
                child: Text(
                  name.isEmpty ? StrRes.openLink : name,
                  style: Styles.ts_0C1C33_17sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (url == null)
                Text(StrRes.linkUnavailable, style: Styles.ts_8E9AB0_12sp)
              else
                Icon(Icons.chevron_right_rounded,
                    color: Styles.muted, size: 24.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String? url, String fallback) {
    if (url == null) {
      return CircleAvatar(
        radius: 22.r,
        backgroundColor: Styles.primaryContainer,
        child: Text(
          fallback.isEmpty ? 'A' : fallback.substring(0, 1),
          style: Styles.ts_0089FF_17sp_medium,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        url,
        width: 44.w,
        height: 44.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: 22.r,
          backgroundColor: Styles.primaryContainer,
          child: Text(fallback.isEmpty ? 'A' : fallback.substring(0, 1)),
        ),
      ),
    );
  }
}
