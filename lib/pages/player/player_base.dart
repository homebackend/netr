/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../cubit/mixin/camera_view_cubit_mixin.dart';
import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/ssh_cubit.dart';
import '../../cubit/viewer/thumbnail_cubit.dart';
import '../../cubit/viewer/video_player_cubit.dart';
import '../../cubit/viewer/view_state.dart';
import '../../cubit/viewer/viewer_keyboard_cubit.dart';
import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';
import '../../tool.dart';
import 'lib_helper.dart';

abstract class PlayerBase extends StatefulWidget {
  final double maxWidth;
  final double maxHeight;
  final String cameraName;
  final Camera camera;
  final Location location;
  final Credential credential;
  final Camera? archive;
  final List<(Camera, Camera, Location, Credential)> cameras;
  final String playerTitle;
  final String dialogText;
  const PlayerBase(
    this.maxWidth,
    this.maxHeight,
    this.cameraName,
    this.camera,
    this.location,
    this.credential,
    this.cameras,
    this.playerTitle,
    this.dialogText, {
    super.key,
    this.archive,
  });
}

abstract class PlayerBaseState<T extends PlayerBase> extends State<T>
    with WidgetsBindingObserver
    implements LibHelper {
  final TransformationController _controller = TransformationController();
  final FocusNode _keyboardFocusNode = FocusNode();
  bool isInitialized = false;
  bool _controlsVisible = true;
  bool _isStopped = false;
  Timer? _hideTimer;
  bool _urlLoaded = false;
  String? _currentUrl;
  String? _selectedCamera;
  Timer? _countdownTimer;
  int _countDownValue = 10;

  @override
  void initState() {
    super.initState();

    _selectedCamera = "${widget.location.name}/${widget.cameraName}";

    _startHideTimer();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      isInitialized = true;
    });

    initLibHelper(context);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _countdownTimer?.cancel();
    _keyboardFocusNode.dispose();
    _controller.dispose();
    disposeLibHelper();
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

  void _startErrorTimer(BuildContext context) {
    _stopErrorTimer();
    setState(() {
      _countDownValue = 10;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countDownValue <= 1) {
        _stopErrorTimer();
        next(context);
      } else {
        setState(() {
          _countDownValue--;
        });
      }
    });
  }

  void _stopErrorTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
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
        createViewBlocProvider(context, stream),
      ],
      child: Builder(builder: (nestedContext) {
        return MultiBlocListener(
          listeners: [
            BlocListener<ThumbnailCubit, ThumbnailState>(
              listener: (context, state) {
                if (state is ThumbnailGeneratorState &&
                    state.location != null &&
                    state.camera != null) {
                  startThumbnailGeneration(
                      state.camera!.name, state.location!.name);
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
                  toggleFullScreen(context);
                }
              },
            ),
            BlocListener<SshCubit, SshState>(listener: (context, state) {
              if (state.status == SshStatus.portForwarded &&
                  state.localPort != null) {
                emitSshUrl(context, state.localPort!);
              }
            }),
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
              builder: (context, state) => createCameraErrorViewBlocBuilder(
                (context, errState) => Stack(
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
                                child: _playerWidget(context),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  semanticsLabel: 'Loading',
                                ),
                              ),
                      ),
                    ),
                    if (isInitialized) _buildInlineControlsOverlay(context),
                    if (errState is CameraViewErrorState)
                      _showPlayerError(context, errState),
                  ],
                ),
              ),
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

  @protected
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
          open(context, _currentUrl!);
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
        stop(context);
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
      toggleFullScreen(context);
    });
  }

  @override
  @protected
  String get cameraName => widget.cameraName;

  @override
  @protected
  String get locationName => widget.location.name;

  @override
  @protected
  double get maxHeight => widget.maxHeight;

  @override
  @protected
  double get maxWidth => widget.maxWidth;

  @override
  @protected
  String get playerTitle => widget.playerTitle;

  @protected
  Future<void> close(BuildContext context) async {
    quit(context);
    await backButtonCleanup(context);
  }

  @protected
  Future<void> backButtonCleanup(BuildContext context) async {
    await stop(context);
    await unlockScreen();
  }

  @protected
  Future<void> lockScreen() async {
    if (isWebPlatform() || !isLinuxPlatform()) {
      await WakelockPlus.enable();
    }
  }

  @protected
  Future<void> unlockScreen() async {
    if (isWebPlatform() || !isLinuxPlatform()) {
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
        var (original, camera, location, _) = widget.cameras[int.parse(index)];
        setState(() {
          _selectedCamera = "${location.name}/${original.name}";
        });
        updateSelectedCameraAndLocation(context, original, location, false);
      },
      itemBuilder: (BuildContext context) {
        return widget.cameras.indexed.map((pair) {
          var (index, (original, camera, location, credential)) = pair;
          return PopupMenuItem<String>(
            value: index.toString(),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: Text(
                "${location.name}/${original.name}",
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

  Widget _playerWidget(BuildContext context) {
    log('playerWidget ${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.width * 9.0 / 16.0}');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VideoPlayerCubit(),
        ),
        //createViewBlocProvider(context, _player.stream),
      ],
      child: MultiBlocListener(
        listeners: [
          createCameraViewBlocListener(
            (context, state) {
              if (state is! CameraViewErrorState) {
                // If any state comes stop the error countdown timer.
                // Not this can happen if any camera gives a temporary
                // error which resolves itself in some time.
                _stopErrorTimer();
              }
              if (state is CameraViewBufferingState) {
                if (state.bufferingDone || state.bufferingState == 100.0) {
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
                if (_currentUrl != state.url) {
                  log('Opening url: ${state.url} for ${state.locationName}/${state.cameraName}');
                  _selectedCamera = '${state.locationName}/${state.cameraName}';
                  _currentUrl = state.url;
                  open(context, state.url);
                }
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
                if (!['Failed to initialize a decoder for codec']
                    .any((e) => state.error.contains(e))) {
                  _startErrorTimer(context);
                  //close(context);
                }
              } else if (state is CameraViewDoneState) {
                close(context);
              }
            },
          ),
          createViewBlocListener(
            (context, state) {
              if (state is ViewUpdatedState &&
                  !state.isFreshState &&
                  state.selectedCamera != null &&
                  state.selectedLocation != null) {
                updateCamera(context, state);
                context.read<ThumbnailCubit>().generate(
                      location: state.selectedLocation,
                      camera: state.selectedCamera,
                    );
              }
            },
          ),
        ],
        child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
          builder: createVideoWidget,
        ),
      ),
    );
  }

  Widget _showPlayerError(BuildContext context, CameraViewErrorState errState) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
            const SizedBox(height: 16),
            Text(
              '$_selectedCamera has encountered error(s)',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Text(
              errState.error,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Switching to next camera in ${_countDownValue}s...',
              style: const TextStyle(color: Colors.amber, fontSize: 14),
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 36),
                  onPressed: () {
                    _stopErrorTimer();
                    quit(context);
                  },
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.skip_previous,
                      color: Colors.white, size: 40),
                  onPressed: () {
                    _stopErrorTimer();
                    previous(context);
                  },
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.skip_next,
                      color: Colors.white, size: 40),
                  onPressed: () {
                    _stopErrorTimer();
                    next(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  @protected
  void initCamera(BuildContext context) {
    if (isInitialized && !_urlLoaded) {
      _urlLoaded = true;
      log('Calling getStreamUrl');
      getStreamUrl(context);
    }
  }

  @override
  @protected
  void startThumbnailGeneration(String cameraName, String locationName);

  @protected
  void toggleFullScreen(BuildContext context);

  @protected
  void back(BuildContext context);

  @protected
  void quit(BuildContext context);

  @protected
  void next(BuildContext context);

  @protected
  void previous(BuildContext context);

  @override
  @protected
  Future<void> stop(BuildContext context);

  @protected
  void emitSshUrl(BuildContext bc, int port);

  @override
  @protected
  Widget createVideoWidget(BuildContext context, VideoPlayerState state);

  @protected
  void updateSelectedCameraAndLocation(BuildContext context, Camera camera,
      Location location, bool isFreshState);

  @protected
  void getStreamUrl(BuildContext context);

  @protected
  void updateCamera(BuildContext context, ViewUpdatedState state);

  @protected
  BlocProvider createViewBlocProvider(
    BuildContext context,
    CameraPlayerStream playerStream,
  );

  @protected
  BlocListener createViewBlocListener(
    void Function(BuildContext context, ViewState state) listener,
  );

  @protected
  BlocListener createCameraViewBlocListener(
    void Function(BuildContext context, CameraViewState state) listener,
  );

  @protected
  BlocBuilder createCameraErrorViewBlocBuilder(
    Widget Function(BuildContext context, CameraViewState state) builder,
  );
}
