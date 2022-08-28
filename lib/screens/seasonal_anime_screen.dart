import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:myanimelist/widgets/season/custom_menu.dart';
import 'package:myanimelist/widgets/season/season_list.dart';

class SeasonalAnimeScreen extends StatelessWidget {
  const SeasonalAnimeScreen({required this.year, required this.type});

  final int year;
  final String type;

  SeasonType seasonClass(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return SeasonType.spring;
      case 'summer':
        return SeasonType.summer;
      case 'fall':
        return SeasonType.fall;
      case 'winter':
        return SeasonType.winter;
      default:
        throw 'SeasonType Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$type $year'),
          bottom: TabBar(
            isScrollable: true,
            tabs: const <Tab>[
              Tab(text: 'TV'),
              Tab(text: 'ONA'),
              Tab(text: 'OVA'),
              Tab(text: 'Movie'),
              Tab(text: 'Special'),
            ],
          ),
          actions: <Widget>[CustomMenu()],
        ),
        body: FutureBuilder(
          future: Jikan().getSeason(year: year, season: seasonClass(type)),
          builder: (context, AsyncSnapshot<BuiltList<Anime>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }

            BuiltList<Anime> animeList = snapshot.data!;
            BuiltList<Anime> tv = BuiltList(animeList.where((anime) => anime.type == 'TV'));
            BuiltList<Anime> ona = BuiltList(animeList.where((anime) => anime.type == 'ONA'));
            BuiltList<Anime> ova = BuiltList(animeList.where((anime) => anime.type == 'OVA'));
            BuiltList<Anime> movie = BuiltList(animeList.where((anime) => anime.type == 'Movie'));
            BuiltList<Anime> special = BuiltList(animeList.where((anime) => anime.type == 'Special'));
            return TabBarView(
              children: <Widget>[
                SeasonList(tv),
                SeasonList(ona),
                SeasonList(ova),
                SeasonList(movie),
                SeasonList(special),
              ],
            );
          },
        ),
      ),
    );
  }
}
