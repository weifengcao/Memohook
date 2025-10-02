import 'dart:async';

import '../../features/logs/memory_log.dart';

abstract class MemoryLogRepository {
  Future<void> initialize();

  Stream<List<MemoryLog>> watchLogs();

  Future<void> addLog(MemoryLog log);

  void dispose();
}

class InMemoryLogRepository extends MemoryLogRepository {
  InMemoryLogRepository({List<MemoryLog>? seed}) : _logs = List.of(seed ?? []) {
    _controller = StreamController<List<MemoryLog>>.broadcast(onListen: _emit);
  }

  final List<MemoryLog> _logs;
  late final StreamController<List<MemoryLog>> _controller;

  @override
  Future<void> initialize() async {
    _emit();
  }

  @override
  Stream<List<MemoryLog>> watchLogs() => _controller.stream;

  @override
  Future<void> addLog(MemoryLog log) async {
    _logs.insert(0, log);
    _emit();
  }

  @override
  void dispose() {
    _controller.close();
  }

  void _emit() {
    _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_logs));
    }
  }
}
