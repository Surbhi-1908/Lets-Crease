import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'message_data.dart';

class MessageStorage {
  static const String _messagesFileName = 'messages.json';
  
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_messagesFileName');
  }
  
  // Save messages for a conversation
  static Future<void> saveMessages(String userId, List<Message> messages) async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final existingData = await file.readAsString();
        final Map<String, dynamic> allConversations = json.decode(existingData);
        
        // Update only the specific conversation
        allConversations[userId] = messages.map((m) => m.toJson()).toList();
        
        await file.writeAsString(json.encode(allConversations));
      } else {
        // Create new file with this conversation
        final Map<String, dynamic> allConversations = {
          userId: messages.map((m) => m.toJson()).toList(),
        };
        await file.writeAsString(json.encode(allConversations));
      }
    } catch (e) {
      // Handle error silently for now
    }
  }
  
  // Load messages for a conversation
  static Future<List<Message>> loadMessages(String userId) async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final existingData = await file.readAsString();
        final Map<String, dynamic> allConversations = json.decode(existingData);
        
        if (allConversations.containsKey(userId)) {
          final List<dynamic> messagesData = allConversations[userId];
          return messagesData.map((m) => Message.fromJson(m)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Get all conversation summaries (for chat list)
  static Future<Map<String, ConversationSummary>> getConversationSummaries() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final existingData = await file.readAsString();
        final Map<String, dynamic> allConversations = json.decode(existingData);
        
        Map<String, ConversationSummary> summaries = {};
        
        allConversations.forEach((userId, messagesData) {
          final List<dynamic> messagesList = messagesData;
          if (messagesList.isNotEmpty) {
            final lastMessage = Message.fromJson(messagesList.last);
            summaries[userId] = ConversationSummary(
              userId: userId,
              lastMessage: lastMessage.text,
              lastMessageTime: lastMessage.timestamp,
              messageCount: messagesList.length,
            );
          }
        });
        
        return summaries;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  // Clear a specific conversation
  static Future<void> clearConversation(String userId) async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final existingData = await file.readAsString();
        final Map<String, dynamic> allConversations = json.decode(existingData);
        
        allConversations.remove(userId);
        await file.writeAsString(json.encode(allConversations));
      }
    } catch (e) {
      // Handle error silently
    }
  }
}

class ConversationSummary {
  final String userId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int messageCount;
  
  const ConversationSummary({
    required this.userId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messageCount,
  });
}
