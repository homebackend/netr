/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:netr/cubit/viewer/live_view_cubit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../cubit/viewer/live_camera_view_cubit.dart';
import '../../cubit/viewer/video_player_cubit.dart';
import '../../cubit/viewer/viewer_keyboard_cubit.dart';
import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';
import '../../tool.dart';

class PlayerBase extends StatefulWidget {
  final double maxWidth;
  final double maxHeight;
  final Camera camera;
  final Location location;
  final Credential credential;
  final Camera? archive;
  final String playerTitle;
  final String dialogText;
  const PlayerBase(
    this.maxWidth,
    this.maxHeight,
    this.camera,
    this.location,
    this.credential,
    this.playerTitle,
    this.dialogText, {
    super.key,
    this.archive,
  });

  @override
  State<PlayerBase> createState() => _PlayerBaseState();
}

class _PlayerBaseState extends State<PlayerBase> with WidgetsBindingObserver {
  final TransformationController _controller = TransformationController();
  //late VideoPlayerControllerInterface videoPlayerController;
  late Player _player;
  late VideoController _videoController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    PlayerConfiguration playerConfiguration = PlayerConfiguration(
      logLevel: MPVLogLevel.info,
      title: widget.playerTitle,
      osc: true,
    );
    _player = Player(configuration: playerConfiguration);
    _videoController = VideoController(_player);

    WidgetsBinding.instance.addObserver(this);
    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    //videoPlayerController.removeListener();
    //videoPlayerController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) => ViewerKeyboardCubit(
        _controller.value,
        maxWidth,
        maxHeight,
      ),
      child: BlocListener<ViewerKeyboardCubit, ViewerKeyboardState>(
        listener: (context, state) {
          if (state is ViewerKeyboardTapState) {
            _onTap();
          } else if (state is ViewerKeyboardControllerState) {
            _controller.value = state.controllerValue;
          } else if (state is ViewerKeyboadPlayState) {
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
            close();
          }
        },
        child: BlocBuilder<ViewerKeyboardCubit, ViewerKeyboardState>(
          builder: (context, state) {
            return PopScope(
              canPop: false,
              child: KeyboardListener(
                autofocus: true,
                focusNode: FocusNode(),
                onKeyEvent: (keyEvent) {
                  context.read<ViewerKeyboardCubit>().handleKeyPress(keyEvent);
                },
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: ViewerKeyboardCubit.minScale,
                  maxScale: ViewerKeyboardCubit.maxScale,
                  transformationController: _controller,
                  onInteractionEnd: (ScaleEndDetails details) {
                    context
                        .read<ViewerKeyboardCubit>()
                        .handleInteractionEnd(details);
                  },
                  child: isInitialized
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _onTap,
                          onSecondaryTap: _onTap,
                          child: playerWidget(context),
                        )
                      : CircularProgressIndicator(
                          semanticsLabel: 'Loading',
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onTap() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: 'Camera Selection',
      barrierDismissible: true,
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: 400,
            width: 400,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: _getDialogItems(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getDialogItems() {
    List<Widget> navigators = getNavigators(context);
    navigators.add(getBackButton(context));

    return [
      SizedBox(
        height: 35,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: navigators,
        ),
      ),
      Text(widget.dialogText, style: _getPopupInfoStyle()),
      SizedBox(
        height: 300,
        child: _getSelectionView(),
      ),
    ];
  }

  Widget _getSelectionView() {
    return Placeholder();
  }

  TextStyle _getPopupInfoStyle() {
    return const TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.bold,
      fontSize: 30,
    );
  }

  List<Widget> getNavigators(BuildContext context) {
    List<Widget> navigators = <Widget>[];
    navigators.add(_getPlayButton(context));
    navigators.add(_getStopButton(context));
    navigators.add(_getPreviousButton(context));
    navigators.add(_getNextButton(context));
    return navigators;
  }

  Widget _getPlayButton(context) {
    return createNavigatorButton(Icons.play_arrow, () async {
      Navigator.pop(context);
      try {
        await _player.play();
      } on Exception catch (e) {
        showSnackBar(context, 'Error during play: $e');
      }
    });
  }

  Widget _getStopButton(context) {
    return createNavigatorButton(Icons.stop, () async {
      Navigator.pop(context);
      try {
        await _player.stop();
      } on Exception catch (e) {
        showSnackBar(context, 'Error during stop: $e');
      }
    });
  }

  Widget _getPreviousButton(context) {
    return createNavigatorButton(Icons.arrow_back, () {
      Navigator.pop(context);
      previous(context);
    });
  }

  Widget _getNextButton(context) {
    return createNavigatorButton(Icons.arrow_forward, () {
      Navigator.pop(context);
      next(context);
    });
  }

  Widget getBackButton(context) {
    return createNavigatorButton(Icons.settings_backup_restore, () async {
      Navigator.pop(context);
      await close();
    });
  }

  Future<void> close() async {
    await backButtonCleanup(context);
    //widget.callback(false);
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
    context.read<LiveViewCubit>().next();
  }

  void previous(BuildContext context) {
    context.read<LiveViewCubit>().previous();
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

  Widget playerWidget(BuildContext context) {
    log('${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.width * 9.0 / 16.0}');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VideoPlayerCubit(),
        ),
        BlocProvider(
            create: (context) => LiveCameraViewCubit(
                  _player.stream,
                  widget.camera,
                  widget.location,
                  widget.credential,
                  StreamQuality.high,
                  archive: widget.archive,
                )),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LiveCameraViewCubit, LiveCameraViewState>(
            listener: (context, state) {
              if (state is LiveCameraViewBufferingState) {
                if (state.bufferingDone) {
                  log('Buffering done');
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                } else {
                  log('Buffering: ${state.bufferingState}%');
                  showSnackBar(context, 'Buffering ${state.bufferingState}%');
                }
              } else if (state is LiveCameraViewPlayingState) {
                if (state.playing) {
                  lockScreen();
                  showSnackBar(context, 'Started playing');
                } else {
                  unlockScreen();
                  showSnackBar(context, 'Stopped playing');
                }
              } else if (state is LiveCameraViewUpdatedState) {
                log('Opening url: ${state.url}');
                open(state.url);
              } else if (state is LiveCameraViewVideoState) {
                if (state.width > 0 && state.height > 0) {
                  context
                      .read<VideoPlayerCubit>()
                      .updateWidthHeight(state.width, state.height);
                }
              } else if (state is LiveCameraViewErrorState) {
                log('Error during video play: ${state.error}');
                showSnackBar(context, 'Play error: ${state.error}');
              }
            },
          ),
          BlocListener<LiveViewCubit, LiveViewState>(
            listener: (context, state) {
              if (state is LiveViewUpdatedState && !state.isFreshState) {
                context.read<LiveCameraViewCubit>().updateCamera(
                      state.selectedCamera!,
                      state.selectedLocation!,
                      state.cameraCredential(state.selectedCamera!)!,
                      state.cameraNvr(state.selectedCamera!),
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
              context.read<LiveCameraViewCubit>().getStreamUrl();
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
