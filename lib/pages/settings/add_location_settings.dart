/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/settings/add_location_cubit.dart';
import '../../cubit/settings/add_locations_cubit.dart';
import '../../mixin/add_location_form_validator.dart';
import '../../mixin/common_form_validator.dart';
import '../../mixin/fields_common.dart';
import '../../mixin/settings_common.dart';
import '../../models/location.dart';
import '../../tool.dart';

class AddLocationSettings extends StatefulWidget
    with
        CommonFormValidator,
        AddLocationFormValidator,
        FieldsCommon,
        SettingsCommon {
  AddLocationSettings({super.key});

  @override
  State<AddLocationSettings> createState() => _AddLocationSettingsState();
}

class _AddLocationSettingsState extends State<AddLocationSettings> {
  final _formKey = GlobalKey<FormState>();
  final Location _location = Location('');
  final _nameController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _addressController = TextEditingController();
  final _sshHostController = TextEditingController();
  final _sshPortController = TextEditingController();
  final _sshUserController = TextEditingController();
  final _sshKeyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _addressController.dispose();
    _sshHostController.dispose();
    _sshPortController.dispose();
    _sshUserController.dispose();
    _sshKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder<AddLocationsCubit, AddLocationCubit, AddLocationState,
        Location>(
      'Location',
      context,
      _formKey,
      _location,
      AddLocationCubit(),
      _form,
      _getSubTitle,
    );
  }

  Widget _form(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    return BlocListener<AddLocationCubit, AddLocationState>(
      listenWhen: (previous, current) => previous.index != current.index,
      listener: (context, state) {
        _nameController.text = state.name;
        _longitudeController.text = state.longitude;
        _latitudeController.text = state.latitude;
        _addressController.text = state.address;
        _sshHostController.text = state.sshHost;
        _sshPortController.text = state.sshPort;
        _sshUserController.text = state.sshUser;
      },
      child: BlocListener<AddLocationCubit, AddLocationState>(
        listenWhen: (previous, current) => previous.index != current.index,
        listener: (context, state) {
          if (state.useSshForNonLocal) {
            _sshHostController.text = state.sshHost;
            _sshPortController.text = state.sshPort;
            _sshUserController.text = state.sshUser;
            _sshKeyController.text = state.sshPrivateKey;
          } else {
            _sshHostController.clear();
            _sshPortController.clear();
            _sshUserController.clear();
            _sshKeyController.clear();
          }
        },
        child: BlocBuilder<AddLocationCubit, AddLocationState>(
          builder: (context, state) {
            return Form(
              key: formKey,
              autovalidateMode: state.autovalidateMode,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (value) =>
                        widget.validateName<AddLocationsCubit, Location>(
                            value, context, state.index >= 0),
                    onChanged: context.read<AddLocationCubit>().updateName,
                    onSaved: (value) {
                      _location.name = value!;
                    },
                    decoration: widget.textFieldDecoration(
                      'Location Name',
                      'Location',
                      Icons.title,
                    ),
                  ),
                  widget.verticalSpacing(),
                  TextFormField(
                    controller: _longitudeController,
                    validator: widget.validateLongitude,
                    onChanged: context.read<AddLocationCubit>().updateLongitude,
                    onSaved: (value) {
                      if (value != null && value.isNotEmpty) {
                        _location.longitude = double.parse(value);
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'(^-?\d*\.?\d*)')),
                    ],
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: widget.textFieldDecoration(
                      'Longitude',
                      'Longitude',
                      Icons.location_on,
                    ),
                  ),
                  widget.verticalSpacing(),
                  TextFormField(
                    controller: _latitudeController,
                    validator: widget.validateLatitude,
                    onSaved: (value) {
                      if (value != null && value.isNotEmpty) {
                        _location.latitude = double.parse(value);
                      }
                    },
                    onChanged: context.read<AddLocationCubit>().updateLatitude,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'(^-?\d*\.?\d*)')),
                    ],
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: widget.textFieldDecoration(
                      'Latitude',
                      'Latitude',
                      Icons.location_on,
                    ),
                  ),
                  widget.verticalSpacing(),
                  _searchLocation(context, state),
                  widget.verticalSpacing(),
                  _allowedDistanceError(_location, context, state),
                  widget.verticalSpacing(),
                  _sshConfiguration(_location, context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _searchLocation(
    BuildContext context,
    AddLocationState state,
  ) {
    if (!isMobilePlatform()) {
      return Container();
    }

    List<Widget> rows = [];
    rows.add(
      Row(
        children: [
          Switch(
            value: state.locationFromAddress,
            onChanged: (value) {
              context.read<AddLocationCubit>().updateLocationFromAddress(value);
            },
          ),
          widget.horizontalSpacing(),
          Text('Get location from given address'),
        ],
      ),
    );

    if (state.locationFromAddress) {
      rows.add(widget.verticalSpacing());
      rows.add(Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _addressController,
              onChanged: context.read<AddLocationCubit>().updateAddress,
              decoration: widget.textFieldDecoration(
                'Address',
                'Street, locality, country',
                Icons.location_on,
              ),
            ),
          ),
          widget.horizontalSpacing(),
          state.fetchingLocationFromAddress
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: state.address.isNotEmpty
                      ? () {
                          context.read<AddLocationCubit>().updateLocation();
                        }
                      : null,
                  child: Text('Search'),
                ),
        ],
      ));
      if (state.locationFromAddressError.isNotEmpty) {
        rows.add(widget.verticalSpacing());
        rows.add(Text(
          state.locationFromAddressError,
          style: TextStyle(
            color: Colors.red,
          ),
        ));
      }
    }

    return Column(
      children: rows,
    );
  }

  Widget _allowedDistanceError(
    Location location,
    BuildContext context,
    AddLocationState state,
  ) {
    location.distance = state.distance;
    return Row(
      children: [
        Text('Allowed distance correction'),
        Expanded(
          child: Slider(
            value: state.distance.index.toDouble() + 1,
            min: 1,
            max: LocationDistance.values.length.toDouble(),
            divisions: LocationDistance.values.length - 1,
            label: state.distance.name,
            onChanged: (double value) {
              log('value = $value');
              context.read<AddLocationCubit>().updateDistance(value);
            },
          ),
        ),
        widget.horizontalSpacing(),
        Text(state.distance.name)
      ],
    );
  }

  Widget _sshConfiguration(
    Location location,
    BuildContext context,
    AddLocationState state,
  ) {
    List<Widget> rows = [];
    if (_sshKeyController.text != state.sshPrivateKey) {
      _sshKeyController.value = TextEditingValue(
        text: state.sshPrivateKey,
        selection: TextSelection.collapsed(offset: state.sshPrivateKey.length),
      );
    }

    rows.add(
      Row(
        children: [
          Switch(
            value: state.useSshForNonLocal,
            onChanged: (value) {
              context.read<AddLocationCubit>().updateUseSshForNonLocal(value);
            },
          ),
          widget.horizontalSpacing(),
          const Text('Use SSH when not on local network')
        ],
      ),
    );

    if (state.useSshForNonLocal) {
      rows.addAll([
        widget.verticalSpacing(),
        TextFormField(
          controller: _sshHostController,
          validator: widget.validateHost,
          onChanged: context.read<AddLocationCubit>().updateSshHost,
          onSaved: (value) {
            location.sshHost = value!;
          },
          decoration: widget.textFieldDecoration(
            'SSH Host',
            'Host or IP address',
            Icons.computer,
          ),
        ),
        widget.verticalSpacing(),
        TextFormField(
          controller: _sshPortController,
          validator: widget.validatePort,
          onChanged: context.read<AddLocationCubit>().updateSshPort,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: const TextInputType.numberWithOptions(),
          onSaved: (value) {
            if (value != null && value.isNotEmpty) {
              location.sshPort = int.parse(value);
            }
          },
          decoration: widget.textFieldDecoration(
            'SSH Port',
            'Port for e.g. 22',
            Icons.power_input,
          ),
        ),
        widget.verticalSpacing(),
        TextFormField(
          controller: _sshUserController,
          validator: widget.validateSshUser,
          onChanged: context.read<AddLocationCubit>().updateSshUser,
          onSaved: (value) {
            location.sshUser = value!;
          },
          decoration: widget.textFieldDecoration(
            'SSH User',
            'SSH User name',
            Icons.person,
          ),
        ),
        widget.verticalSpacing(),
        TextFormField(
          controller: _sshKeyController,
          maxLines: 6,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          onChanged: context.read<AddLocationCubit>().updateSshPrivateKey,
          onSaved: (value) {
            location.sshPrivateKey = value ?? '';
          },
          decoration: InputDecoration(
            labelText: 'SSH Private Key',
            hintText:
                'Paste your private key text here or pick a file below...',
            alignLabelWithHint: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Icon(Icons.vpn_key),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
        widget.verticalSpacing(),
        ElevatedButton(
          onPressed: () {
            context.read<AddLocationCubit>().addSshPrivateKey();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.file_open),
              widget.horizontalSpacing(),
              Text(
                state.sshPrivateKey.isEmpty
                    ? 'Import Key from File'
                    : 'Change Key File',
              ),
            ],
          ),
        ),
      ]);

      if (state.sshHost.isNotEmpty &&
          state.sshPort.isNotEmpty &&
          state.sshUser.isNotEmpty &&
          state.sshPrivateKey.isNotEmpty) {
        rows.add(widget.verticalSpacing());
        if (state.testingSshConnection) {
          rows.add(
            const Center(child: CircularProgressIndicator()),
          ); // Centered to fix layout crash
        } else {
          List<Widget> children = [
            const Icon(Icons.private_connectivity),
            widget.horizontalSpacing(),
            const Text('Test Connection'),
          ];

          switch (state.sshConnectionStatus) {
            case SshConnectionStatus.untested:
              break;
            case SshConnectionStatus.successful:
              children.addAll([
                widget.horizontalSpacing(),
                const Icon(
                  Icons.check_box,
                  color: Colors.green,
                ),
              ]);
              break;
            case SshConnectionStatus.failed:
              children.addAll([
                widget.horizontalSpacing(),
                const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ]);
              break;
          }

          rows.add(
            ElevatedButton(
              onPressed: () {
                context.read<AddLocationCubit>().testSshConnection();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
          );
        }
      }
    }

    return Column(
      children: rows,
    );
  }

  List<Widget> _getSubTitle(Location location) {
    return [
      Icon(
        Icons.location_on,
        color: location.latitude > 0 && location.longitude > 0
            ? Colors.green
            : Colors.red,
      ),
      widget.horizontalSpacing(),
      Text('within ${location.distance.name}'),
      widget.horizontalSpacing(size: 16.0),
      Text(
        'SSH:',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      widget.horizontalSpacing(),
      location.useSshForNonLocal &&
              location.sshHost!.isNotEmpty &&
              location.sshPort! > 0 &&
              location.sshUser!.isNotEmpty &&
              location.sshPrivateKey!.isNotEmpty
          ? Icon(
              Icons.thumb_up,
              color: Colors.green,
            )
          : Icon(
              Icons.thumb_down,
              color: Colors.red,
            )
    ];
  }
}
