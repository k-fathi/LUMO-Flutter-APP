import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  FirebaseStorage? _storage;

  FirebaseStorageService() {
    try {
      _storage = FirebaseStorage.instance;
    } catch (e) {
      debugPrint('FirebaseStorage instance not available: $e');
    }
  }

  // Upload file from path
  Future<String> uploadFile({
    required String filePath,
    required String storagePath,
    Function(double)? onProgress,
  }) async {
    if (_storage == null) return 'mock-url';
    final file = File(filePath);
    final fileName = path.basename(filePath);
    final ref = _storage!.ref().child('$storagePath/$fileName');

    final uploadTask = ref.putFile(file);

    // Listen to upload progress
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    await uploadTask;
    return await ref.getDownloadURL();
  }

  // Upload bytes (for web or in-memory data)
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String storagePath,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    if (_storage == null) return 'mock-url';
    final ref = _storage!.ref().child('$storagePath/$fileName');

    final uploadTask = ref.putData(bytes);

    // Listen to upload progress
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    await uploadTask;
    return await ref.getDownloadURL();
  }

  // Upload image with compression metadata
  Future<String> uploadImage({
    required String filePath,
    required String storagePath,
    Function(double)? onProgress,
  }) async {
    if (_storage == null) return 'mock-url';
    final file = File(filePath);
    final fileName = path.basename(filePath);
    final ref = _storage!.ref().child('$storagePath/$fileName');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'uploadedBy': 'lumo-ai'},
    );

    final uploadTask = ref.putFile(file, metadata);

    // Listen to upload progress
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    await uploadTask;
    return await ref.getDownloadURL();
  }

  // Delete file
  Future<void> deleteFile(String downloadUrl) async {
    if (_storage == null) return;
    try {
      final ref = _storage!.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // File might not exist, ignore error
    }
  }

  // Delete folder
  Future<void> deleteFolder(String folderPath) async {
    if (_storage == null) return;
    try {
      final ref = _storage!.ref().child(folderPath);
      final listResult = await ref.listAll();

      // Delete all files in folder
      for (var item in listResult.items) {
        await item.delete();
      }

      // Recursively delete subfolders
      for (var prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }
    } catch (e) {
      // Folder might not exist, ignore error
    }
  }

  // Get download URL
  Future<String> getDownloadUrl(String storagePath) async {
    if (_storage == null) return 'mock-url';
    final ref = _storage!.ref().child(storagePath);
    return await ref.getDownloadURL();
  }

  // Get file metadata
  Future<FullMetadata?> getMetadata(String storagePath) async {
    if (_storage == null) return null;
    final ref = _storage!.ref().child(storagePath);
    return await ref.getMetadata();
  }

  // List files in folder
  Future<List<String>> listFiles(String folderPath) async {
    if (_storage == null) return [];
    final ref = _storage!.ref().child(folderPath);
    final listResult = await ref.listAll();

    final downloadUrls = <String>[];
    for (var item in listResult.items) {
      final url = await item.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  // ==================== SPECIALIZED UPLOAD METHODS ====================

  // Upload user avatar
  Future<String> uploadUserAvatar({
    required String userId,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      filePath: filePath,
      storagePath: 'users/$userId/avatar',
      onProgress: onProgress,
    );
  }

  // Upload post image
  Future<String> uploadPostImage({
    required String userId,
    required String postId,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      filePath: filePath,
      storagePath: 'posts/$userId/$postId',
      onProgress: onProgress,
    );
  }

  // Upload chat image
  Future<String> uploadChatImage({
    required String chatRoomId,
    required String messageId,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      filePath: filePath,
      storagePath: 'chats/$chatRoomId/$messageId',
      onProgress: onProgress,
    );
  }

  // Upload analysis document
  Future<String> uploadAnalysisDocument({
    required String doctorId,
    required String patientId,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    return await uploadFile(
      filePath: filePath,
      storagePath: 'analysis/$doctorId/$patientId',
      onProgress: onProgress,
    );
  }

  // Get storage reference
  Reference getReference(String path) {
    if (_storage == null) {
      throw FirebaseException(
          plugin: 'storage', message: 'Storage not initialized');
    }
    return _storage!.ref().child(path);
  }

  // Get storage instance (for advanced operations)
  FirebaseStorage get instance => _storage!;
}
