import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseService<T> {
  final FirebaseFirestore firestore;
  final String collection;

  BaseService(this.firestore, this.collection);

  // Convert Firestore document to model
  T fromFirestore(DocumentSnapshot doc);

  // Convert model to Firestore document
  Map<String, dynamic> toFirestore(T model);

  // Get a single document by ID
  Future<T?> get(String id) async {
    final doc = await firestore.collection(collection).doc(id).get();
    if (doc.exists) {
      return fromFirestore(doc);
    }
    return null;
  }

  // Create a new document
  Future<T> create(T model) async {
    final docRef = await firestore.collection(collection).add(toFirestore(model));
    final doc = await docRef.get();
    return fromFirestore(doc);
  }

  // Update an existing document
  Future<T> update(String id, T model) async {
    await firestore.collection(collection).doc(id).update(toFirestore(model));
    final doc = await firestore.collection(collection).doc(id).get();
    return fromFirestore(doc);
  }

  // Delete a document
  Future<void> delete(String id) async {
    await firestore.collection(collection).doc(id).delete();
  }

  // List all documents
  Future<List<T>> list() async {
    final querySnapshot = await firestore.collection(collection).get();
    return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
  }

  // Query documents with filters
  Future<List<T>> query({
    String? field,
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
    int? limit,
    DocumentSnapshot? startAfter,
    DocumentSnapshot? endBefore,
  }) async {
    Query query = firestore.collection(collection);

    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isNotEqualTo != null) {
        query = query.where(field, isNotEqualTo: isNotEqualTo);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (isLessThanOrEqualTo != null) {
        query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (isGreaterThanOrEqualTo != null) {
        query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
      }
      if (whereIn != null) {
        query = query.where(field, whereIn: whereIn);
      }
      if (whereNotIn != null) {
        query = query.where(field, whereNotIn: whereNotIn);
      }
      if (isNull != null) {
        query = query.where(field, isNull: isNull);
      }
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    if (endBefore != null) {
      query = query.endBeforeDocument(endBefore);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
  }

  // Stream documents
  Stream<List<T>> stream() {
    return firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList());
  }

  // Stream a single document
  Stream<T?> streamDocument(String id) {
    return firestore
        .collection(collection)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? fromFirestore(doc) : null);
  }
} 