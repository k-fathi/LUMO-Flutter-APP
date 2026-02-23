import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseFirestoreService {
  FirebaseFirestore? _firestore;

  FirebaseFirestoreService() {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('FirebaseFirestore instance not available: $e');
    }
  }

  // ==================== GENERIC CRUD OPERATIONS ====================

  // Create document
  Future<void> createDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore?.collection(collection).doc(docId).set(data);
  }

  // Read document
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    if (_firestore == null) return null;
    final doc = await _firestore!.collection(collection).doc(docId).get();
    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  // Update document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore?.collection(collection).doc(docId).update(data);
  }

  // Delete document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore?.collection(collection).doc(docId).delete();
  }

  // ==================== QUERY OPERATIONS ====================

  // Get collection
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    Query<Map<String, dynamic>>? Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    if (_firestore == null) return [];
    CollectionReference<Map<String, dynamic>> ref =
        _firestore!.collection(collection);
    Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  // Get collection with where clause
  Future<List<Map<String, dynamic>>> getCollectionWhere({
    required String collection,
    required String field,
    required dynamic value,
    int? limit,
  }) async {
    if (_firestore == null) return [];
    Query<Map<String, dynamic>> query =
        _firestore!.collection(collection).where(field, isEqualTo: value);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  // ==================== STREAM OPERATIONS ====================

  // Stream document
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String docId,
  }) {
    if (_firestore == null) return Stream.value(null);
    return _firestore!.collection(collection).doc(docId).snapshots().map((doc) {
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    });
  }

  // Stream collection
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>>? Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    if (_firestore == null) return Stream.value([]);
    CollectionReference<Map<String, dynamic>> ref =
        _firestore!.collection(collection);
    Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // ==================== BATCH OPERATIONS ====================

  // Batch write
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    if (_firestore == null) return;
    final batch = _firestore!.batch();

    for (var operation in operations) {
      final collection = operation['collection'] as String;
      final docId = operation['docId'] as String;
      final data = operation['data'] as Map<String, dynamic>;
      final type = operation['type'] as String; // 'set', 'update', 'delete'

      final docRef = _firestore!.collection(collection).doc(docId);

      switch (type) {
        case 'set':
          batch.set(docRef, data);
          break;
        case 'update':
          batch.update(docRef, data);
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    }

    await batch.commit();
  }

  // ==================== SUBCOLLECTION OPERATIONS ====================

  // Create subcollection document
  Future<String> createSubcollectionDocument({
    required String collection,
    required String docId,
    required String subcollection,
    required Map<String, dynamic> data,
  }) async {
    if (_firestore == null) return 'mock-id';
    final docRef = await _firestore!
        .collection(collection)
        .doc(docId)
        .collection(subcollection)
        .add(data);
    return docRef.id;
  }

  // Get subcollection
  Future<List<Map<String, dynamic>>> getSubcollection({
    required String collection,
    required String docId,
    required String subcollection,
    Query<Map<String, dynamic>>? Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    if (_firestore == null) return [];
    CollectionReference<Map<String, dynamic>> ref =
        _firestore!.collection(collection).doc(docId).collection(subcollection);

    Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  // Stream subcollection
  Stream<List<Map<String, dynamic>>> streamSubcollection({
    required String collection,
    required String docId,
    required String subcollection,
    Query<Map<String, dynamic>>? Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    if (_firestore == null) return Stream.value([]);
    CollectionReference<Map<String, dynamic>> ref =
        _firestore!.collection(collection).doc(docId).collection(subcollection);

    Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // ==================== TRANSACTION OPERATIONS ====================

  // Run transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    if (_firestore == null) {
      throw FirebaseException(
          plugin: 'firestore', message: 'Firestore not initialized');
    }
    return await _firestore!.runTransaction(transactionHandler);
  }

  // ==================== AGGREGATE OPERATIONS ====================

  // Increment field
  Future<void> incrementField({
    required String collection,
    required String docId,
    required String field,
    num incrementBy = 1,
  }) async {
    await _firestore?.collection(collection).doc(docId).update({
      field: FieldValue.increment(incrementBy),
    });
  }

  // Decrement field
  Future<void> decrementField({
    required String collection,
    required String docId,
    required String field,
    num decrementBy = 1,
  }) async {
    await _firestore?.collection(collection).doc(docId).update({
      field: FieldValue.increment(-decrementBy),
    });
  }

  // Array union (add to array if not exists)
  Future<void> arrayUnion({
    required String collection,
    required String docId,
    required String field,
    required List<dynamic> elements,
  }) async {
    await _firestore?.collection(collection).doc(docId).update({
      field: FieldValue.arrayUnion(elements),
    });
  }

  // Array remove
  Future<void> arrayRemove({
    required String collection,
    required String docId,
    required String field,
    required List<dynamic> elements,
  }) async {
    await _firestore?.collection(collection).doc(docId).update({
      field: FieldValue.arrayRemove(elements),
    });
  }

  // ==================== HELPER METHODS ====================

  // Check if document exists
  Future<bool> documentExists({
    required String collection,
    required String docId,
  }) async {
    if (_firestore == null) return false;
    final doc = await _firestore!.collection(collection).doc(docId).get();
    return doc.exists;
  }

  // Get document count
  Future<int> getCollectionCount({
    required String collection,
    Query<Map<String, dynamic>>? Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    if (_firestore == null) return 0;
    CollectionReference<Map<String, dynamic>> ref =
        _firestore!.collection(collection);
    Query<Map<String, dynamic>> query = queryBuilder?.call(ref) ?? ref;

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  // Get server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  // Get Firestore instance (for advanced queries)
  FirebaseFirestore get instance => _firestore!;
}
