import 'package:flutter/material.dart';
import 'package:stream_feeds/stream_feeds.dart';

class CommentComposer extends StatefulWidget {
  const CommentComposer({super.key, required this.activity});

  final Activity activity;

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (_hasText != hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Write a comment...',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: _hasText && !_isSending ? _createComment : null,
              icon: Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
              disabledColor: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createComment() async {
    await widget.activity.addComment(
      request: ActivityAddCommentRequest(
        comment: _controller.text,
        activityId: widget.activity.activityId,
      ),
    );
    _controller.clear();
  }
}
