import '../../models/document_model.dart';

enum CloudSyncStatus {
  idle,
  syncing,
  success,
  error,
  notAuthenticated,
}

enum CloudServiceType {
  googleDrive,
  oneDrive,
  dropbox,
  iCloud,
  webdav,
  custom,
}

class CloudDocument {
  final String id;
  final String name;
  final DateTime modifiedAt;
  final int sizeInBytes;
  final CloudServiceType serviceType;
  final String? path;
  final Map<String, dynamic> metadata;

  const CloudDocument({
    required this.id,
    required this.name,
    required this.modifiedAt,
    required this.sizeInBytes,
    required this.serviceType,
    this.path,
    this.metadata = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudDocument &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serviceType == other.serviceType;

  @override
  int get hashCode => Object.hash(id, serviceType);
}

class SyncResult {
  final bool success;
  final String? errorMessage;
  final int documentsSynced;
  final int documentsFailed;
  final List<String> syncedDocumentIds;
  final List<String> failedDocumentIds;
  final DateTime syncTime;

  const SyncResult({
    this.success = true,
    this.errorMessage,
    this.documentsSynced = 0,
    this.documentsFailed = 0,
    this.syncedDocumentIds = const [],
    this.failedDocumentIds = const [],
    DateTime? syncTime,
  }) : syncTime = syncTime ?? DateTime.now();

  static const empty = SyncResult();
}

abstract class CloudSyncService {
  CloudServiceType get serviceType;
  String get serviceName;
  CloudSyncStatus get status;

  bool get isAuthenticated;

  Stream<CloudSyncStatus> get statusStream;

  Future<bool> authenticate(Map<String, dynamic> credentials);

  Future<void> signOut();

  Future<String> uploadDocument(DocumentData document);

  Future<DocumentData?> downloadDocument(String cloudDocumentId);

  Future<List<CloudDocument>> listCloudDocuments({String? path});

  Future<SyncResult> syncAll({
    required List<DocumentData> localDocuments,
    required Future<DocumentData?> Function(String documentId) getLocalDocument,
    required Future<void> Function(DocumentData document) saveLocalDocument,
    SyncDirection direction = SyncDirection.bidirectional,
  });

  Future<bool> deleteCloudDocument(String cloudDocumentId);

  Future<bool> checkConnection();

  void dispose();
}

enum SyncDirection {
  uploadOnly,
  downloadOnly,
  bidirectional,
}

class SyncConflictResolver {
  static SyncResolution resolve(
    DocumentData localVersion,
    CloudDocument cloudVersion,
    DateTime? lastSyncTime,
  ) {
    final localModified = localVersion.modifiedAt;
    final cloudModified = cloudVersion.modifiedAt;

    if (lastSyncTime == null) {
      if (cloudModified.isAfter(localModified)) {
        return SyncResolution.useCloud;
      }
      return SyncResolution.useLocal;
    }

    final localChanged = localModified.isAfter(lastSyncTime);
    final cloudChanged = cloudModified.isAfter(lastSyncTime);

    if (localChanged && !cloudChanged) {
      return SyncResolution.useLocal;
    } else if (!localChanged && cloudChanged) {
      return SyncResolution.useCloud;
    } else if (localChanged && cloudChanged) {
      return SyncResolution.conflict;
    }

    return SyncResolution.noChange;
  }
}

enum SyncResolution {
  useLocal,
  useCloud,
  conflict,
  noChange,
}
