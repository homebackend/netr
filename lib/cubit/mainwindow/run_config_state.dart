/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'run_config_cubit.dart';

enum LocationSource {
  unset,
  userInput,
  gps,
  lastUsed,
}

sealed class RunConfigState {
  final String location;
  final LocationSource locationSource;
  final StreamQuality quality;
  DateTime archiveDate;
  late DateTime archiveFirstDate;
  late DateTime archiveLastDate;

  RunConfigState({
    this.location = '',
    this.locationSource = LocationSource.unset,
    this.quality = StreamQuality.high,
    required this.archiveDate,
  }) {
    _setDates();
  }

  void _setDates() {
    var now = DateTime.now();
    if (archiveDate.isAfter(now) ||
        archiveDate.isBefore(
          now.subtract(
            Duration(
              days: DateUtils.getDaysInMonth(
                now.year,
                now.month,
              ),
            ),
          ),
        )) {
      archiveDate = now;
    }

    archiveFirstDate = DateUtils.dateOnly(
      archiveDate.subtract(
        Duration(
          days: DateUtils.getDaysInMonth(
            archiveDate.year,
            archiveDate.month,
          ),
        ),
      ),
    );
    archiveLastDate = DateUtils.dateOnly(
      DateTime.now().add(Duration(days: 1)),
    );
  }

  RunConfigState copyWith({
    String? location,
    LocationSource? locationSource,
    StreamQuality? quality,
    DateTime? archiveDate,
  });
}

final class RunConfigUpdatedState extends RunConfigState {
  RunConfigUpdatedState({
    super.location,
    super.locationSource,
    super.quality,
    required super.archiveDate,
  });

  @override
  RunConfigUpdatedState copyWith({
    String? location,
    LocationSource? locationSource,
    StreamQuality? quality,
    DateTime? archiveDate,
    DateTime? archiveFirstDate,
    DateTime? archiveLastDate,
  }) {
    return RunConfigUpdatedState(
      location: location ?? this.location,
      locationSource: locationSource ?? this.locationSource,
      quality: quality ?? this.quality,
      archiveDate: archiveDate ?? this.archiveDate,
    );
  }
}
