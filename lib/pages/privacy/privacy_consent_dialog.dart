import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyConsentDialog extends StatelessWidget {
  const PrivacyConsentDialog({super.key});

  Future<void> _openUrl(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(height: 1.45)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(StrRes.privacyConsentTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 460),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(StrRes.privacyConsentSummary),
                _section(StrRes.privacyConsentAccount),
                _section(StrRes.privacyConsentMessages),
                _section(StrRes.privacyConsentDevice),
                _section(StrRes.privacyConsentPermissions),
                _section(StrRes.privacyConsentThirdParty),
                _section(StrRes.privacyConsentRights),
                Wrap(
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => _openUrl(Config.privacyPolicyUrl),
                      child: Text(StrRes.privacyConsentPolicyLink),
                    ),
                    TextButton(
                      onPressed: () => _openUrl(Config.userAgreementUrl),
                      child: Text(StrRes.privacyConsentAgreementLink),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: Text(StrRes.privacyConsentDecline),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(StrRes.privacyConsentAgree),
          ),
        ],
      ),
    );
  }
}
