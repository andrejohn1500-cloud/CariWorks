import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  final String conversationPartnerId;
  final String partnerName;
  final String listingId;
  final String listingTitle;

  const ChatScreen({
    super.key,
    required this.conversationPartnerId,
    required this.partnerName,
    required this.listingId,
    required this.listingTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  int _strikes = 0;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _markRead();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    final me = _supabase.auth.currentUser?.id;
    if (me == null) return;
    final data = await _supabase
        .from('messages')
        .select()
        .or('and(sender_id.eq.$me,receiver_id.eq.${widget.conversationPartnerId}),and(sender_id.eq.${widget.conversationPartnerId},receiver_id.eq.$me)')
        .eq('listing_id', widget.listingId)
        .order('created_at', ascending: true);
    setState(() {
      _messages = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
    _scrollToBottom();
  }

  Future<void> _markRead() async {
    final me = _supabase.auth.currentUser?.id;
    if (me == null) return;
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', me)
        .eq('sender_id', widget.conversationPartnerId)
        .eq('listing_id', widget.listingId);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _containsBannedWords(String text) {
    const banned = [
      'fuck', 'shit', 'bitch', 'asshole', 'nigger', 'nigga', 'faggot', 'cunt',
      'kill you', 'kill him', 'kill her', 'i will kill', 'gonna kill', 'murder',
      'rape', 'bomb', 'terrorist', 'cocaine', 'heroin', 'drug deal',
      'hate you', 'shoot you', 'stab you',
    ];
    final lower = text.toLowerCase();
    return banned.any((w) => lower.contains(w));
  }

  Future<void> _suspendUser(String userId) async {
    await _supabase.from('profiles').update({'is_suspended': true}).eq('id', userId);
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final me = _supabase.auth.currentUser?.id;
    if (me == null) return;
    if (_containsBannedWords(text)) {
      _strikes++;
      if (_strikes >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been suspended for violating community guidelines.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        await _suspendUser(me);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Warning \$_strikes/3: Message blocked — community guidelines violation.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    _ctrl.clear();
    await _supabase.from('messages').insert({
      'listing_id': widget.listingId,
      'sender_id': me,
      'receiver_id': widget.conversationPartnerId,
      'content': text,
      'is_read': false,
    });
    await _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    final me = _supabase.auth.currentUser?.id;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.partnerName,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.listingTitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5B8DB8)))
                : _messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet. Say hello!',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMine = msg['sender_id'] == me;
                          return Align(
                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isMine ? const Color(0xFF5B8DB8) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                msg['content'] ?? '',
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.only(
                left: 16, right: 8, top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8),
            color: Colors.white,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B8DB8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
