import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

class ScreenLockTitle extends StatelessWidget {
  const ScreenLockTitle({
    Key? key,
    required this.stream,
  }) : super(key: key);

  final Stream<String> stream;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: Styles.ink,
        border: Border(bottom: BorderSide(color: Styles.primary, width: 2)),
      ),
      child: Column(
        children: [
          Text(
            StrRes.plsEnterPassword,
            style: Styles.ts_FFFFFF_17sp_medium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            child: StreamBuilder(
              builder: (context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    sprintf(StrRes.lockPwdErrorHint, [snapshot.data]),
                    style: Styles.ts_FF381F_17sp,
                    textAlign: TextAlign.center,
                  );
                }
                return const SizedBox();
              },
              stream: stream,
            ),
          ),
        ],
      ),
    );
  }
}
