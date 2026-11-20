const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'
];

/// 12 July 2025
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "42 min", "1 h 5 min"
String formatDuration(Duration d) {
  final m = d.inMinutes;
  if (m < 60) return '$m min';
  final h = m ~/ 60;
  final r = m % 60;
  return r == 0 ? '$h h' : '$h h $r min';
}

/// "2m ago", "3h ago", "5d ago"
String timeAgo(DateTime t, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(t);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String formatDistance(double km) =>
    km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(km == km.roundToDouble() ? 0 : 1)} km';

String plural(int n, String one, [String? many]) => n == 1 ? one : (many ?? '${one}s');
