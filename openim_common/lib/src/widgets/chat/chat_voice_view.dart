import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openim_common/openim_common.dart';

class ChatVoiceView extends StatefulWidget {
  const ChatVoiceView(
      {super.key, required this.message, required this.isISend});

  final Message message;
  final bool isISend;

  @override
  State<ChatVoiceView> createState() => _ChatVoiceViewState();
}

class _ChatVoiceViewState extends State<ChatVoiceView> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _playing =
          state.playing && state.processingState != ProcessingState.completed);
    });
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.stop();
      return;
    }
    try {
      final sound = widget.message.soundElem;
      final url = sound?.sourceUrl;
      final path = sound?.soundPath;
      if (url?.isNotEmpty == true) {
        await _player.setUrl(url!);
      } else if (path?.isNotEmpty == true) {
        await _player.setFilePath(path!);
      } else {
        throw StateError('voice source is empty');
      }
      await _player.play();
    } catch (_) {
      IMViews.showToast('语音播放失败');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.message.soundElem?.duration ?? 0;
    return Material(
      color: widget.isISend ? Styles.primary : Styles.surface,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: (82 + duration.clamp(0, 40) * 2).w,
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _playing ? Icons.stop_rounded : Icons.graphic_eq_rounded,
                size: 22.w,
                color: widget.isISend ? Colors.white : Styles.primary,
              ),
              8.horizontalSpace,
              Text(
                '$duration″',
                style: TextStyle(
                  color: widget.isISend ? Colors.white : Styles.ink,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
