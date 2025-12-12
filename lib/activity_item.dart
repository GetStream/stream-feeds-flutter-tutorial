import 'package:flutter/material.dart';
import 'package:stream_feeds/stream_feeds.dart';

class ActivityItem extends StatelessWidget {
  const ActivityItem({
    super.key,
    required this.currentUserId,
    required this.activity,
    required this.onFollow,
    required this.onUnfollow,
    required this.onCommentPressed,
    required this.onLikePressed,
  });

  final String currentUserId;
  final ActivityData activity;
  final ValueSetter<FeedId> onFollow;
  final ValueSetter<FeedId> onUnfollow;
  final VoidCallback onCommentPressed;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    final isFollowing = activity.currentFeed?.ownFollows?.isNotEmpty ?? false;

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: CircleAvatar(
                child: Text(activity.user.name?[0].toUpperCase() ?? ''),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.user.name ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (!isFollowing && activity.user.id != currentUserId)
                        TextButton(
                          onPressed: () => onFollow(activity.currentFeed!.fid),
                          child: Text(
                            'Follow',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      if (isFollowing && activity.user.id != currentUserId)
                        TextButton(
                          onPressed: () =>
                              onUnfollow(activity.currentFeed!.fid),
                          child: Text(
                            'Unfollow',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  Text(activity.text ?? ''),
                  ...activity.attachments
                      .where((attachment) => attachment.imageUrl != null)
                      .map(
                        (attachment) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(attachment.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.width * 0.5,
                            minWidth: double.infinity,
                          ),
                        ),
                      ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: onCommentPressed,
                        icon: Icon(Icons.comment),
                        label: Text(activity.commentCount.toString()),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onLikePressed,
                        icon: Icon(Icons.favorite),
                        label: Text(activity.reactionCount.toString()),
                        style: TextButton.styleFrom(
                          foregroundColor: activity.ownReactions.isEmpty
                              ? Colors.black54
                              : Colors.red,
                        ),
                      ),
                    ],
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
