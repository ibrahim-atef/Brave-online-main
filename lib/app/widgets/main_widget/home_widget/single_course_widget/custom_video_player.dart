import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webinar/app/models/content_model.dart';
import 'package:webinar/app/models/note_model.dart';
import 'package:webinar/app/models/single_content_model.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/pdf_viewer_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/personal_note_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:html/parser.dart';
import 'package:webinar/locator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../../common/utils/date_formater.dart';
import '../../../../../../config/assets.dart';

import '../../../../widgets/main_widget/home_widget/single_course_widget/course_video_player.dart';

import 'full_screen_video_page.dart';

class PodVideoPlayerDev extends StatefulWidget {
  final String type;
  final String url;
  final String name;
  final RouteObserver<ModalRoute<void>> routeObserver;

  const PodVideoPlayerDev(
    this.url,
    this.type,
    this.routeObserver, {
    super.key,
    required this.name,
  });

  /// Clear saved position for a specific video
  static Future<void> clearSavedPosition(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        await prefs.remove('video_position_$videoId');
        log('Cleared saved position for video: $videoId');
      }
    } catch (e) {
      log('Error clearing saved position: $e');
    }
  }

  /// Clear all saved video positions
  static Future<void> clearAllSavedPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final videoPositionKeys =
          keys.where((key) => key.startsWith('video_position_'));

      for (final key in videoPositionKeys) {
        await prefs.remove(key);
      }

      log('Cleared all saved video positions');
    } catch (e) {
      log('Error clearing all saved positions: $e');
    }
  }

  /// Get saved position for a specific video
  static Future<Duration?> getSavedPosition(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        final int? savedSeconds = prefs.getInt('video_position_$videoId');
        if (savedSeconds != null) {
          return Duration(seconds: savedSeconds);
        }
      }
      return null;
    } catch (e) {
      log('Error getting saved position: $e');
      return null;
    }
  }

  @override
  State<PodVideoPlayerDev> createState() => _PodVideoPlayerDevState();
}

class _PodVideoPlayerDevState extends State<PodVideoPlayerDev> {
  bool _isFullScreen = false;
  final double _watermarkPositionX = 0.0;
  final double _watermarkPositionY = 0.0;
  Timer? _timer;
  YoutubePlayerController? _controller;
  YoutubePlayerController? _fullscreenController;
  bool _disposed = false;
  bool _isLoading = true;
  bool _isInitialized = false;
  Duration _savedPosition = Duration.zero;
  Timer? _positionSaveTimer;

  @override
  void initState() {
    super.initState();

    // Load saved position first
    _loadSavedPosition().then((_) {
      _initializeVideoPlayer();
    });

    // Force portrait orientation
    _setPortraitOrientation();
  }

