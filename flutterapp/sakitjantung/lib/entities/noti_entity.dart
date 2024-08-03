import 'dart:typed_data';

class NotificationEventEntity {
  String uniqueId;
  String key;
  String packageName;
  int uid;
  String channelId;
  int id;
  DateTime createAt;
  int timestamp;
  String title;
  String text;
  bool hasLargeIcon;
  Uint8List? largeIcon;
  bool canTap;
  Map<String, dynamic> raw;
  int transactionType; // 2 for money in, 1 for money out
  double amount;

  NotificationEventEntity({
    String? uniqueId,
    String? key,
    String? packageName,
    int? uid,
    String? channelId,
    int? id,
    DateTime? createAt,
    int? timestamp,
    String? title,
    String? text,
    bool? hasLargeIcon,
    Uint8List? largeIcon,
    bool? canTap,
    Map<String, dynamic>? raw,
    int? transactionType,
    double? amount,
  })  : uniqueId = uniqueId ?? '',
        key = key ?? '',
        packageName = packageName ?? '',
        uid = uid ?? 0,
        channelId = channelId ?? '',
        id = id ?? 0,
        createAt = createAt ?? DateTime.now(),
        timestamp = timestamp ?? 0,
        title = title ?? '',
        text = text ?? '',
        hasLargeIcon = hasLargeIcon ?? false,
        largeIcon = largeIcon ?? Uint8List(0),
        canTap = canTap ?? false,
        raw = raw ?? {},
        transactionType = transactionType ?? -1,
        amount = amount ?? 0; // -1 means not classified

  // Convert a map to a NotificationEventEntity object
  factory NotificationEventEntity.fromMap(Map<String, dynamic>? map) {
    if (map == null) return NotificationEventEntity();

    return NotificationEventEntity(
      uniqueId: map['uniqueId'],
      key: map['key'],
      packageName: map['packageName'],
      uid: map['uid'],
      channelId: map['channelId'],
      id: map['id'],
      createAt:
          map['createAt'] != null ? DateTime.parse(map['createAt']) : null,
      timestamp: map['timestamp'],
      title: map['title'],
      text: map['text'],
      hasLargeIcon: map['hasLargeIcon'],
      largeIcon: map['largeIcon'] != null
          ? Uint8List.fromList(List<int>.from(map['largeIcon']))
          : null,
      canTap: map['canTap'],
      raw: map['raw'],
      transactionType: map['transactionType'],
      amount: map['amount'],
    );
  }

  // Convert a NotificationEventEntity object to a map
  Map<String, dynamic> toMap() {
    return {
      'uniqueId': uniqueId,
      'key': key,
      'packageName': packageName,
      'uid': uid,
      'channelId': channelId,
      'id': id,
      'createAt': createAt.toIso8601String(),
      'timestamp': timestamp,
      'title': title,
      'text': text,
      'hasLargeIcon': hasLargeIcon,
      'largeIcon': largeIcon?.toList(),
      'canTap': canTap,
      'raw': raw,
      'transactionType': transactionType,
      'amount': amount,
    };
  }
}
