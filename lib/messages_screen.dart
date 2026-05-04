import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('messages')
          .select('id, content, created_at, is_read, sender_id, receiver_id, listing_id, listings(title), profiles!messages_sender_id_fkey(full_name, avatar_url)')
          .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
          .order('created_at', ascending: false);

      // Group by conversation partner
      final Map<String, Map<String, dynamic>> convMap = {};
      for (final msg in data) {
        final otherId = msg['sender_id'] == user.id
            ? msg['receiver_id']
            : msg['sender_id'];
        if (!convMap.containsKey(otherId)) {
          convMap[otherId] = msg;
        }
      }

      if (mounted) setState(() { _conversations = convMap.values.toList(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFAF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No messages yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                      const SizedBox(height: 8),
                      Text('Apply to jobs or post listings to start conversations', style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchConversations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      final user = Supabase.instance.client.auth.currentUser;
                      final otherProfile = conv['profiles'];
                      final name = otherProfile?['full_name'] ?? 'Unknown';
                      final lastMsg = conv['content'] ?? '';
                      final listingTitle = conv['listings']?['title'] ?? '';
                      final isUnread = !conv['is_read'] && conv['receiver_id'] == user?.id;

                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => _ChatScreen(
                            otherUserId: conv['sender_id'] == user?.id ? conv['receiver_id'] : conv['sender_id'],
                            otherName: name,
                            listingId: conv['listing_id'],
                            listingTitle: listingTitle,
                          ),
                        )),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: isUnread ? Border.all(color: const Color(0xFF5B8DB8), width: 1.5) : null,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF5B8DB8),
                                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    if (listingTitle.isNotEmpty)
                                      Text(listingTitle, style: const TextStyle(color: Color(0xFF5B8DB8), fontSize: 12)),
                                    Text(lastMsg, style: TextStyle(color: isUnread ? Colors.black87 : Colors.grey[500], fontSize: 13),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              if (isUnread)
                                Container(width: 10, height: 10,
                                    decoration: const BoxDecoration(color: Color(0xFF5B8DB8), shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherName;
  final String? listingId;
  final String listingTitle;
  const _ChatScreen({required this.otherUserId, required this.otherName, this.listingId, required this.listingTitle});
  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('messages')
          .select()
          .or('and(sender_id.eq.${user.id},receiver_id.eq.${widget.otherUserId}),and(sender_id.eq.${widget.otherUserId},receiver_id.eq.${user.id})')
          .order('created_at', ascending: true);

      // Mark received messages as read
      await Supabase.instance.client
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', widget.otherUserId)
          .eq('receiver_id', user.id);

      if (mounted) setState(() { _messages = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _ctrl.text.trim().isEmpty) return;
    final content = _ctrl.text.trim();
    _ctrl.clear();
    try {
      await Supabase.instance.client.from('messages').insert({
        'sender_id': user.id,
        'receiver_id': widget.otherUserId,
        'listing_id': widget.listingId,
        'content': content,
      });
      await _fetchMessages();
    } catch (e) {
      debugPrint('Send error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFAF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.otherName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
          if (widget.listingTitle.isNotEmpty)
            Text(widget.listingTitle, style: const TextStyle(color: Color(0xFF5B8DB8), fontSize: 12)),
        ]),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFFF3CD),
            child: const Row(children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF856404)),
              SizedBox(width: 8),
              Expanded(child: Text('Keep conversations on CariWorks. Never share passwords or send payments outside the app.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF856404)))),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final msg = _messages[i];
                      final isMine = msg['sender_id'] == userId;
                      return Align(
                        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMine ? const Color(0xFF5B8DB8) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                          ),
                          child: Text(msg['content'] ?? '',
                              style: TextStyle(color: isMine ? Colors.white : Colors.black87, fontSize: 14)),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 8),
            color: Colors.white,
            child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true, fillColor: const Color(0xFFF1F3F4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFF5B8DB8), shape: BoxShape.circle),
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
