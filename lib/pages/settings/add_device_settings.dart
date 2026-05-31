/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/settings/add_camera_cubit.dart';
import '../../cubit/settings/add_cameras_cubit.dart';
import '../../cubit/settings/add_credentials_cubit.dart';
import '../../cubit/settings/add_locations_cubit.dart';
import '../../cubit/settings/add_nvrs_cubit.dart';
import '../../mixin/common_form_validator.dart';
import '../../mixin/fields_common.dart';
import '../../mixin/settings_common.dart';
import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';

enum DeviceType {
  camera('Camera'),
  nvr('NVR');

  const DeviceType(this.label);
  final String label;
}

class AddDeviceSettings<T> extends StatefulWidget
    with CommonFormValidator, FieldsCommon, SettingsCommon {
  final DeviceType deviceType;
  AddDeviceSettings(this.deviceType, {super.key});

  @override
  State<AddDeviceSettings> createState() => _AddDeviceSettingsState<T>();
}

class _AddDeviceSettingsState<T> extends State<AddDeviceSettings> {
  final _formKey = GlobalKey<FormState>();
  final _camera = Camera('');
  final _nameController = TextEditingController();
  final _protocolController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _protocolController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.deviceType) {
      case DeviceType.camera:
        return widget
            .builder<AddCamerasCubit, AddCameraCubit, AddCameraState, Camera>(
          widget.deviceType.label,
          context,
          _formKey,
          _camera,
          AddCameraCubit(),
          _form<AddCameraCubit>,
          _getSubTitle,
        );
      case DeviceType.nvr:
        return widget
            .builder<AddNvrsCubit, AddNvrCubit, AddCameraState, Camera>(
          widget.deviceType.label,
          context,
          _formKey,
          _camera,
          AddNvrCubit(),
          _form<AddNvrCubit>,
          _getSubTitle,
        );
    }
  }

  Widget _form<C extends AddCameraCubitBase>(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    return BlocListener<C, AddCameraState>(
      listenWhen: (previous, current) => previous.index != current.index,
      listener: (context, state) {
        _nameController.text = state.name;
        _protocolController.text = state.protocol;
        _hostController.text = state.host;
        _portController.text = state.port;

        _camera.cameraType = state.cameraType;
        _camera.ipLocationNames = state.ipLocationNames;
        _camera.locationName = state.locationName;
        _camera.credentialName = state.credentialName;
        _camera.archiveName = state.archiveName;
      },
      child: BlocBuilder<C, AddCameraState>(
        builder: (context, state) {
          return Form(
            key: formKey,
            autovalidateMode: state.autovalidateMode,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: (value) => widget.deviceType == DeviceType.camera
                      ? widget.validateName<AddCamerasCubit, Camera>(
                          value, context, state.index >= 0)
                      : widget.validateName<AddNvrsCubit, Camera>(
                          value, context, state.index >= 0),
                  onChanged: context.read<C>().updateName,
                  onSaved: (value) {
                    _camera.name = value!;
                  },
                  decoration: widget.textFieldDecoration(
                    '${widget.deviceType.label} Name',
                    'Unique name of ${widget.deviceType.label}',
                    Icons.title,
                  ),
                ),
                widget.verticalSpacing(),
                widget.dropDownMenu<CameraType>(
                  '${widget.deviceType.label} Type',
                  CameraType.values,
                  CameraType.hikvision,
                  (cameraType) => cameraType.label,
                  (cameraType) {
                    _camera.cameraType = cameraType!;
                    context.read<C>().updateCameraType(cameraType);
                  },
                  showEmptyOption: false,
                ),
                widget.verticalSpacing(),
                TextFormField(
                  controller: _hostController,
                  validator: widget.validateHost,
                  onChanged: context.read<C>().updateHost,
                  onSaved: (value) {
                    _camera.host = value!;
                  },
                  decoration: widget.textFieldDecoration(
                    'Host',
                    'Host name',
                    Icons.computer,
                  ),
                ),
                widget.verticalSpacing(),
                TextFormField(
                  controller: _portController,
                  validator: (value) =>
                      widget.validatePort(value, mandatory: true),
                  onChanged: context.read<C>().updatePort,
                  onSaved: (value) {
                    _camera.port = int.parse(value!);
                  },
                  decoration: widget.textFieldDecoration(
                    'Port',
                    '554',
                    Icons.power_input,
                  ),
                ),
                widget.verticalSpacing(),
                widget.verticalSpacing(),
                widget.autoDropDownMenu<AddLocationsCubit, Location>(
                  'Location',
                  state.locationName,
                  (locationName) {
                    _camera.locationName = locationName!;
                    context.read<C>().updateLocationName(locationName);
                  },
                ),
                widget.verticalSpacing(),
                widget.checkboxGroup<AddLocationsCubit, Location>(
                    'Availabile at Locations', state.ipLocationNames,
                    (checked, locationName) {
                  if (checked) {
                    _camera.ipLocationNames.add(locationName);
                    context.read<C>().addIpLocationName(locationName);
                  } else {
                    _camera.ipLocationNames.remove(locationName);
                    context.read<C>().removeIpLocationName(locationName);
                  }
                }),
                widget.verticalSpacing(),
                widget.autoDropDownMenu<AddCredentialsCubit, Credential>(
                    'Credential', state.credentialName, (credentialName) {
                  _camera.credentialName = credentialName!;
                  context.read<C>().updateCredentialName(credentialName);
                }),
                widget.verticalSpacing(),
                widget.deviceType == DeviceType.camera
                    ? widget.autoDropDownMenu<AddNvrsCubit, Camera>(
                        'Archive View NVR',
                        state.archiveName,
                        (archiveName) {
                          _camera.archiveName = archiveName!;
                          context.read<C>().updateArchiveName(archiveName);
                        },
                      )
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getSubTitle(Camera camera) {
    List<Widget> items = [];

    if (widget.deviceType == DeviceType.camera) {
      items.addAll([
        widget.horizontalSpacing(),
        Icon(
          Icons.archive,
          color: camera.archiveName.isEmpty ? Colors.red : Colors.green,
        ),
      ]);
    }

    items.addAll([
      widget.horizontalSpacing(),
      Icon(
        Icons.location_city,
        color: camera.locationName.isEmpty ? Colors.red : Colors.green,
      ),
      widget.horizontalSpacing(),
      Icon(
        Icons.lock,
        color: camera.credentialName.isEmpty ? Colors.red : Colors.green,
      ),
    ]);
    return items;
  }
}
