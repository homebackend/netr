/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../cubit/viewer/camera_view_cubit.dart';
import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/thumbnail_cubit.dart';
import '../../cubit/viewer/video_player_cubit.dart';
import '../../cubit/viewer/view_cubit.dart';
import '../../cubit/viewer/view_state.dart';
import '../../cubit/viewer/viewer_keyboard_cubit.dart';
import '../../helpers/thumbnail_manager.dart';
import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';
import '../../tool.dart';

class PlayerBase<C extends ViewCubit, CC extends CameraViewCubit>
    extends StatefulWidget {
  final double maxWidth;
  final double maxHeight;
  final Camera camera;
  final Location location;
  final Credential credential;
  final Camera? archive;
  final List<(Camera, Location, Credential)> cameras;
  final String playerTitle;
  final String dialogText;
  final CameraViewCubit Function(PlayerStream playerStream) creator;
  const PlayerBase(
    this.creator,
    this.maxWidth,
    this.maxHeight,
    this.camera,
    this.location,
    this.credential,
    this.cameras,
    this.playerTitle,
    this.dialogText, {
    super.key,
    this.archive,
  });

  @override
  State<PlayerBase> createState() => _PlayerBaseState<C, CC>();
}

class _PlayerBaseState<C extends ViewCubit, CC extends CameraViewCubit>
    extends State<PlayerBase> with WidgetsBindingObserver {
  final TransformationController _controller = TransformationController();
  late Player _player;
  late VideoController _videoController;
  final FocusNode _keyboardFocusNode = FocusNode();
  bool isInitialized = false;
  bool _controlsVisible = true;
  bool _isStopped = false;
  Timer? _hideTimer;
  String? _currentUrl;
  String? _selectedCamera;

  @override
  void initState() {
    super.initState();

    PlayerConfiguration playerConfiguration = PlayerConfiguration(
      logLevel: MPVLogLevel.info,
      title: widget.playerTitle,
      bufferSize: 1024 * 32,
      osc: true,
    );
    _player = Player(configuration: playerConfiguration);
    _videoController = VideoController(_player);
    _selectedCamera = "${widget.location.name}/${widget.camera.name}";

    _startHideTimer();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      isInitialized = true;
    });

    ThumbnailManager.generateCctvThumbnail(
      _player,
      widget.location.name,
      widget.camera.name,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _keyboardFocusNode.dispose();
    _controller.dispose();
    _player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startHideTimer() {
    _stopHideTimer();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _stopHideTimer() {
    _hideTimer?.cancel();
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _startHideTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ViewerKeyboardCubit(
            _controller.value,
            maxWidth,
            maxHeight,
          ),
        ),
        BlocProvider(create: (_) => ThumbnailCubit()),
      ],
      child: Builder(builder: (nestedContext) {
        return MultiBlocListener(
          listeners: [
            BlocListener<ThumbnailCubit, ThumbnailState>(
              listener: (context, state) {
                if (state is ThumbnailGeneratorState &&
                    state.location != null &&
                    state.camera != null) {
                  ThumbnailManager.generateCctvThumbnail(
                    _player,
                    state.location!.name,
                    state.camera!.name,
                  );
                }
              },
            ),
            BlocListener<ViewerKeyboardCubit, ViewerKeyboardState>(
              listener: (context, state) {
                if (state is ViewerKeyboardTapState) {
                  _onTap();
                } else if (state is ViewerKeyboardControllerState) {
                  _controller.value = Matrix4.copy(state.controllerValue);
                } else if (state is ViewerKeyboardPlayState) {
                  switch (state.playActions) {
                    case PlayActions.playToggle:
                      togglePlay();
                      break;
                    case PlayActions.previous:
                      previous(context);
                      break;
                    case PlayActions.next:
                      next(context);
                      break;
                  }
                } else if (state is ViewerKeyboardBackState) {
                  close(context);
                } else if (state is ViewerKeyboardFullscreenState) {
                  context.read<C>().toggleFullScreen();
                }
              },
            ),
          ],
          child: Focus(
            autofocus: true,
            focusNode: _keyboardFocusNode,
            onKeyEvent: (node, keyEvent) => nestedContext
                    .read<ViewerKeyboardCubit>()
                    .handleKeyPress(keyEvent)
                ? KeyEventResult.handled
                : KeyEventResult.ignored,
            child: BlocBuilder<ViewerKeyboardCubit, ViewerKeyboardState>(
              builder: (context, state) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: ViewerKeyboardCubit.minScale,
                        maxScale: ViewerKeyboardCubit.maxScale,
                        transformationController: _controller,
                        onInteractionEnd: (ScaleEndDetails details) {
                          final cubit = context.read<ViewerKeyboardCubit>();
                          cubit.updateControllerValue(_controller.value);
                          cubit.handleInteractionEnd(details);
                        },
                        child: isInitialized
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _onTap,
                                onSecondaryTap: _onTap,
                                child: playerWidget(context),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  semanticsLabel: 'Loading',
                                ),
                              ),
                      ),
                    ),
                    if (isInitialized) _buildInlineControlsOverlay(context),
                  ],
                );
              },
            ),
          ),
        );
      }),
    );
  }

  void _onTap() {
    _keyboardFocusNode.requestFocus();
    _toggleControls();
  }

  List<Widget> getNavigators(BuildContext context) {
    List<Widget> navigators = <Widget>[];
    navigators.add(_getPlayButton(context));
    navigators.add(_getStopButton(context));
    navigators.add(_getPreviousButton(context));
    navigators.add(_getNextButton(context));
    navigators.add(_getZoomInButton(context));
    navigators.add(_getZoomOutButton(context));
    return navigators;
  }

  Widget _getPlayButton(BuildContext context) {
    return createNavigatorButton(Icons.play_arrow, () async {
      try {
        _startHideTimer();
        if (_isStopped && _currentUrl != null) {
          open(_currentUrl!);
        }
      } on Exception catch (e) {
        showSnackBar(context, 'Error during play: $e');
      }
    });
  }

  Widget _getStopButton(BuildContext context) {
    return createNavigatorButton(Icons.stop, () async {
      try {
        _startHideTimer();
        await _player.stop();
        _isStopped = true;
      } on Exception catch (e) {
        showSnackBar(context, 'Error during stop: $e');
      }
    });
  }

  Widget _getPreviousButton(BuildContext context) {
    return createNavigatorButton(Icons.arrow_back, () {
      _startHideTimer();
      previous(context);
    });
  }

  Widget _getNextButton(BuildContext context) {
    return createNavigatorButton(Icons.arrow_forward, () {
      _startHideTimer();
      next(context);
    });
  }

  Widget _getZoomInButton(BuildContext context) {
    return createNavigatorButton(Icons.zoom_in, () {
      _startHideTimer();
      context.read<ViewerKeyboardCubit>().zoomIn();
    });
  }

  Widget _getZoomOutButton(BuildContext context) {
    return createNavigatorButton(Icons.zoom_out, () {
      _startHideTimer();
      context.read<ViewerKeyboardCubit>().zoomOut();
    });
  }

  Widget _getBackButton(BuildContext context) {
    return createNavigatorButton(Icons.settings_backup_restore, () async {
      _startHideTimer();
      if (_controller.value.isIdentity()) {
        await close(context);
      } else {
        _controller.value = Matrix4.identity();
      }
    });
  }

  Widget _getFullscreenButton(BuildContext context) {
    return createNavigatorButton(Icons.fullscreen, () async {
      _startHideTimer();
      context.read<C>().toggleFullScreen();
    });
  }

  Future<void> close(BuildContext context) async {
    context.read<C>().back();
    await backButtonCleanup(context);
  }

  Future<void> backButtonCleanup(BuildContext context) async {
    await _player.stop();
    await unlockScreen();
  }

  Future<void> togglePlay() async {
    await _player.playOrPause();
  }

  Future<void> open(String url) async {
    await _player.stop();
    await _player.open(Media(url), play: true);
  }

  void next(BuildContext context) {
    context.read<C>().next();
  }

  void previous(BuildContext context) {
    context.read<C>().previous();
  }

  Future<void> lockScreen() async {
    if (kIsWeb || !Platform.isLinux) {
      await WakelockPlus.enable();
    }
  }

  Future<void> unlockScreen() async {
    if (kIsWeb || !Platform.isLinux) {
      await WakelockPlus.disable();
    }
  }

  Widget _getCameraDropUpMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Select Camera",
      constraints: const BoxConstraints(maxHeight: 300, maxWidth: 300),
      position: PopupMenuPosition.over,
      offset: const Offset(0, -120),
      onOpened: () => _stopHideTimer(),
      onCanceled: () => _startHideTimer(),
      onSelected: (String index) async {
        _startHideTimer();
        var (camera, location, _) = widget.cameras[int.parse(index)];
        setState(() {
          _selectedCamera = "${location.name}/${camera.name}";
        });
        context
            .read<C>()
            .updateSelectedCameraAndLocation(camera, location, false);
      },
      itemBuilder: (BuildContext context) {
        return widget.cameras.indexed.map((pair) {
          var (index, (camera, location, credential)) = pair;
          return PopupMenuItem<String>(
            value: index.toString(),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: Text(
                "${location.name}/${camera.name}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              _selectedCamera ?? '',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_drop_up, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineControlsOverlay(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: !_controlsVisible,
          child: Container(
            color: Colors.black45,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Details Label Bar
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.dialogText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _startHideTimer();
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...getNavigators(context),
                        _getBackButton(context),
                        _getFullscreenButton(context),
                        SizedBox(
                          width: 40,
                        ),
                        Text(
                          "Jump to: ",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _getCameraDropUpMenu(context),
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

  Widget playerWidget(BuildContext context) {
    log('${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.width * 9.0 / 16.0}');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VideoPlayerCubit(),
        ),
        BlocProvider(
          create: (context) => widget.creator(_player.stream) as CC,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CC, CameraViewState>(
            listener: (context, state) {
              if (state is CameraViewBufferingState) {
                if (state.bufferingDone) {
                  log('Buffering done');
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                } else {
                  log('Buffering: ${state.bufferingState}%');
                  showSnackBar(context, 'Buffering ${state.bufferingState}%');
                }
              } else if (state is CameraViewPlayingState) {
                if (state.playing) {
                  lockScreen();
                  showSnackBar(context, 'Started playing');
                } else {
                  unlockScreen();
                  showSnackBar(context, 'Stopped playing');
                }
              } else if (state is CameraViewUpdatedState) {
                log('Opening url: ${state.url}');
                _currentUrl = state.url;
                open(state.url);
              } else if (state is CameraViewVideoState) {
                if (state.state.width > 0 && state.state.height > 0) {
                  context.read<VideoPlayerCubit>().updateWidthHeight(
                        state.state.width.toInt(),
                        state.state.height.toInt(),
                      );
                }
              } else if (state is CameraViewErrorState) {
                log('Error during video play: ${state.error}');
                showSnackBar(context, 'Play error: ${state.error}');
                close(context);
              } else if (state is CameraViewDoneState) {
                close(context);
              }
            },
          ),
          BlocListener<C, ViewState>(
            listener: (context, state) {
              if (state is ViewUpdatedState &&
                  !state.isFreshState &&
                  state.selectedCamera != null &&
                  state.selectedLocation != null) {
                context.read<CC>().updateCamera(state);
                context.read<ThumbnailCubit>().generate(
                      location: state.selectedLocation,
                      camera: state.selectedCamera,
                    );
              }
            },
          ),
        ],
        child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
          builder: (context, state) {
            if (state.width > 0 && state.height > 0) {
              return SizedBox(
                width: widget.maxWidth,
                height: widget.maxHeight,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: state.aspectRatio,
                    child: Video(
                      controller: _videoController,
                      controls: null,
                    ),
                  ),
                ),
              );
            } else {
              context.read<CC>().getStreamUrl();
              return SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Waiting for video',
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
