class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final String userId; // ID of the other user in conversation
  
  const Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    required this.userId,
  });
  
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromMe: json['isFromMe'] as bool,
      userId: json['userId'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isFromMe': isFromMe,
      'userId': userId,
    };
  }
  
  Message copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    bool? isFromMe,
    String? userId,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFromMe: isFromMe ?? this.isFromMe,
      userId: userId ?? this.userId,
    );
  }
}
