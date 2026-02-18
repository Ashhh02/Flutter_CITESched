import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citesched_flutter/main.dart';
import 'package:citesched_flutter/core/utils/date_utils.dart';
import 'dart:convert';

class NLPQueryDialog extends ConsumerStatefulWidget {
  const NLPQueryDialog({super.key});

  @override
  ConsumerState<NLPQueryDialog> createState() => _NLPQueryDialogState();
}

class _NLPQueryDialogState extends ConsumerState<NLPQueryDialog> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  final Color maroonColor = const Color(0xFF720045);

  @override
  void initState() {
    super.initState();
    _messages.add({
      'isUser': false,
      'text':
          "Hello! I'm your CITESched Assistant. I can help you find schedules, check room availability, or (for admins) analyze conflicts and faculty load.",
    });
  }

  Future<void> _sendQuery() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': query});
      _queryController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await client.nLP.query(query);

      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': response.text,
            'intent': response.intent,
            'schedules': response.schedules,
            'dataJson': response.dataJson,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text':
                "I encountered an error while processing your request. Please try again later.",
            'isError': true,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 700,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [maroonColor, const Color(0xFF9d005f)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CITESched AI',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Powered by NLP Service',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _TypingIndicator(maroonColor: maroonColor);
                  }

                  final msg = _messages[index];
                  return _MessageBubble(
                    messageData: msg,
                    maroonColor: maroonColor,
                  );
                },
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      onSubmitted: (_) => _sendQuery(),
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Ask about schedules, rooms, load...",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: maroonColor,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendQuery,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final Color maroonColor;
  const _TypingIndicator({required this.maroonColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: maroonColor.withOpacity(0.1),
            radius: 18,
            child: Icon(Icons.smart_toy_rounded, color: maroonColor, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _Dot(delay: i * 200, color: maroonColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  final Color color;
  const _Dot({required this.delay, required this.color});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.3 + (0.7 * _animation.value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final Color maroonColor;

  const _MessageBubble({
    required this.messageData,
    required this.maroonColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = messageData['isUser'] as bool;
    final isError = messageData['isError'] ?? false;
    final text = messageData['text'] as String;
    final schedules = messageData['schedules'] as List?;
    final dataJson = messageData['dataJson'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                CircleAvatar(
                  backgroundColor: maroonColor.withOpacity(0.1),
                  radius: 18,
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: maroonColor,
                    size: 20,
                  ),
                ),
              if (!isUser) const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser
                        ? maroonColor
                        : (isError
                              ? Colors.red.withOpacity(0.05)
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey[100])),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: isError
                        ? Border.all(color: Colors.red.withOpacity(0.3))
                        : null,
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.4,
                      color: isUser
                          ? Colors.white
                          : (isError
                                ? Colors.red[700]
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF2D3748))),
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 12),
              if (isUser)
                CircleAvatar(
                  backgroundColor: maroonColor.withOpacity(0.1),
                  radius: 18,
                  child: Icon(
                    Icons.person_rounded,
                    color: maroonColor,
                    size: 20,
                  ),
                ),
            ],
          ),
          if (schedules != null && schedules.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildScheduleCards(context, schedules),
          ],
          if (dataJson != null) ...[
            const SizedBox(height: 12),
            _buildDataSummary(context, dataJson),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCards(BuildContext context, List schedules) {
    return Padding(
      padding: const EdgeInsets.only(left: 48), // Align with bot bubble
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: schedules.map((s) {
            return Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: maroonColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.subject?.name ?? 'Unknown Subject',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: maroonColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.room_outlined,
                        size: 10,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.room?.name ?? 'TBA',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 10,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          s.timeslot != null
                              ? CITESchedDateUtils.formatTimeslot(
                                  s.timeslot!.day,
                                  s.timeslot!.startTime,
                                  s.timeslot!.endTime,
                                )
                              : 'TBA',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDataSummary(BuildContext context, String dataJson) {
    try {
      final data = jsonDecode(dataJson);
      if (data['count'] != null) {
        // This is a conflict summary
        return Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSmallChip(context, "Room: ${data['room']}", Colors.orange),
              _buildSmallChip(
                context,
                "Faculty: ${data['faculty']}",
                Colors.red,
              ),
            ],
          ),
        );
      }
    } catch (_) {}
    return const SizedBox();
  }

  Widget _buildSmallChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
