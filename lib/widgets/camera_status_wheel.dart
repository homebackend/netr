/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/viewer/ssh_cubit.dart';

class SshStatusProgressWheel extends StatelessWidget {
  const SshStatusProgressWheel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SshCubit, SshState>(
      builder: (context, state) {
        if (state.status == SshStatus.initial) {
          return const SizedBox.shrink();
        }

        final String statusLabel = _getStatusMessage(state);
        final Color themeColor = _getStatusColor(state);
        final bool showLoadingIndicator = _shouldSpin(state.status);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: showLoadingIndicator ? null : 1.0,
                      strokeWidth: 6.0,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      backgroundColor: themeColor.withValues(alpha: 0.15),
                    ),
                  ),
                  Icon(
                    _getStatusIcon(state.status),
                    size: 36,
                    color: themeColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                statusLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: themeColor,
                ),
              ),
              if (state.status == SshStatus.portForwarded &&
                  state.localPort != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Local Proxy Routing Active on Port: ${state.localPort}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  String _getStatusMessage(SshState state) {
    switch (state.status) {
      case SshStatus.sshConnecting:
        return 'Authenticating Master SSH Tunnel with ${state.locationName ?? "Server"}...';
      case SshStatus.sshConnected:
        return state.isReusedConnection
            ? 'Validated Existing Master Tunnel Connection Cache!'
            : 'New SSH Gateway Authentication Handshake Success!';
      case SshStatus.forwardingPort:
        return 'Requesting Dynamic Local Sockets Allocation Ports...';
      case SshStatus.portForwarded:
        return 'Tunnel Connected & Streaming Live Media Feeds!';
      case SshStatus.noSshConnectionConfigured:
        return 'Error: Unregistered Location Environment Pointer.';
      case SshStatus.failure:
        return state.errorMessage ??
            'Network Pipeline Tunnel Dropped Exception.';
      default:
        return 'System Initializing...';
    }
  }

  Color _getStatusColor(SshState state) {
    switch (state.status) {
      case SshStatus.sshConnecting:
      case SshStatus.forwardingPort:
        return const Color(0xFF4A3E7D);
      case SshStatus.sshConnected:
        return Colors.indigo;
      case SshStatus.portForwarded:
        return Colors.green.shade600;
      case SshStatus.noSshConnectionConfigured:
      case SshStatus.failure:
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  bool _shouldSpin(SshStatus status) {
    return status == SshStatus.sshConnecting ||
        status == SshStatus.forwardingPort;
  }

  IconData _getStatusIcon(SshStatus status) {
    switch (status) {
      case SshStatus.sshConnecting:
        return Icons.vpn_lock_outlined;
      case SshStatus.sshConnected:
        return Icons.verified_user_outlined;
      case SshStatus.forwardingPort:
        return Icons.router_outlined;
      case SshStatus.portForwarded:
        return Icons.videocam_outlined;
      case SshStatus.noSshConnectionConfigured:
        return Icons.wrong_location_outlined;
      case SshStatus.failure:
        return Icons.gpp_bad_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }
}
