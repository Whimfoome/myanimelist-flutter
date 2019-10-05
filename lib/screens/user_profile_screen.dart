import 'package:flutter/material.dart';
import 'package:jikan_dart/jikan_dart.dart';
import 'package:intl/intl.dart' show NumberFormat, DateFormat;
import 'package:built_collection/built_collection.dart' show BuiltList;
import 'package:myanimelist/screens/anime_list_screen.dart';
import 'package:myanimelist/screens/manga_list_screen.dart';
import 'package:myanimelist/widgets/profile/about_section.dart';
import 'package:myanimelist/widgets/profile/favorite_list.dart';
import 'package:myanimelist/widgets/profile/friend_list.dart';

final NumberFormat f = NumberFormat.compact();
final DateFormat date1 = DateFormat('MMM d, yy');
const kExpandedHeight = 280.0;

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen(this.username);

  final String username;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final JikanApi jikanApi = JikanApi();

  ScrollController _scrollController;
  ProfileResult profile;
  BuiltList<FriendResult> friends;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  void load() async {
    profile = await jikanApi.getUserProfile(widget.username);
    friends = await jikanApi.getUserFriends(widget.username);
    setState(() => loading = false);
  }

  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset > kExpandedHeight - kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(appBar: AppBar(), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(controller: _scrollController, slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: kExpandedHeight,
          title: _showTitle ? Text(profile.username) : null,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.network(profile.imageUrl, width: 135.0, height: 210.0, fit: BoxFit.cover),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(profile.username,
                              style: Theme.of(context).textTheme.title.copyWith(color: Colors.white)),
                          SizedBox(height: 24.0),
                          Row(
                            children: <Widget>[
                              Icon(Icons.person, color: Colors.white),
                              Text(profile.gender,
                                  style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
                            ],
                          ),
                          profile.location != null
                              ? Row(
                                  children: <Widget>[
                                    Icon(Icons.place, color: Colors.white),
                                    Text(profile.location,
                                        style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
                                  ],
                                )
                              : Container(),
                          profile.birthday != null
                              ? Row(
                                  children: <Widget>[
                                    Icon(Icons.cake, color: Colors.white),
                                    Text(date1.format(DateTime.parse(profile.birthday)),
                                        style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
                                  ],
                                )
                              : Container(),
                          Row(
                            children: <Widget>[
                              Icon(Icons.access_time, color: Colors.white),
                              Text(date1.format(DateTime.parse(profile.lastOnline)),
                                  style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.indigo[600],
                      child: Text('Anime List', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeListScreen(profile.username)));
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.indigo[600],
                      child: Text('Manga List', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MangaListScreen(profile.username)));
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0.0),
            AboutSection(profile.about),
            // TODO: Stats
            FavoriteList(profile.favorites),
            friends.length > 0 ? FriendList(friends) : Container(),
          ]),
        ),
      ]),
    );
  }
}
