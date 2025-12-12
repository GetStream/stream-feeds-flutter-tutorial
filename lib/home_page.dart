import 'package:flutter/material.dart';
import 'package:stream_feeds/stream_feeds.dart';

import 'activity_composer.dart';
import 'activity_list_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.client,
    required this.userFeed,
    required this.timelineFeed,
    required this.onFollow,
    required this.onUnfollow,
  });

  final StreamFeedsClient client;
  final Feed userFeed;
  final Feed timelineFeed;
  final ValueSetter<FeedId> onFollow;
  final ValueSetter<FeedId> onUnfollow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActivityComposer(userFeed: userFeed),
        Expanded(
          child: ActivityListView(
            client: client,
            feed: timelineFeed,
            onFollow: onFollow,
            onUnfollow: onUnfollow,
          ),
        ),
      ],
    );
  }
}
