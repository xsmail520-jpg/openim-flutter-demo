import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class LoadingView {
  static final LoadingView singleton = LoadingView._();

  factory LoadingView() => singleton;

  LoadingView._();

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  OverlayState? _progressOverlayState;
  OverlayEntry? _progressOverlayEntry;
  bool isProgressVisible = false;

  Future<T> wrap<T>({
    required Future<T> Function() asyncFunction,
    bool showing = true,
  }) async {
    await Future.delayed(1.milliseconds);
    if (showing) show();
    T data;
    try {
      data = await asyncFunction();
    } on Exception catch (_) {
      rethrow;
    } finally {
      dismiss();
    }
    return data;
  }

  void show() async {
    if (_isVisible) return;
    _overlayState = Overlay.of(Get.overlayContext!);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        color: Styles.ink.withValues(alpha: .04),
        child: Center(
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Styles.surface,
              border: Border.all(
                color: Styles.divider,
                width: Styles.dividerWidth,
              ),
              borderRadius: BorderRadius.circular(Styles.radiusMedium),
            ),
            child: const SpinKitCircle(
              color: Styles.primary,
              size: 36,
            ),
          ),
        ),
      ),
    );
    _isVisible = true;
    _overlayState?.insert(_overlayEntry!);
  }

  dismiss() async {
    if (!_isVisible && !isProgressVisible) return;
    _overlayEntry?.remove();
    _progressOverlayEntry?.remove();
    _isVisible = false;
    isProgressVisible = false;
  }

  void progress(Stream<double> stream) async {
    _progressOverlayState = Overlay.of(Get.overlayContext!);
    _progressOverlayEntry = OverlayEntry(
      builder: (BuildContext context) => GestureDetector(
        onTap: dismiss,
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Styles.ink.withValues(alpha: .12),
          child: Center(
            child: Container(
              alignment: Alignment.center,
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Styles.radiusMedium),
                color: Styles.ink,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(
                    color: Styles.surface,
                    radius: 20,
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder(
                      stream: stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        if (!snapshot.hasData) return Container();
                        final progress = snapshot.data ?? 0.0;
                        return Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Styles.surface,
                            fontSize: 12,
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    isProgressVisible = true;
    _progressOverlayState?.insert(_progressOverlayEntry!);
  }
}
