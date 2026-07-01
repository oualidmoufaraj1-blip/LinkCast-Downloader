import 'dart:io';

import 'package:better_native_video_player/better_native_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_to_airplay/flutter_to_airplay.dart';
import 'package:just_audio/just_audio.dart';

import '../models/download_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';
import '../utils/media_utils.dart';

class SendToTvScreen extends StatefulWidget {
  const SendToTvScreen({super.key, required this.item});

  final DownloadItem item;

  @override
  State<SendToTvScreen> createState() => _SendToTvScreenState();
}

class _SendToTvScreenState extends State<SendToTvScreen> {
  NativeVideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _loading = true;
  String? _error;
  bool _airPlayAvailable = false;
  bool _airPlayConnected = false;
  bool _audioPlaying = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!File(widget.item.filePath).existsSync()) {
      setState(() {
        _loading = false;
        _error = 'File no longer exists on this device.';
      });
      return;
    }

    final kind = MediaUtils.kindForFile(widget.item.fileName);
    try {
      if (kind == MediaKind.video) {
        await _initVideo();
      } else if (kind == MediaKind.audio) {
        await _initAudio();
      } else {
        _error = 'This file type cannot be sent to a TV.';
      }
    } catch (e) {
      _error = 'Could not prepare media for TV: $e';
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _initVideo() async {
    final controller = NativeVideoPlayerController(
      id: widget.item.id.hashCode,
      autoPlay: true,
      showNativeControls: true,
    );

    controller.addAirPlayAvailabilityListener(_onAirPlayAvailability);
    controller.addAirPlayConnectionListener(_onAirPlayConnection);

    await controller.initialize();
    await AirPlayStateManager.instance.init();
    await controller.loadFile(path: widget.item.filePath);

    _videoController = controller;
    _airPlayAvailable = await controller.isAirPlayAvailable();
  }

  Future<void> _initAudio() async {
    final player = AudioPlayer();
    await player.setFilePath(widget.item.filePath);
    player.playingStream.listen((playing) {
      if (mounted) setState(() => _audioPlaying = playing);
    });
    await player.play();
    _audioPlayer = player;
    _airPlayAvailable = true;
  }

  void _onAirPlayAvailability(bool available) {
    if (mounted) setState(() => _airPlayAvailable = available);
  }

  void _onAirPlayConnection(bool connected) {
    if (mounted) setState(() => _airPlayConnected = connected);
  }

  Future<void> _pickAirPlayDevice() async {
    final controller = _videoController;
    if (controller != null) {
      if (await controller.isAirPlayAvailable()) {
        await controller.showAirPlayPicker();
      } else {
        _showNoTvDialog();
      }
      return;
    }

    if (_audioPlayer != null) {
      _showAudioAirPlayHint();
    }
  }

  void _showNoTvDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('No TV Found'),
        content: const Text(
          'Make sure your iPhone and TV are on the same Wi‑Fi network, '
          'and that AirPlay is enabled on your TV or Apple TV.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAudioAirPlayHint() {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Send Audio to TV'),
        content: const Text(
          'Tap the AirPlay icon below to choose your TV or speaker. '
          'Playback will stream to the selected device.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.removeAirPlayAvailabilityListener(_onAirPlayAvailability);
    _videoController?.removeAirPlayConnectionListener(_onAirPlayConnection);
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: palette.navBarBackground,
        border: null,
        middle: Text(
          widget.item.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : _error != null
                ? _ErrorBody(message: _error!)
                : _buildPlayerBody(),
      ),
    );
  }

  Widget _buildPlayerBody() {
    final kind = MediaUtils.kindForFile(widget.item.fileName);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (kind == MediaKind.video && _videoController != null)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: NativeVideoPlayer(controller: _videoController!),
          ),
        if (kind == MediaKind.audio) ...[
          const SizedBox(height: 48),
          Icon(
            CupertinoIcons.music_note_2,
            size: 72,
            color: palette.label,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.item.fileName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: palette.label,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                onPressed: () async {
                  final player = _audioPlayer;
                  if (player == null) return;
                  if (_audioPlaying) {
                    await player.pause();
                  } else {
                    await player.play();
                  }
                },
                child: Icon(
                  _audioPlaying
                      ? CupertinoIcons.pause_circle_fill
                      : CupertinoIcons.play_circle_fill,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (_airPlayConnected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.tv,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Streaming to TV',
                          style: TextStyle(
                            color: palette.label,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (kind == MediaKind.video)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed:
                        _airPlayAvailable ? _pickAirPlayDevice : _showNoTvDialog,
                    child: const Text('Choose TV'),
                  ),
                ),
              if (kind == MediaKind.audio) ...[
                Text(
                  'Select a TV or speaker',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.label,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: AirPlayRoutePickerView(
                    tintColor: palette.label,
                    activeTintColor: AppColors.primary,
                    backgroundColor: CupertinoColors.transparent,
                  ),
                ),
              ],
              if (kind == MediaKind.video) const SizedBox(height: 16),
              if (kind == MediaKind.audio) const SizedBox(height: 16),
              Text(
                kind == MediaKind.video
                    ? 'Use the player controls or tap Choose TV to stream via AirPlay. '
                        'Your iPhone and TV must be on the same Wi‑Fi network.'
                    : 'Use the AirPlay control above to pick Apple TV, HomePod, '
                        'or an AirPlay-compatible speaker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: palette.label.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.label, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
