import 'package:storage_space/storage_space.dart';

import '../sync/sync_state.dart';

class SyncDownloadSizeState extends SyncState {
  final int totalBytes;

  SyncDownloadSizeState(this.totalBytes);

  @override
  List<Object?> get props => [totalBytes];
}

class SyncDownloadStartState extends SyncState {
  @override
  List<Object?> get props => [];
}

class SyncDownloadErrorState extends SyncState {
  final String message;
  final String time;

  SyncDownloadErrorState(this.message,this.time);

  @override
  List<Object?> get props => [message,time];
}

class SyncDownloadLimitState extends SyncState {
  final StorageSpace storage;
  final int displaySize;

  SyncDownloadLimitState(this.storage ,this.displaySize);

  @override
  List<Object?> get props => [];
}