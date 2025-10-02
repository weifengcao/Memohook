String friendlyTimestamp(DateTime dt, {DateTime? reference}) {
  final now = reference ?? DateTime.now();
  final difference = now.difference(dt);

  if (difference.inMinutes < 1) {
    return 'just now';
  }
  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  }
  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours hour${hours == 1 ? '' : 's'} ago';
  }
  final date = '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';
  final time = '${_pad(dt.hour)}:${_pad(dt.minute)}';
  return '$date at $time';
}

String _pad(int value) => value.toString().padLeft(2, '0');
