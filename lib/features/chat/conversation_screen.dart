import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/user_data.dart';
import '../../core/data/message_data.dart';
import '../../core/data/message_storage.dart';
import '../../core/theme/app_theme.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final User user;

  const ConversationScreen({super.key, required this.user});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isTyping = false;
  bool _isLoading = true;

  // Starter prompts for first-time conversations
  static const List<String> _starterPrompts = [
    "I liked your recent model, can you give me some tips?",
    "Where did you buy these papers from?",
    "Your origami folds are really clean. Any advice for beginners?",
    "What's your favorite type of paper to work with?",
    "How long have you been doing origami?",
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await MessageStorage.loadMessages(widget.user.id);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: widget.user.profileImageUrl.startsWith('https')
                  ? NetworkImage(widget.user.profileImageUrl)
                  : null,
              child: widget.user.profileImageUrl.startsWith('https')
                  ? null
                  : Icon(
                      Icons.person,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isTyping)
                    Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages List or Starter Prompts
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildStarterPrompts()
                    : _buildMessagesList(),
          ),
          
          // Only show message input if there are messages
          if (_messages.isNotEmpty) _buildMessageInput(),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
      userId: widget.user.id,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    
    // Save to persistent storage
    await MessageStorage.saveMessages(widget.user.id, _messages);
    
    // Simulate typing indicator and response
    _simulateTypingAndResponse();
  }

  Widget _buildStarterPrompts() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start a conversation with ${widget.user.username}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a starter message or type your own:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _starterPrompts.map((prompt) {
              return _buildPromptChip(prompt);
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildCustomMessagePrompt(),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String prompt) {
    return InkWell(
      onTap: () => _sendPromptMessage(prompt),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          prompt,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomMessagePrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom message',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type your own message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _MessageBubble(
              message: message,
              isFromMe: message.isFromMe,
              user: widget.user,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: AppTheme.primaryColor,
            mini: true,
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _sendPromptMessage(String prompt) {
    _messageController.text = prompt;
    _sendMessage();
  }

  void _simulateTypingAndResponse() async {
    setState(() {
      _isTyping = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final responseMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _getAutoResponse(),
        timestamp: DateTime.now(),
        isFromMe: false,
        userId: widget.user.id,
      );
      
      setState(() {
        _isTyping = false;
        _messages.add(responseMessage);
      });
      
      // Save updated messages to storage
      await MessageStorage.saveMessages(widget.user.id, _messages);
    }
  }

  String _getAutoResponse() {
    final responses = [
      'That sounds great! Keep practicing!',
      'I love that model too! Have you tried the advanced version?',
      'Paper choice is really important. What type are you using?',
      'Thanks for sharing! Your progress sounds amazing.',
      'Have you checked out any origami tutorials online?',
      'Patience is key in origami. You\'re doing great!',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFromMe;
  final User user;

  const _MessageBubble({
    required this.message,
    required this.isFromMe,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: user.profileImageUrl.startsWith('https')
                  ? NetworkImage(user.profileImageUrl)
                  : null,
              child: user.profileImageUrl.startsWith('https')
                  ? null
                  : Icon(
                      Icons.person,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFromMe ? AppTheme.primaryColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: !isFromMe
                    ? Border.all(color: Theme.of(context).dividerColor)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isFromMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isFromMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromMe) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 14,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
