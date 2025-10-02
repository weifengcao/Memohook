import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/logs/memory_log.dart';
import '../memory_log_repository.dart';

class FirestoreMemoryLogRepository extends MemoryLogRepository {
  FirestoreMemoryLogRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  final StreamController<List<MemoryLog>> _controller =
      StreamController<List<MemoryLog>>.broadcast();

  @override
  Future<void> initialize() async {
    // TODO: Decide how to scope appId/userId; these might come from auth.
    const appId = 'memohook-dev';
    const userId = 'local-demo-user';

    final collection = _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('logs')
        .orderBy('timestamp', descending: true);

    _subscription = collection.snapshots().listen((snapshot) {
      final logs = snapshot.docs.map(_fromDoc).toList();
      _controller.add(logs);
    }, onError: _controller.addError);
  }

  @override
  Stream<List<MemoryLog>> watchLogs() => _controller.stream;

  @override
  Future<void> addLog(MemoryLog log) async {
    const appId = 'memohook-dev';
    const userId = 'local-demo-user';

    final docRef = _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('logs')
        .doc(log.id);

    await docRef.set({
      'content': log.content,
      'timestamp': Timestamp.fromDate(log.createdAt),
      'keywords': log.keywords,
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }

  MemoryLog _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing Firestore data for ${doc.id}');
    }
    return MemoryLog(
      id: doc.id,
      content: data['content'] as String? ?? '',
      createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      keywords:
          (data['keywords'] as List<dynamic>?)
              ?.map((keyword) => keyword.toString())
              .toList() ??
          const <String>[],
    );
  }
}