  /// Load saved video position from SharedPreferences
  Future<void> _loadSavedPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? videoId = YoutubePlayer.convertUrlToId(widget.url);
      if (videoId != null) {
        final int? savedSeconds = prefs.getInt('video_position_$videoId');
        if (savedSeconds != null) {
          _savedPosition = Duration(seconds: savedSeconds);
          log('Loaded saved position: $_savedPosition for video: $videoId');
        }
      }
    } catch (e) {
      log('Error loading saved position: $e');
    }
  }

  /// Save current video position to SharedPreferences
  Future<void> _saveCurrentPosition() async {
    if (_controller == null || !_controller!.value.isReady) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? videoId = YoutubePlayer.convertUrlToId(widget.url);
      if (videoId != null) {
        final int currentSeconds = _controller!.value.position.inSeconds;
        await prefs.setInt('video_position_$videoId', currentSeconds);
        log('Saved position: ${_controller!.value.position} for video: $videoId');
      }
    } catch (e) {
      log('Error saving position: $e');
    }
  }

  /// Initialize video player with proper error handling
  void _initializeVideoPlayer() {
    // Safely extract the YouTube video ID
    final String? videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (videoId == null || videoId.isEmpty) {
      log("Warning: Invalid or no video ID found in URL: ${widget.url}");
      setState(() {
        _isLoading = false;
        _isInitialized = false;
      });
      return;
    }

    try {
      // Initialize controllers
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          isLive: false,
          hideControls: true,
        ),
      );

      _fullscreenController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          isLive: false,
          hideControls: false,
        ),
      );

      // Set up position saving timer (save every 5 seconds)
      _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_mountedSafe && _controller != null && _controller!.value.isReady) {
          _saveCurrentPosition();
        }
      });

      // Listen to controller state changes
      _controller!.addListener(_onControllerStateChanged);
      _fullscreenController!.addListener(_onFullscreenControllerStateChanged);

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });

      log('Video player initialized successfully for video: $videoId');
    } catch (e) {
      log('Error initializing video player: $e');
      setState(() {
        _isLoading = false;
        _isInitialized = false;
      });
    }
  }

  /// Handle controller state changes
  void _onControllerStateChanged() {
    if (_mountedSafe && _controller != null) {
      setState(() {});

      // Save position when video ends
      if (_controller!.value.playerState == PlayerState.ended) {
        _saveCurrentPosition();
      }
    }
  }

  /// Handle fullscreen controller state changes
  void _onFullscreenControllerStateChanged() {
    if (_mountedSafe && _fullscreenController != null) {
      // Sync position back to main controller when fullscreen ends
      if (_fullscreenController!.value.playerState == PlayerState.ended) {
        _saveCurrentPosition();
      }
    }
  }

  /// Ensures the device is fixed to portrait orientation.
  void _setPortraitOrientation() {
    try {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (e) {
      log("Error setting device orientation: $e");
    }
  }

  void _toggleFullScreen() {
    if (_controller == null || _fullscreenController == null) return;
    if (!_mountedSafe) return;

    setState(() {
      _isFullScreen = true;
    });

    final Duration currentPosition = _controller!.value.position;
    final bool wasPlaying = _controller!.value.isPlaying;

    // Pause before fullscreen
    _controller!.pause();

    // Sync position in fullscreen controller
    _fullscreenController!.seekTo(currentPosition);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPage(
          url: widget.url,
          name: widget.name,
          controller: _fullscreenController!,
          initialPosition: currentPosition,
          shouldAutoPlay: wasPlaying,
        ),
      ),
    ).then((_) {
      if (!_mountedSafe) return;
      setState(() {
        _isFullScreen = false;
      });
      _setPortraitOrientation();

      // Resume playback if it was playing
      if (wasPlaying) {
        _controller!.play();
      }
    });
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isReady) return;

    try {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      setState(() {});
    } catch (e) {
      log('Error toggling play/pause: $e');
    }
  }

  void _seekForward() {
    if (_controller == null || !_controller!.value.isReady) return;
    try {
      final currentPosition = _controller!.value.position;
      final newPosition = currentPosition + const Duration(seconds: 10);
      _controller!.seekTo(newPosition);
    } catch (e) {
      log('Error seeking forward: $e');
    }
  }

  void _seekBackward() {
    if (_controller == null || !_controller!.value.isReady) return;
    try {
      final currentPosition = _controller!.value.position;
      final newPosition = currentPosition - const Duration(seconds: 10);
      if (newPosition.inSeconds >= 0) {
        _controller!.seekTo(newPosition);
      }
    } catch (e) {
      log('Error seeking backward: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;

    _controller?.removeListener(_onControllerStateChanged);
    _fullscreenController?.removeListener(_onFullscreenControllerStateChanged);

    _controller?.dispose();
    _controller = null;

    _fullscreenController?.dispose();
    _fullscreenController = null;

    // استعادة إعدادات الـ system UI عند إغلاق الفيديو
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    super.dispose();
  }

  bool get _mountedSafe => mounted && !_disposed;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Video Player or Loading
                if (_isLoading)
                  Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading video...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (!_isInitialized || _controller == null)
                  Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    child: YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.red,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.red,
                        handleColor: Colors.redAccent,
                      ),
                      onReady: () {
                        log('Player is ready.');
                        if (_mountedSafe && _savedPosition > Duration.zero) {
                          // Seek to saved position after a short delay
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_mountedSafe && _controller != null) {
                              _controller!.seekTo(_savedPosition);
                              log('Seeked to saved position: $_savedPosition');
                            }
                          });
                        }
                      },
                      onEnded: (YoutubeMetaData metaData) {
                        log('Player ended.');
                        _saveCurrentPosition();
                      },
                    ),
                  ),

                // Bottom Controls Bar (only show when video is ready)
                if (_isInitialized &&
                    _controller != null &&
                    _controller!.value.isReady)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.black.withOpacity(0.2),
                      child: Row(
                        children: [
                          // Play/Pause Button
                          IconButton(
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          // Seek Backward Button
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _seekBackward,
                          ),
                          // Seek Forward Button
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _seekForward,
                          ),
                          const Spacer(),
                          // Fullscreen button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _toggleFullScreen,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
