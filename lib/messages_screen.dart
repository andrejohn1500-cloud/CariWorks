import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _allMessages = <String, List<Map<String, dynamic>>>{};

  final _conversations = [
    {'name': 'TechSVG Ltd', 'avatar': 'T', 'color': 0xFF5B8DB8, 'lastMessage': 'Thanks for applying! Can we schedule an interview?', 'time': '9:45 AM', 'unread': 2, 'job': 'Web Developer'},
    {'name': 'PowerPro TT', 'avatar': 'P', 'color': 0xFFE8A838, 'lastMessage': 'Please send your certifications to HR.', 'time': 'Yesterday', 'unread': 0, 'job': 'Electrician'},
    {'name': 'Caribbean Brands', 'avatar': 'C', 'color': 0xFF4CAF50, 'lastMessage': 'We reviewed your portfolio and loved it!', 'time': 'Mon', 'unread': 1, 'job': 'Marketing Officer'},
    {'name': 'Milton Cato Hospital', 'avatar': 'M', 'color': 0xFFE53935, 'lastMessage': 'Your application is under review.', 'time': 'Sun', 'unread': 0, 'job': 'Nurse'},
    {'name': 'Island Freight Co', 'avatar': 'I', 'color': 0xFF8E24AA, 'lastMessage': 'Are you available to start next Monday?', 'time': 'Fri', 'unread': 0, 'job': 'Logistics Officer'},
  ];

  void _openChat(BuildContext context, Map<String, dynamic> c) {
    final key = c['name'] as String;
    final job = c['job'] as String;
    final lastMsg = c['lastMessage'] as String;
    final time = c['time'] as String;
    if (!_allMessages.containsKey(key)) {
      _allMessages[key] = [
        {'text': 'Hi, we saw your application for the $job position.', 'mine': false, 'time': '9:30 AM'},
        {'text': 'Thank you! I am very interested in the role.', 'mine': true, 'time': '9:32 AM'},
        {'text': lastMsg, 'mine': false, 'time': time},
      ];
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => _ChatScreen(
      conversation: c,
      messages: _allMessages[key]!,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF5B8DB8)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: Icon(Icons.search, color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (ctx, i) {
                final c = _conversations[i];
                final unread = c['unread'] as int;
                return GestureDetector(
                  onTap: () => _openChat(context, c),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Color(c['color'] as int).withValues(alpha: 0.15),
                              child: Text(c['avatar'] as String,
                                style: TextStyle(color: Color(c['color'] as int), fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            if (unread > 0)
                              Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xFF5B8DB8), shape: BoxShape.circle),
                                  child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(c['name'] as String, style: TextStyle(fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600, fontSize: 15)),
                                  Text(c['time'] as String, style: TextStyle(fontSize: 12, color: unread > 0 ? const Color(0xFF5B8DB8) : Colors.black38, fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(c['job'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF5B8DB8))),
                              const SizedBox(height: 4),
                              Text(c['lastMessage'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: unread > 0 ? Colors.black87 : Colors.black45, fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;
  final List<Map<String, dynamic>> messages;
  const _ChatScreen({required this.conversation, required this.messages});
  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final _controller = TextEditingController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(c['color'] as int).withValues(alpha: 0.15),
              child: Text(c['avatar'] as String, style: TextStyle(color: Color(c['color'] as int), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                Text(c['job'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF5B8DB8))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final mine = m['mine'] as bool;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                    decoration: BoxDecoration(
                      color: mine ? const Color(0xFF5B8DB8) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m['text'] as String, style: TextStyle(color: mine ? Colors.white : Colors.black87, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(m['time'] as String, style: TextStyle(fontSize: 10, color: mine ? Colors.white70 : Colors.black38)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.trim().isEmpty) return;
                      setState(() {
                        _messages.add({'text': _controller.text.trim(), 'mine': true, 'time': 'Now'});
                        _controller.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Color(0xFF5B8DB8), shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
