import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';

/// Comments panel displayed in the editor sidebar.
///
/// Shows a list of comments linked to document selections with
/// threaded replies, add comment functionality, and resolve/delete options.
class CommentsPanel extends StatefulWidget {
  const CommentsPanel({super.key});

  @override
  State<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  final _commentController = TextEditingController();
  bool _showInput = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        final doc = state is DocumentLoaded ? state.document : null;
        final comments = doc?.comments ?? [];

        return Container(
          width: 300,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'التعليقات',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${comments.length}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Comment input area
              if (_showInput)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _commentController,
                        autofocus: true,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'أضف تعليقاً...',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showInput = false;
                                _commentController.clear();
                              });
                            },
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              if (_commentController.text.isNotEmpty) {
                                context.read<DocumentBloc>().add(
                                      AddComment(_commentController.text),
                                    );
                                _commentController.clear();
                                setState(() => _showInput = false);
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0860CD),
                              foregroundColor: const Color(0xFF1A1A2E),
                            ),
                            child: const Text(
                              'إضافة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // Comments list
              Expanded(
                child: comments.isEmpty && !_showInput
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 48,
                              color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد تعليقات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                color: const Color(0xFF1A1A2E)
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _CommentCard(
                            comment: comment,
                            onResolve: () => context
                                .read<DocumentBloc>()
                                .add(ResolveComment(comment.id)),
                            onDelete: () => context
                                .read<DocumentBloc>()
                                .add(DeleteComment(comment.id)),
                            onReply: (text) => context
                                .read<DocumentBloc>()
                                .add(ReplyToComment(comment.id, text)),
                          );
                        },
                      ),
              ),
              // Add comment FAB
              if (!_showInput)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showInput = true),
                      icon: const Icon(Icons.add_comment_outlined, size: 18),
                      label: const Text(
                        'إضافة تعليق',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1A2E),
                        side: BorderSide(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentCard extends StatefulWidget {
  final dynamic comment;
  final VoidCallback onResolve;
  final VoidCallback onDelete;
  final ValueChanged<String> onReply;

  const _CommentCard({
    required this.comment,
    required this.onResolve,
    required this.onDelete,
    required this.onReply,
  });

  @override
  State<_CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard> {
  bool _showReplies = true;
  bool _showReplyInput = false;
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF0860CD),
                      child: Text(
                        (comment.author ?? '?').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        comment.author ?? 'مستخدم',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      iconSize: 18,
                      icon: Icon(
                        Icons.more_horiz,
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
                      ),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'resolve',
                          child: Text('حل'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('حذف'),
                        ),
                      ],
                      onSelected: (v) {
                        if (v == 'resolve') widget.onResolve();
                        if (v == 'delete') widget.onDelete();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Comment text
                Text(
                  comment.text ?? '',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                // Timestamp and reply button
                Row(
                  children: [
                    Text(
                      _formatTime(comment.timestamp),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(
                          () => _showReplyInput = !_showReplyInput),
                      child: Text(
                        'رد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: const Color(0xFF0860CD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Replies
          if (comment.replies != null && comment.replies.isNotEmpty)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 12, 8),
                    child: Column(
                      children: comment.replies.map<Widget>((reply) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                                child: Text(
                                  (reply.author ?? '?')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reply.text ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatTime(reply.timestamp),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9,
                                        color: const Color(0xFF1A1A2E)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              crossFadeState: _showReplies
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          // Reply input
          if (_showReplyInput)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: InputDecoration(
                        hintText: 'اكتب رداً...',
                        hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.send, size: 16),
                    color: const Color(0xFF0860CD),
                    onPressed: () {
                      if (_replyController.text.isNotEmpty) {
                        widget.onReply(_replyController.text);
                        _replyController.clear();
                        setState(() => _showReplyInput = false);
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
