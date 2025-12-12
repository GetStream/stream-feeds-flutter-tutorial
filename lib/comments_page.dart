import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:stream_feeds/stream_feeds.dart';

import 'comment_composer.dart';

class CommentsPage extends StatefulWidget {
  static MaterialPageRoute<void> route(
    StreamFeedsClient client,
    String activityId,
    FeedId feedId,
  ) {
    return MaterialPageRoute(
      builder: (context) =>
          CommentsPage(client: client, activityId: activityId, feedId: feedId),
    );
  }

  const CommentsPage({
    super.key,
    required this.client,
    required this.activityId,
    required this.feedId,
  });

  final StreamFeedsClient client;
  final String activityId;
  final FeedId feedId;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late Activity activity;
  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  @override
  void didUpdateWidget(covariant CommentsPage oldWidget) {
    if (oldWidget.activityId != widget.activityId) {
      activity.dispose();
      _loadActivity();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    activity.dispose();
    super.dispose();
  }

  Future<void> _loadActivity() async {
    activity = widget.client.activity(
      activityId: widget.activityId,
      fid: widget.feedId,
    );
    await activity.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stream Feeds Tutorial')),
      body: Column(
        children: [
          Expanded(
            child: StateNotifierBuilder(
              stateNotifier: activity.notifier,
              builder: (context, state, child) {
                if (state.comments.isEmpty) {
                  return Center(child: Text('No comments yet'));
                }

                return ListView(
                  children: [
                    ...state.comments.map(
                      (comment) => CommentItem(comment: comment),
                    ),
                    if (activity.state.canLoadMoreComments)
                      TextButton(
                        onPressed: () => activity.queryMoreComments(),
                        child: Text('Load more'),
                      ),
                  ],
                );
              },
            ),
          ),
          CommentComposer(activity: activity),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  const CommentItem({super.key, required this.comment});

  final CommentData comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.user.name ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(comment.text ?? ''),
          ],
        ),
      ),
    );
  }
}
