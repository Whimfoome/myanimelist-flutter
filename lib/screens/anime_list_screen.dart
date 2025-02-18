import 'package:flutter/material.dart';
import 'package:myanimelist/constants.dart';
import 'package:myanimelist/oauth.dart';
import 'package:myanimelist/screens/anime_screen.dart';
import 'package:myanimelist/widgets/profile/custom_filter_v2.dart';

class AnimeListScreen extends StatelessWidget {
  const AnimeListScreen(this.username, {this.title, this.order, this.sort});

  final String username;
  final String? title;
  final String? order;
  final String? sort;

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
            tabs: const <Tab>[
              Tab(text: 'All Anime'),
              Tab(text: 'Currently Watching'),
              Tab(text: 'Completed'),
              Tab(text: 'On Hold'),
              Tab(text: 'Dropped'),
              Tab(text: 'Plan to Watch'),
            ],
          ),
          actions: <Widget>[CustomFilterV2(username)],
        ),
        body: FutureBuilder(
          future: MalClient().getUserList(username, sort: sort),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }

            List<dynamic> userList = snapshot.data!;
            List<dynamic> watching = userList.where((anime) => anime['list_status']['status'] == 'watching').toList();
            List<dynamic> completed = userList.where((anime) => anime['list_status']['status'] == 'completed').toList();
            List<dynamic> onHold = userList.where((anime) => anime['list_status']['status'] == 'on_hold').toList();
            List<dynamic> dropped = userList.where((anime) => anime['list_status']['status'] == 'dropped').toList();
            List<dynamic> planToWatch =
                userList.where((anime) => anime['list_status']['status'] == 'plan_to_watch').toList();
            return TabBarView(
              children: <Widget>[
                UserAnimeList(userList),
                UserAnimeList(watching),
                UserAnimeList(completed),
                UserAnimeList(onHold),
                UserAnimeList(dropped),
                UserAnimeList(planToWatch),
              ],
            );
          },
        ),
      ),
    );
  }
}

class UserAnimeList extends StatefulWidget {
  const UserAnimeList(this.userList);

  final List<dynamic> userList;

  @override
  _UserAnimeListState createState() => _UserAnimeListState();
}

class _UserAnimeListState extends State<UserAnimeList> with AutomaticKeepAliveClientMixin<UserAnimeList> {
  Color statusColor(String status) {
    switch (status) {
      case 'watching':
        return kWatchingColor;
      case 'completed':
        return kCompletedColor;
      case 'on_hold':
        return kOnHoldColor;
      case 'dropped':
        return kDroppedColor;
      case 'plan_to_watch':
        return kPlantoWatchColor;
      default:
        throw 'AnimeStatus Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.userList.isEmpty) {
      return ListTile(title: Text('No items found.'));
    }
    return Scrollbar(
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: widget.userList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = widget.userList.elementAt(index);
          String score = item['list_status']['score'] == 0 ? '-' : item['list_status']['score'].toString();
          String watched = item['list_status']['num_episodes_watched'] == 0
              ? '-'
              : item['list_status']['num_episodes_watched'].toString();
          String total = item['node']['num_episodes'] == 0 ? '-' : item['node']['num_episodes'].toString();
          String progress = item['list_status']['status'] == 'completed' ? total : '$watched / $total';
          String type = ['tv', 'ova', 'ona'].contains(item['node']['media_type'])
              ? item['node']['media_type'].toUpperCase()
              : item['node']['media_type'][0].toUpperCase() + item['node']['media_type'].substring(1);
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(color: statusColor(item['list_status']['status']), width: 5.0, height: kImageHeightS),
                        Image.network(
                          item['node']['main_picture']['large'],
                          width: kImageWidthS,
                          height: kImageHeightS,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(item['node']['title'], style: Theme.of(context).textTheme.subtitle2),
                              Text(
                                '$type ($progress eps)',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        Text(score, style: Theme.of(context).textTheme.subtitle1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimeScreen(item['node']['id'], item['node']['title']),
                  settings: RouteSettings(name: 'AnimeScreen'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
