import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FullScreenVideoPage extends StatefulWidget {
  final String url;
  final String name;
  final YoutubePlayerController controller;
  final Duration initialPosition;
  final bool shouldAutoPlay;

  const FullScreenVideoPage({
    Key? key,
    required this.url,
    required this.name,
    required this.controller,
    required this.initialPosition,
    required this.shouldAutoPlay,
  }) : super(key: key);

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  bool _disposed = false;
  Timer? _positionSaveTimer;

  @override
  void initState() {
    super.initState();

    // Force landscape orientation + immersive mode for fullscreen
    _setLandscapeOrientation();

    // Set up position saving timer (save every 5 seconds)
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_mountedSafe && widget.controller.value.isReady) {
        _saveCurrentPosition();
      }
    });

    // Use a post-frame callback to ensure the widget's build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mountedSafe) return;
      if (widget.controller.value.isReady) {
        widget.controller.seekTo(widget.initialPosition);

        // Auto-play if it was playing before
        if (widget.shouldAutoPlay) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_mountedSafe) {
              widget.controller.play();
            }
          });
        }
      }
    });
  }

  bool get _mountedSafe => mounted && !_disposed;

  /// Save current video position to SharedPreferences
  Future<void> _saveCurrentPosition() async {
    if (!widget.controller.value.isReady) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? videoId = YoutubePlayer.convertUrlToId(widget.url);
      if (videoId != null) {
        final int currentSeconds = widget.controller.value.position.inSeconds;
        await prefs.setInt('video_position_$videoId', currentSeconds);
        log('Fullscreen: Saved position: ${widget.controller.value.position} for video: $videoId');
      }
    } catch (e) {
      log('Fullscreen: Error saving position: $e');
    }
  }

  /// Ensures the device is set to landscape orientation and immersive mode.
  void _setLandscapeOrientation() {
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (e) {
      log('Error setting landscape orientation: $e');
    }
  }

  /// Resets UI mode and orientation when leaving.
  void _resetOrientation() {
    try {
      // Save position before leaving
      _saveCurrentPosition();
      
      // Restore standard UI mode and portrait orientation
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (e) {
      log('Error resetting orientation: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;
    
    // Save final position before disposing
    _saveCurrentPosition();
    
    // Do NOT dispose the controller here; it is passed from PodVideoPlayerDev
    // Also do not force portrait orientation here; let the page popping handle it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _resetOrientation();
        return true; // proceed with the pop
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Video Player
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: YoutubePlayer(
                    controller: widget.controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.red,
                    progressColors: const ProgressBarColors(
                      playedColor: Colors.red,
                      handleColor: Colors.redAccent,
                    ),
                    onReady: () {
                      if (_mountedSafe) {
                        // Ensure correct position
                        widget.controller.seekTo(widget.initialPosition);

                        if (widget.shouldAutoPlay) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_mountedSafe) {
                              widget.controller.play();
                            }
                          });
                        }
                      }
                    },
                    onEnded: (YoutubeMetaData metaData) {
                      // Save position when video ends
                      _saveCurrentPosition();
                    },
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      _resetOrientation();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
