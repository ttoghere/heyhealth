import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Call {
  String callerId;
  String callerName;
  String receiverId;
  String receiverName;
  String channelId;
  bool hasDialled;
  Call({
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.channelId,
    required this.hasDialled,
  });

  Call copyWith({
    String? callerId,
    String? callerName,
    String? receiverId,
    String? receiverName,
    String? channelId,
    bool? hasDialled,
  }) {
    return Call(
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      channelId: channelId ?? this.channelId,
      hasDialled: hasDialled ?? this.hasDialled,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'channelId': channelId,
      'hasDialled': hasDialled,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      channelId: map['channelId'] as String,
      hasDialled: map['hasDialled'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Call.fromJson(String source) =>
      Call.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Call(callerId: $callerId, callerName: $callerName, receiverId: $receiverId, receiverName: $receiverName, channelId: $channelId, hasDialled: $hasDialled)';
  }

  @override
  bool operator ==(covariant Call other) {
    if (identical(this, other)) return true;

    return other.callerId == callerId &&
        other.callerName == callerName &&
        other.receiverId == receiverId &&
        other.receiverName == receiverName &&
        other.channelId == channelId &&
        other.hasDialled == hasDialled;
  }

  @override
  int get hashCode {
    return callerId.hashCode ^
        callerName.hashCode ^
        receiverId.hashCode ^
        receiverName.hashCode ^
        channelId.hashCode ^
        hasDialled.hashCode;
  }
}
