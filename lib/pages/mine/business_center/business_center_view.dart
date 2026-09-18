import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

class BusinessCenterPage extends StatefulWidget {
  const BusinessCenterPage({super.key});

  @override
  State<BusinessCenterPage> createState() => _BusinessCenterPageState();
}

class _BusinessCenterPageState extends State<BusinessCenterPage> {
  bool loading = true;
  Map<String, dynamic> wallet = const {};
  Map<String, dynamic> recharge = const {};
  Map<String, dynamic> invitation = const {};
  Map<String, dynamic>? kyc;
  List<Map<String, dynamic>> paymentMethods = const [];
  List<Map<String, dynamic>> requests = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => loading = true);
    try {
      final values = await Future.wait<dynamic>([
        Apis.walletSummary(),
        Apis.walletRechargeOptions(),
        Apis.myInvitation(),
        Apis.getKYC(),
        Apis.paymentMethods(),
        Apis.walletRequests(),
      ]);
      if (!mounted) return;
      final methods = Map<String, dynamic>.from(values[4] as Map);
      final requestData = Map<String, dynamic>.from(values[5] as Map);
      setState(() {
        wallet = Map<String, dynamic>.from(values[0] as Map);
        recharge = Map<String, dynamic>.from(values[1] as Map);
        invitation = Map<String, dynamic>.from(values[2] as Map);
        kyc = values[3] == null
            ? null
            : Map<String, dynamic>.from(values[3] as Map);
        paymentMethods = _mapList(methods['list']);
        requests = _mapList(requestData['list']);
      });
    } catch (e) {
      IMViews.showToast(sprintf(StrRes.businessDataLoadFailed, [e]));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> _mapList(dynamic value) => value is List
      ? value.map((e) => Map<String, dynamic>.from(e as Map)).toList()
      : <Map<String, dynamic>>[];

  String _money(dynamic minor) =>
      ((minor is num ? minor.toInt() : 0) / 100).toStringAsFixed(2);

  int? _parseMoney(String value) {
    final match = RegExp(r'^\d{1,9}(?:\.\d{1,2})?$').firstMatch(value.trim());
    if (match == null) return null;
    final parts = value.trim().split('.');
    final cents = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
    return int.parse(parts[0]) * 100 + int.parse(cents);
  }

  String _requestKey() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';

  Future<String?> _pickImage() {
    final completer = Completer<String?>();
    IMViews.openPhotoSheet(onData: (path, url) async {
      if (!completer.isCompleted) completer.complete(url);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Styles.background,
        appBar: AppBar(
          title: Text(StrRes.businessWalletAndIdentity),
          backgroundColor: Styles.primary,
          foregroundColor: Colors.white,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _walletCard(),
                    const SizedBox(height: 12),
                    _identityCard(),
                    const SizedBox(height: 12),
                    _paymentCard(),
                    const SizedBox(height: 12),
                    _invitationCard(),
                    const SizedBox(height: 12),
                    _requestCard(),
                  ],
                ),
              ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Styles.divider),
        ),
        child: child,
      );

  Widget _walletCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(StrRes.businessWalletBalance,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 8),
            Text(
              '¥ ${_money(wallet['balanceMinor'])}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _showRecharge,
                    child: Text(StrRes.businessRecharge),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showWithdrawal,
                    child: Text(StrRes.businessWithdraw),
                  ),
                ),
              ],
            ),
            if ((recharge['supportMessage'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                recharge['supportMessage'].toString(),
                style: const TextStyle(color: Styles.muted, fontSize: 13),
              ),
            ],
          ],
        ),
      );

  Widget _identityCard() {
    final status = (kyc?['status'] ?? '').toString();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(StrRes.businessKyc,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            _statusChip(status),
          ]),
          if (kyc != null) ...[
            const SizedBox(height: 10),
            Text('${kyc?['realName'] ?? ''}  ${kyc?['idNumber'] ?? ''}'),
            if ((kyc?['reviewRemark'] ?? '').toString().isNotEmpty)
              Text(sprintf(StrRes.businessReviewRemark, [kyc?['reviewRemark']]),
                  style: const TextStyle(color: Styles.muted)),
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: status == 'approved' ? null : _showKYC,
            child: Text(kyc == null
                ? StrRes.businessSubmitIdentity
                : StrRes.businessResubmit),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(StrRes.businessWithdrawalPaymentMethod,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              TextButton(
                  onPressed: _showPaymentMethod, child: Text(StrRes.add)),
            ]),
            if (paymentMethods.isEmpty)
              Text(StrRes.businessNoPaymentMethod,
                  style: const TextStyle(color: Styles.muted))
            else
              ...paymentMethods.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(_paymentType(item['type'])),
                    subtitle: Text(
                        '${item['accountName'] ?? ''} ${item['bankName'] ?? ''} ${item['accountNo'] ?? ''}'),
                  )),
          ],
        ),
      );

  Widget _invitationCard() => _card(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(StrRes.businessMyInvitationCode,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(StrRes.businessInvitationHint,
                      style:
                          const TextStyle(color: Styles.muted, fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  IMUtils.copy(text: (invitation['code'] ?? '').toString()),
              child: Text((invitation['code'] ?? '—').toString(),
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );

  Widget _requestCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(StrRes.businessFundRequestRecords,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (requests.isEmpty)
              Text(StrRes.businessNoRecords,
                  style: const TextStyle(color: Styles.muted))
            else
              ...requests.take(10).map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(sprintf(StrRes.businessRequestAmount, [
                      item['type'] == 'withdraw'
                          ? StrRes.businessWithdraw
                          : StrRes.businessRecharge,
                      _money(item['amountMinor']),
                    ])),
                    subtitle: Text(item['reviewRemark'] ?? ''),
                    trailing: _statusChip((item['status'] ?? '').toString()),
                  )),
          ],
        ),
      );

  Widget _statusChip(String status) {
    final labels = {
      'pending': StrRes.businessStatusPending,
      'processing': StrRes.businessStatusProcessing,
      'approved': StrRes.businessStatusApproved,
      'rejected': StrRes.businessStatusRejected,
      '': StrRes.businessStatusNotSubmitted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'approved'
            ? Colors.green.withValues(alpha: .12)
            : Styles.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child:
          Text(labels[status] ?? status, style: const TextStyle(fontSize: 12)),
    );
  }

  String _paymentType(dynamic type) =>
      {
        'bank': StrRes.businessPaymentBank,
        'wechat': StrRes.businessPaymentWechat,
        'alipay': StrRes.businessPaymentAlipay,
      }[type] ??
      StrRes.businessPaymentMethod;

  Future<void> _showRecharge() async {
    final channels = _mapList(recharge['channels']);
    if (channels.isEmpty) {
      IMViews.showToast(
          (recharge['supportMessage'] ?? StrRes.businessContactSupportRecharge)
              .toString());
      return;
    }
    final amount = TextEditingController();
    String? proofURL;
    var selected = channels.first;
    final idempotencyKey = _requestKey();
    var submitting = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setLocal) {
        return _sheet(
          title: StrRes.businessSubmitRechargeRequest,
          children: [
            DropdownButtonFormField<String>(
              value: selected['id']?.toString(),
              decoration:
                  InputDecoration(labelText: StrRes.businessRechargeMethod),
              items: channels
                  .map((e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text(e['name'].toString())))
                  .toList(),
              onChanged: (value) => setLocal(() => selected = channels
                  .firstWhere((element) => element['id'].toString() == value)),
            ),
            const SizedBox(height: 8),
            _channelDetail(selected),
            TextField(
              controller: amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: StrRes.businessRechargeAmount),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final url = await _pickImage();
                if (url != null) setLocal(() => proofURL = url);
              },
              child: Text(proofURL == null
                  ? StrRes.businessUploadPaymentProof
                  : StrRes.businessPaymentProofUploaded),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (submitting) return;
                      final minor = _parseMoney(amount.text);
                      if (minor == null || minor <= 0) {
                        IMViews.showToast(StrRes.businessEnterValidAmount);
                        return;
                      }
                      // 同一张申请单在网络重试时沿用幂等键，避免客户端重复创建资金申请。
                      setLocal(() => submitting = true);
                      try {
                        await Apis.createRecharge(
                          idempotencyKey: idempotencyKey,
                          amountMinor: minor,
                          channelID: selected['id'].toString(),
                          proofURL: proofURL,
                        );
                        if (context.mounted) Navigator.pop(context);
                        IMViews.showToast(StrRes.businessRechargeSubmitted);
                        await _load();
                      } finally {
                        if (context.mounted) setLocal(() => submitting = false);
                      }
                    },
              child: Text(StrRes.businessSubmitRequest),
            ),
          ],
        );
      }),
    );
  }

  Widget _channelDetail(Map<String, dynamic> channel) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Styles.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((channel['bankName'] ?? '').toString().isNotEmpty)
              Text(sprintf(StrRes.businessBankName, [channel['bankName']])),
            if ((channel['accountName'] ?? '').toString().isNotEmpty)
              Text(sprintf(
                  StrRes.businessAccountName, [channel['accountName']])),
            if ((channel['accountNumber'] ?? '').toString().isNotEmpty)
              Text(sprintf(
                  StrRes.businessAccountNumber, [channel['accountNumber']])),
            if ((channel['qrCodeURL'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.network(channel['qrCodeURL'], height: 160),
              ),
          ],
        ),
      );

  Future<void> _showWithdrawal() async {
    if (kyc?['status'] != 'approved') {
      IMViews.showToast(StrRes.businessCompleteKycFirst);
      return;
    }
    if (paymentMethods.isEmpty) {
      IMViews.showToast(StrRes.businessAddPaymentMethodFirst);
      return;
    }
    final amount = TextEditingController();
    var methodID = paymentMethods.first['id'].toString();
    final idempotencyKey = _requestKey();
    var submitting = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
          builder: (context, setLocal) =>
              _sheet(title: StrRes.businessWithdrawRequest, children: [
                DropdownButtonFormField<String>(
                  value: methodID,
                  decoration:
                      InputDecoration(labelText: StrRes.businessPaymentMethod),
                  items: paymentMethods
                      .map((e) => DropdownMenuItem(
                          value: e['id'].toString(),
                          child: Text(
                              '${_paymentType(e['type'])} ${e['accountName']}')))
                      .toList(),
                  onChanged: (value) => setLocal(() => methodID = value!),
                ),
                TextField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(labelText: StrRes.businessWithdrawAmount),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (submitting) return;
                          final minor = _parseMoney(amount.text);
                          if (minor == null || minor <= 0) {
                            IMViews.showToast(StrRes.businessEnterValidAmount);
                            return;
                          }
                          // 与充值申请相同：一次弹窗操作始终复用同一幂等键。
                          setLocal(() => submitting = true);
                          try {
                            await Apis.createWithdrawal(
                                idempotencyKey: idempotencyKey,
                                amountMinor: minor,
                                paymentMethodID: methodID);
                            if (context.mounted) Navigator.pop(context);
                            IMViews.showToast(StrRes.businessWithdrawSubmitted);
                            await _load();
                          } finally {
                            if (context.mounted)
                              setLocal(() => submitting = false);
                          }
                        },
                  child: Text(StrRes.businessSubmitRequest),
                ),
              ])),
    );
  }

  Future<void> _showKYC() async {
    final name = TextEditingController(text: kyc?['realName']?.toString());
    final number = TextEditingController();
    String? frontURL;
    String? backURL;
    var submitting = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
          builder: (context, setLocal) =>
              _sheet(title: StrRes.businessKyc, children: [
                TextField(
                    controller: name,
                    decoration:
                        InputDecoration(labelText: StrRes.businessRealName)),
                TextField(
                    controller: number,
                    decoration:
                        InputDecoration(labelText: StrRes.businessIdNumber)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () async {
                            final url = await _pickImage();
                            if (url != null) setLocal(() => frontURL = url);
                          },
                          child: Text(frontURL == null
                              ? StrRes.businessUploadIdFront
                              : StrRes.businessIdFrontUploaded))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () async {
                            final url = await _pickImage();
                            if (url != null) setLocal(() => backURL = url);
                          },
                          child: Text(backURL == null
                              ? StrRes.businessUploadIdBack
                              : StrRes.businessIdBackUploaded))),
                ]),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (submitting) return;
                          if (name.text.trim().isEmpty ||
                              number.text.trim().length < 6 ||
                              frontURL == null ||
                              backURL == null) {
                            IMViews.showToast(
                                StrRes.businessCompleteKycDetails);
                            return;
                          }
                          setLocal(() => submitting = true);
                          try {
                            await Apis.submitKYC(
                                realName: name.text.trim(),
                                idNumber: number.text.trim(),
                                frontURL: frontURL!,
                                backURL: backURL!);
                            if (context.mounted) Navigator.pop(context);
                            IMViews.showToast(StrRes.businessKycSubmitted);
                            await _load();
                          } finally {
                            if (context.mounted)
                              setLocal(() => submitting = false);
                          }
                        },
                  child: Text(StrRes.businessSubmitReview),
                ),
              ])),
    );
  }

  Future<void> _showPaymentMethod() async {
    final name = TextEditingController();
    final account = TextEditingController();
    final bank = TextEditingController();
    var type = 'bank';
    String? qrURL;
    var submitting = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
          builder: (context, setLocal) =>
              _sheet(title: StrRes.businessAddPaymentMethod, children: [
                DropdownButtonFormField<String>(
                  value: type,
                  decoration:
                      InputDecoration(labelText: StrRes.businessPaymentType),
                  items: [
                    DropdownMenuItem(
                        value: 'bank', child: Text(StrRes.businessPaymentBank)),
                    DropdownMenuItem(
                        value: 'wechat',
                        child: Text(StrRes.businessPaymentWechat)),
                    DropdownMenuItem(
                        value: 'alipay',
                        child: Text(StrRes.businessPaymentAlipay)),
                  ],
                  onChanged: (value) => setLocal(() => type = value!),
                ),
                TextField(
                    controller: name,
                    decoration:
                        InputDecoration(labelText: StrRes.businessPayeeName)),
                if (type == 'bank') ...[
                  TextField(
                      controller: bank,
                      decoration: InputDecoration(
                          labelText: StrRes.businessBankNameLabel)),
                  TextField(
                      controller: account,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: StrRes.businessBankCardNumber)),
                ] else ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                      onPressed: () async {
                        final url = await _pickImage();
                        if (url != null) setLocal(() => qrURL = url);
                      },
                      child: Text(qrURL == null
                          ? StrRes.businessUploadPaymentQr
                          : StrRes.businessPaymentQrUploaded)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (submitting) return;
                          if (name.text.trim().isEmpty ||
                              (type == 'bank' &&
                                  (bank.text.trim().isEmpty ||
                                      account.text.trim().isEmpty)) ||
                              (type != 'bank' && qrURL == null)) {
                            IMViews.showToast(
                                StrRes.businessCompletePaymentDetails);
                            return;
                          }
                          setLocal(() => submitting = true);
                          try {
                            await Apis.savePaymentMethod(
                                type: type,
                                accountName: name.text.trim(),
                                bankName: bank.text.trim(),
                                accountNo: account.text.trim(),
                                qrCodeURL: qrURL);
                            if (context.mounted) Navigator.pop(context);
                            IMViews.showToast(
                                StrRes.businessPaymentMethodSaved);
                            await _load();
                          } finally {
                            if (context.mounted)
                              setLocal(() => submitting = false);
                          }
                        },
                  child: Text(StrRes.save),
                ),
              ])),
    );
  }

  Widget _sheet({required String title, required List<Widget> children}) =>
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      );
}
