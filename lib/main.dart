import 'package:flutter/material.dart';
import 'package:stream_feeds/stream_feeds.dart';

import 'activity_list_view.dart';
import 'home_page.dart';

const String apiKey = 'REPLACE_WITH_API_KEY';
const String userId = 'REPLACE_WITH_USER_ID';
const String userToken = 'REPLACE_WITH_TOKEN';
const String name = 'REPLACE_WITH_USER_NAME';

final client = StreamFeedsClient(
  apiKey: apiKey,
  user: User(id: userId, name: name),
  tokenProvider: TokenProvider.static(UserToken(userToken)),
);

Future<void> main() async {
  runApp(const Center(child: CircularProgressIndicator()));
  await client.connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream Feeds Tutorial',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;
  late final Feed userFeed;
  late final Feed timelineFeed;
  late final Feed exploreFeed;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    userFeed = client.feedFromId(FeedId.user(userId));
    await userFeed.getOrCreate();

    timelineFeed = client.feedFromId(FeedId.timeline(userId));
    await timelineFeed.getOrCreate();

    final followsSelf = timelineFeed.state.following.any(
      (follow) => follow.targetFeed.fid == userFeed.fid,
    );

    if (!followsSelf) {
      await timelineFeed.follow(targetFid: userFeed.fid);
    }

    exploreFeed = client.feedFromId(FeedId(group: 'foryou', id: userId));
    await exploreFeed.getOrCreate();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    userFeed.dispose();
    timelineFeed.dispose();
    exploreFeed.dispose();
    super.dispose();
  }

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Stream Feeds Tutorial')),
      body: _index == 0
          ? HomePage(
              client: client,
              userFeed: userFeed,
              timelineFeed: timelineFeed,
              onFollow: onFollow,
              onUnfollow: onUnfollow,
            )
          : ActivityListView(
              client: client,
              feed: exploreFeed,
              onFollow: onFollow,
              onUnfollow: onUnfollow,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        ],
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }

  Future<void> onFollow(FeedId value) async {
    await timelineFeed.follow(targetFid: value);
    await timelineFeed.getOrCreate();
    await exploreFeed.getOrCreate();
  }

  Future<void> onUnfollow(FeedId value) async {
    await timelineFeed.unfollow(targetFid: value);
    await timelineFeed.getOrCreate();
    await exploreFeed.getOrCreate();
  }
}
