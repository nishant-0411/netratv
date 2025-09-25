import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotScreen extends StatefulWidget {
  final List<String> userInterests;
  final String? userName;

  const ChatbotScreen({
    super.key,
    this.userInterests = const [],
    this.userName,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  static const String _historyPrefsKey = 'chatbot_history_v1';
  List<String> _fetchedInterests = const [];
  String? _fetchedName;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadUserProfile();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_historyPrefsKey);
    if (saved != null) {
      try {
        final List decoded = jsonDecode(saved);
        setState(() {
          _messages.clear();
          _messages.addAll(
            decoded.map(
              (e) => _ChatMessage(
                role: e['role'] as String? ?? 'user',
                content: e['content'] as String? ?? '',
              ),
            ),
          );
        });
        _scrollToBottom();
      } catch (_) {}
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _messages
        .map((m) => {'role': m.role, 'content': m.content})
        .toList(growable: false);
    await prefs.setString(_historyPrefsKey, jsonEncode(payload));
  }

  Future<void> _loadUserProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data();
      if (data == null) return;
      setState(() {
        _fetchedName = (data['name'] as String?)?.trim();
        final raw = data['interests'];
        _fetchedInterests = raw is List ? List<String>.from(raw) : const [];
      });
    } catch (_) {}
  }

  String _buildSystemPreamble() {
    final effectiveInterests = widget.userInterests.isNotEmpty
        ? widget.userInterests
        : _fetchedInterests;
    final interests = effectiveInterests.isEmpty
        ? 'No specific interests provided.'
        : effectiveInterests.join(', ');
    final name = (widget.userName ?? _fetchedName)?.trim();
    final nameLine = name == null || name.isEmpty
        ? ''
        : ' The user name is $name.';
    return 'You are a helpful career mentor for Indian audiences. Use a neutral Indian English tone (spellings can be Indian/British). Be concise, practical, and culturally contextual to India (e.g., exams, colleges, entrance tests, local job market). Tailor your answers to these user interests: $interests.$nameLine Avoid slang; keep it respectful and encouraging.';
  }

  List<_ChatMessage> _buildContextMessages(String userPrompt) {
    final List<_ChatMessage> context = [];
    context.add(_ChatMessage(role: 'system', content: _buildSystemPreamble()));

    final historyTail = _messages.length > 8
        ? _messages.sublist(_messages.length - 8)
        : List<_ChatMessage>.from(_messages);
    context.addAll(historyTail);

    context.add(_ChatMessage(role: 'user', content: userPrompt));
    return context;
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _sending = true;
      _inputController.clear();
    });
    _scrollToBottom();
    await _saveHistory();

    final contextMessages = _buildContextMessages(text);

    try {
      final buffer = StringBuffer();
      for (final m in contextMessages) {
        if (m.role == 'system') {
          buffer.writeln('System: ${m.content}\n');
        } else if (m.role == 'user') {
          buffer.writeln('User: ${m.content}\n');
        } else {
          buffer.writeln('Assistant: ${m.content}\n');
        }
      }

      final response = await Gemini.instance.prompt(
        parts: [Part.text(buffer.toString())],
      );
      final aiText = response?.output?.trim();

      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content: aiText == null || aiText.isEmpty
                ? 'Sorry, I could not generate a response.'
                : aiText,
          ),
        );
        _sending = false;
      });
      _scrollToBottom();
      await _saveHistory();
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content:
                'There was an error generating a response. Please try again.',
          ),
        );
        _sending = false;
      });
      _scrollToBottom();
      await _saveHistory();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearChat() async {
    setState(() {
      _messages.clear();
    });
    await _saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF7F9FC), Color(0xFFF0F4F8)],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.role == 'user';
                      final bubbleColor = isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white;
                      final textColor = isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Colors.black87;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isUser)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFE3F2FD),
                                child: Icon(
                                  Icons.smart_toy,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            if (!isUser) const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: bubbleColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft: Radius.circular(
                                      isUser ? 14 : 4,
                                    ),
                                    bottomRight: Radius.circular(
                                      isUser ? 4 : 14,
                                    ),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: isUser
                                    ? Text(
                                        message.content,
                                        style: TextStyle(color: textColor),
                                      )
                                    : MarkdownBody(
                                        data: message.content,
                                        selectable: true,
                                        styleSheet: MarkdownStyleSheet(
                                          p: const TextStyle(
                                            fontSize: 15,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            if (isUser) const SizedBox(width: 8),
                            if (isUser)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFE8F5E9),
                                child: Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x11000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _inputController,
                                    minLines: 1,
                                    maxLines: 6,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Ask about careers, exams, skills, colleges (India)',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _sending ? null : _sendMessage,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _sending
                                  ? Colors.grey.shade300
                                  : Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _sending
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: (bottomInset > 0 ? bottomInset : 0) + 92,
            child: FloatingActionButton(
              mini: true,
              onPressed: _sending ? null : _clearChat,
              tooltip: 'Clear chat',
              child: const Icon(Icons.delete_outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role; // 'user' | 'assistant' | 'system'
  final String content;

  _ChatMessage({required this.role, required this.content});
}
