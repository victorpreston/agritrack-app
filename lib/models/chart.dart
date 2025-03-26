import '../services/shared_prefs_helper.dart';

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imagePath,
  });

  // Convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
    );
  }
}

class ChatModel {
  List<Message> messages = [];

  Message addMessage({
    required String id,
    required String text,
    required bool isUser,
    String? imagePath,
  }) {
    final message = Message(
      id: id,
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );

    messages.add(message);

    _saveMessages();

    return message;
  }

  Future<void> loadMessages() async {
    final messagesList = await SharedPrefsHelper.getChatHistory();
    if (messagesList != null) {
      messages = messagesList.map((json) => Message.fromJson(json)).toList();
    }
  }

  Future<void> _saveMessages() async {
    final messagesList = messages.map((message) => message.toJson()).toList();
    await SharedPrefsHelper.saveChatHistory(messagesList);
  }

  Future<void> clearMessages() async {
    messages.clear();
    await SharedPrefsHelper.saveChatHistory([]);
  }

  Future<void> saveMessages() async {
    await _saveMessages();
  }
}