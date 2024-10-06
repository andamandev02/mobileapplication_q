String formatQueueTime(String queueTime) {
  try {
    List<String> parts = queueTime.split(':');
    return '${parts[0]}:${parts[1]}';
  } catch (e) {
    return 'Invalid time';
  }
}

String calculateTimeDifference(String queueTime) {
  DateTime now = DateTime.now();
  DateTime parsedTime = DateTime(now.year, now.month, now.day,
      int.parse(queueTime.split(":")[0]), int.parse(queueTime.split(":")[1]));
  Duration difference = now.difference(parsedTime);
  int hours = difference.inHours;
  int minutes = (difference.inMinutes % 60);
  int secounds = (difference.inSeconds % 60);
  return '$hours:${minutes.toString().padLeft(2, '0')}:${secounds.toString().padLeft(2, '0')}';
}
