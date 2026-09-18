import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _audits = [];

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
      final results =
          await Future.wait([Apis.loginSessions(), Apis.loginAudit()]);
      if (!mounted) return;
      final sessionData = results[0]['list'];
      final auditData = results[1]['list'];
      setState(() {
        _sessions = sessionData is List
            ? sessionData
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList()
            : [];
        _audits = auditData is List
            ? auditData.map((e) => Map<String, dynamic>.from(e as Map)).toList()
            : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = sprintf(StrRes.securityLoadFailed, [e]);
      });
    }
  }

  Future<bool> _confirmRevoke() async {
    final input = TextEditingController();
    final result = await Get.dialog<bool>(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(StrRes.securityRevokeDevice,
                  style: Styles.ts_0C1C33_17sp_medium),
              8.verticalSpace,
              Text(
                  sprintf(StrRes.securityRevokeDescription,
                      [StrRes.securityConfirmationWord]),
                  style: Styles.ts_8E9AB0_14sp),
              14.verticalSpace,
              TextField(
                controller: input,
                autofocus: true,
                decoration:
                    InputDecoration(hintText: StrRes.securityConfirmationWord),
              ),
              14.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(StrRes.cancel)),
                  8.horizontalSpace,
                  FilledButton(
                    onPressed: () => Get.back(
                        result: input.text.trim() ==
                            StrRes.securityConfirmationWord),
                    child: Text(StrRes.remove),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    input.dispose();
    return result == true;
  }

  Future<void> _revoke(Map<String, dynamic> session) async {
    if (!await _confirmRevoke()) return;
    try {
      await Apis.revokeLoginSession(sessionID: '${session['sessionID'] ?? ''}');
      IMViews.showToast(StrRes.securityDeviceRemoved);
      await _load();
    } catch (e) {
      IMViews.showToast(sprintf(StrRes.securityRevokeFailed, [e]));
    }
  }

  String _time(dynamic value) {
    final date = DateTime.tryParse('$value');
    return date == null ? '—' : date.toLocal().toString().substring(0, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StrRes.securityTitle)),
      backgroundColor: Styles.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    children: [
                      _sectionTitle(StrRes.securityCurrentDevices),
                      if (_sessions.isEmpty)
                        _empty(StrRes.securityNoDevices)
                      else
                        ..._sessions.map((session) => _sessionTile(session)),
                      _sectionTitle(StrRes.securityLoginAudit),
                      if (_audits.isEmpty)
                        _empty(StrRes.securityNoLoginAudit)
                      else
                        ..._audits.map(_auditTile),
                    ],
                  ),
                ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
        child: Text(text, style: Styles.ts_8E9AB0_14sp),
      );

  Widget _empty(String text) => Container(
        color: Styles.surface,
        padding: EdgeInsets.all(22.w),
        child: Center(child: Text(text, style: Styles.ts_8E9AB0_14sp)),
      );

  Widget _sessionTile(Map<String, dynamic> session) {
    final current = session['current'] == true;
    return Container(
      color: Styles.surface,
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        leading: Icon(current ? Icons.phone_android : Icons.devices_outlined,
            color: Styles.primary),
        title: Text('${session['platform'] ?? StrRes.securityUnknownPlatform}'
            '${current ? StrRes.securityCurrentDeviceMarker : ''}'),
        subtitle: Text(sprintf(StrRes.securitySessionDetails, [
          session['deviceID'] ?? StrRes.securityUnknownDevice,
          _time(session['loginAt']),
          _time(session['lastSeenAt']),
        ])),
        isThreeLine: true,
        trailing: current
            ? const SizedBox.shrink()
            : TextButton(
                onPressed: () => _revoke(session), child: Text(StrRes.remove)),
      ),
    );
  }

  Widget _auditTile(Map<String, dynamic> audit) => Container(
        color: Styles.surface,
        margin: EdgeInsets.only(bottom: 1.h),
        child: ListTile(
          leading: const Icon(Icons.history, color: Styles.muted),
          title: Text(sprintf(StrRes.securityAuditSummary, [
            audit['action'] ?? StrRes.securityLoginAction,
            audit['result'] ?? ''
          ])),
          subtitle: Text(sprintf(StrRes.securityAuditDetails, [
            _time(audit['createdAt']),
            audit['ip'] ?? StrRes.securityIpNotRecorded
          ])),
          isThreeLine: true,
        ),
      );
}
