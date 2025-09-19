import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;
  final VoidCallback onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    required this.onComplete,
    this.style = const TextStyle(fontSize: 16, color: Colors.black87),
    this.speed = const Duration(milliseconds: 25),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    Future.doWhile(() async {
      if (_index < widget.text.length) {
        await Future.delayed(widget.speed);
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_index];
            _index++;
          });
        }
        return true;
      } else {
        widget.onComplete();
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayedText, style: widget.style);
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatUser _currentUser = ChatUser(
    id: "user",
    firstName: "You",
    profileImage: "https://i.pravatar.cc/150?img=3",
  );

  final ChatUser _botUser = ChatUser(
    id: "bot",
    firstName: "Sahayak",
    profileImage: "https://cdn-icons-png.flaticon.com/512/4712/4712109.png",
  );

  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  final Set<String> _typedMessages = {};

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Load chat history from local storage
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("chat_history");
    if (saved != null) {
      final List decoded = jsonDecode(saved);
      setState(() {
        _messages.addAll(decoded.map((m) => ChatMessage(
              user: m['role'] == 'user' ? _currentUser : _botUser,
              createdAt: DateTime.parse(m['time']),
              text: m['text'],
            )));
        _typedMessages.addAll(decoded.map((m) => m['text']));
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _messages.map((m) {
      return {
        'role': m.user.id,
        'text': m.text,
        'time': m.createdAt.toIso8601String(),
      };
    }).toList();
    await prefs.setString("chat_history", jsonEncode(data));
  }

  Future<void> _sendMessage(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
      _isLoading = true;
    });

    await _saveMessages();

    final history = _messages
        .map((m) => {
              'role': m.user.id == _currentUser.id ? 'user' : 'model',
              'text': m.text
            })
        .toList()
        .reversed
        .toList();

    final reply = await _chatService.sendMessage(history);

    final botMessage = ChatMessage(
      user: _botUser,
      createdAt: DateTime.now(),
      text: reply,
    );

    setState(() {
      _messages.insert(0, botMessage);
      _isLoading = false;
    });

    await _saveMessages();
  }

  Future<void> _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("chat_history");
    setState(() {
      _messages.clear();
      _typedMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          DashChat(
            currentUser: _currentUser,
            onSend: _sendMessage,
            messages: _messages,
            typingUsers: _isLoading ? [_botUser] : [],
            messageOptions: MessageOptions(
              showTime: true,
              containerColor: const Color.fromARGB(255, 232, 232, 232), // bot
              currentUserContainerColor: const Color.fromARGB(255, 185, 185, 185), // user
              textColor: Colors.black87,
              currentUserTextColor: Colors.black87,
              messageTextBuilder: (message, previous, next) {
                final isBot = message.user.id == _botUser.id;
                final isLatestBot =
                    isBot && _messages.isNotEmpty && _messages.first == message;

                if (isLatestBot &&
                    !_typedMessages.contains(message.text) &&
                    !_isLoading) {
                  return TypewriterText(
                    text: message.text,
                    onComplete: () {
                      _typedMessages.add(message.text);
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  );
                }

                return Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isBot ? Colors.black87 : Colors.black87,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Clear Chat",
              onPressed: _clearChat,
            ),
          ),
        ],
      ),
    );
  }
}
