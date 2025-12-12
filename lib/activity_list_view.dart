import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:stream_feeds/stream_feeds.dart';

import 'activity_item.dart';
import 'comments_page.dart';

class ActivityListView extends StatelessWidget {
  const ActivityListView({
    super.key,
    required this.client,
    required this.feed,
    required this.onFollow,
    required this.onUnfollow,
  });
  final StreamFeedsClient client;
  final Feed feed;
  final ValueSetter<FeedId> onFollow;
  final ValueSetter<FeedId> onUnfollow;

  @override
  Widget build(BuildContext context) {
    return StateNotifierBuilder(
      stateNotifier: feed.notifier,
      builder: (context, state, child) {
        if (state.activities.isEmpty) {
          return Center(child: const Text('No posts yet'));
        }
        return RefreshIndicator(
          onRefresh: () => feed.getOrCreate(),
          child: ListView(
            children: [
              ...state.activities.map(
                (activity) => ActivityItem(
                  currentUserId: client.user.id,
                  activity: activity,
                  onFollow: onFollow,
                  onUnfollow: onUnfollow,
                  onCommentPressed: () {
                    Navigator.of(
                      context,
                    ).push(CommentsPage.route(client, activity.id, feed.fid));
                  },
                  onLikePressed: () {
                    if (activity.ownReactions.isEmpty) {
                      feed.addActivityReaction(
                        activityId: activity.id,
                        request: AddReactionRequest(type: 'like'),
                      );
                    } else {
                      feed.deleteActivityReaction(
                        activityId: activity.id,
                        type: 'like',
                      );
                    }
                  },
                ),
              ),
              if (feed.state.canLoadMoreActivities)
                TextButton(
                  onPressed: () => feed.queryMoreActivities(),
                  child: Text('Load more'),
                ),
            ],
          ),
        );
      },
    );
  }
}
