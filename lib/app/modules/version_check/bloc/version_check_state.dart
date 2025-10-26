import 'package:equatable/equatable.dart';
import 'package:otogapo/models/app_version_config.dart';

/// Base state class for version checking.
abstract class VersionCheckState extends Equatable {
  const VersionCheckState();

  @override
  List<Object?> get props => [];
}

/// Initial state before version check.
class VersionCheckInitial extends VersionCheckState {
  const VersionCheckInitial();
}

/// Loading state while fetching version config.
class VersionCheckLoading extends VersionCheckState {
  const VersionCheckLoading();
}

/// State when app is up to date.
class VersionCheckUpToDate extends VersionCheckState {
  const VersionCheckUpToDate();
}

/// State when an update is available.
class VersionCheckUpdateAvailable extends VersionCheckState {
  /// Creates a [VersionCheckUpdateAvailable] state.
  const VersionCheckUpdateAvailable({
    required this.config,
    required this.isForced,
  });

  /// The version configuration from PocketBase.
  final AppVersionConfig config;

  /// Whether this is a forced update.
  final bool isForced;

  @override
  List<Object?> get props => [config, isForced];
}

/// Error state when version check fails.
class VersionCheckError extends VersionCheckState {
  /// Creates a [VersionCheckError] state.
  const VersionCheckError({required this.message});

  /// Error message.
  final String message;

  @override
  List<Object?> get props => [message];
}
