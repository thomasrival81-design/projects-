import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// PINZX PROJECT intro screen.
/// The progress bar follows the real video position. SKIP routes directly to
/// the dashboard and the completion guard prevents duplicate navigation.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  VideoPlayerController? _video;
  bool _initialized = false;
  bool _navigationStarted = false;
  bool _videoFailed = false;
  double _progress = 0;
  String _status = 'INITIALIZING';
  Timer? _fallbackTimer;
  DateTime? _fallbackStart;

  static const _cyan = Color(0xFF00E5FF);
  static const _blue = Color(0xFF075DFF);

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.asset('assets/videos/pinzx_intro.mp4');
    _video = controller;
    controller.addListener(_onVideoTick);
    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(false);
      await controller.setVolume(0);
      setState(() {
        _initialized = true;
        _status = 'INITIALIZING';
      });
      await controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _videoFailed = true;
        _status = 'INITIALIZING';
      });
      // Graceful fallback if the video cannot be decoded on a device.
      _fallbackStart = DateTime.now();
      _fallbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || _navigationStarted) {
          timer.cancel();
          return;
        }
        final elapsed = DateTime.now().difference(_fallbackStart!).inMilliseconds;
        setState(() => _progress = (elapsed / 8000).clamp(0.0, 1.0).toDouble());
        if (_progress >= 1) _openDashboard();
      });
    }
  }

  void _onVideoTick() {
    final controller = _video;
    if (!mounted || controller == null || !controller.value.isInitialized || _navigationStarted) return;
    final duration = controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    final position = controller.value.position;
    final progress = (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0).toDouble();
    if ((progress - _progress).abs() >= 0.003 || progress >= 1) {
      setState(() => _progress = progress);
    }
    if (controller.value.hasError) {
      setState(() => _status = 'VIDEO ERROR');
    } else if (position >= duration) {
      _openDashboard();
    }
  }

  Future<void> _openDashboard({bool skipped = false}) async {
    if (_navigationStarted || !mounted) return;
    _navigationStarted = true;
    _fallbackTimer?.cancel();
    setState(() {
      _progress = 1;
      _status = 'READY';
    });
    await _video?.pause();
    // Let READY be visible after natural completion; SKIP remains immediate.
    if (!skipped) await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/project-dashboard');
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _video?.removeListener(_onVideoTick);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _video;
    final percent = (_progress * 100).round().clamp(0, 100);
    return Scaffold(
      backgroundColor: const Color(0xFF020716),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized && controller != null)
            ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.4, -0.35),
                  radius: 1.3,
                  colors: [Color(0xFF00AFCB), Color(0xFF064BDB), Color(0xFF020716)],
                ),
              ),
            ),
          // Blue/cyan tint and dark lower fade keep overlay text legible.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x55001560), Color(0x220057FF), Color(0xDD020716)],
                stops: [0, 0.48, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: Color(0xFF20D879), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Text(_status, style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 3.2, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () => _openDashboard(skipped: true),
                        icon: const Icon(Icons.skip_next, size: 20),
                        label: const Text('SKIP', style: TextStyle(letterSpacing: 2)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0x88030C25),
                          side: const BorderSide(color: Color(0xAAFFFFFF), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x99040B1D),
                      border: Border.all(color: const Color(0xAAFFFFFF), width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text('PINZX PROJECT', style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 2.4)),
                  ),
                  const SizedBox(height: 20),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('PINZX', style: TextStyle(color: Colors.white, fontSize: 68, height: 1, fontWeight: FontWeight.w500, letterSpacing: 2.2)),
                  ),
                  const SizedBox(height: 16),
                  const Text('ADVANCED TOOLKIT · V7.5.0', style: TextStyle(color: Color(0xFFB7C4E3), fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('LOADING', style: TextStyle(color: Color(0xFF9EABC8), fontSize: 11, letterSpacing: 3)),
                      Text('$percent%', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 5,
                      color: const Color(0x55000000),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progress.clamp(0.0, 1.0).toDouble(),
                        child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [_cyan, _blue]))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(_videoFailed ? 'VIDEO FALLBACK' : (_progress >= 1 ? 'READY' : 'INITIALIZING'),
                      style: const TextStyle(color: Color(0xFF7B8BAE), fontSize: 12, letterSpacing: 3)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
