import 'package:flutter/material.dart';
import 'package:jikan_dart/jikan_dart.dart';
import 'package:built_collection/built_collection.dart' show BuiltList;
import 'package:myanimelist/screens/anime_screen.dart';
import 'package:myanimelist/widgets/profile/custom_filter.dart';

class AnimeListScreen extends StatelessWidget {
  AnimeListScreen(this.username, {this.order});

  final String username;
  final String order;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime List'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All Anime'),
              Tab(text: 'Currently Watching'),
              Tab(text: 'Completed'),
              Tab(text: 'On Hold'),
              Tab(text: 'Dropped'),
              Tab(text: 'Plan to Watch'),
            ],
          ),
          actions: <Widget>[CustomFilter(username, 'anime')],
        ),
        body: TabBarView(
          children: [
            UserAnimeList(username, type: AllAnimeListType(), order: order),
            UserAnimeList(username, type: WatchingAnimeListType(), order: order),
            UserAnimeList(username, type: CompletedAnimeListType(), order: order),
            UserAnimeList(username, type: OnHoldAnimeListType(), order: order),
            UserAnimeList(username, type: DroppedAnimeListType(), order: order),
            UserAnimeList(username, type: PlanToWatchAnimeListType(), order: order),
          ],
        ),
      ),
    );
  }
}

class UserAnimeList extends StatefulWidget {
  UserAnimeList(this.username, {this.type, this.order});

  final String username;
  final MangaAnimeListType type;
  final String order;

  @override
  _UserAnimeListState createState() => _UserAnimeListState();
}

class _UserAnimeListState extends State<UserAnimeList> with AutomaticKeepAliveClientMixin<UserAnimeList> {
  Future<BuiltList<AnimeItem>> _future;

  Color statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green[600];
        break;
      case 2:
        return Colors.blue[900];
        break;
      case 3:
        return Colors.yellow[700];
        break;
      case 4:
        return Colors.red[900];
        break;
      case 6:
        return Colors.grey[400];
        break;
      default:
        throw 'AnimeStatus Error';
    }
  }

  @override
  void initState() {
    super.initState();
    _future = JikanApi().getUserAnimeList(widget.username, widget.type, order: widget.order);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }

        BuiltList<AnimeItem> animeList = snapshot.data;
        return Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              AnimeItem item = animeList.elementAt(index);
              String score = item.score == 0 ? '-' : item.score.toString();
              String watched = item.watchedEpisodes == 0 ? '-' : item.watchedEpisodes.toString();
              String total = item.totalEpisodes == 0 ? '-' : item.totalEpisodes.toString();
              String progress = watched == total ? total : '$watched / $total';
              return InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Container(color: statusColor(item.watchingStatus), width: 5.0, height: 70.0),
                            Image.network(item.imageUrl, width: 50.0, height: 70.0, fit: BoxFit.cover),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(item.title, style: Theme.of(context).textTheme.subtitle),
                                  Text(item.type + ' ($progress eps)', style: Theme.of(context).textTheme.caption),
                                ],
                              ),
                            ),
                            Text(score, style: Theme.of(context).textTheme.subhead),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnimeScreen(item.malId, item.title)));
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
