import '../../features/logs/memory_log.dart';

abstract class MemoryLogRepository {
  Future<List<MemoryLog>> loadInitialLogs();

  Future<void> addLog(MemoryLog log);
}

class InMemoryLogRepository extends MemoryLogRepository {
  InMemoryLogRepository({List<MemoryLog>? seed}) : _logs = List.of(seed ?? []);

  final List<MemoryLog> _logs;

  @override
  Future<List<MemoryLog>> loadInitialLogs() async {
    _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(_logs);
  }

  @override
  Future<void> addLog(MemoryLog log) async {
    _logs.insert(0, log);
  }
}
