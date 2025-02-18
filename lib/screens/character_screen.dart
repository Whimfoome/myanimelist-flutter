import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:jikan_api/jikan_api.dart';
import 'package:myanimelist/constants.dart';
import 'package:myanimelist/widgets/profile/about_section.dart';
import 'package:myanimelist/widgets/profile/picture_list.dart';
import 'package:myanimelist/widgets/subtitle_anime.dart';
import 'package:myanimelist/widgets/title_anime.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen(this.id);

  final int id;

  @override
  _CharacterScreenState createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  final Jikan jikan = Jikan();
  final NumberFormat f = NumberFormat.decimalPattern();

  late ScrollController _scrollController;
  late Character character;
  late BuiltList<Picture> pictures;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  void load() async {
    final Trace characterTrace = FirebasePerformance.instance.newTrace('character_trace');
    characterTrace.start();
    character = await jikan.getCharacter(widget.id);
    pictures = await jikan.getCharacterPictures(widget.id);
    characterTrace.stop();
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
          title: _showTitle ? Text(character.name) : null,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: kSliverAppBarPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Image.network(
                          character.imageUrl,
                          width: kSliverAppBarWidth,
                          height: kSliverAppBarHeight,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AutoSizeText(
                              character.name,
                              style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                              maxLines: 2,
                            ),
                            character.nameKanji != null
                                ? AutoSizeText(
                                    character.nameKanji!,
                                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                    maxLines: 1,
                                  )
                                : Container(),
                            SizedBox(height: 24.0),
                            Row(
                              children: <Widget>[
                                Icon(Icons.person, color: Colors.white, size: 20.0),
                                SizedBox(width: 4.0),
                                Text(
                                  f.format(character.favorites),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
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
            AboutSection(character.about),
            character.anime!.isNotEmpty ? AnimeographyList(character.anime!, type: ItemType.anime) : Container(),
            character.manga!.isNotEmpty ? AnimeographyList(character.manga!, type: ItemType.manga) : Container(),
            character.voices!.isNotEmpty ? VoiceList(character.voices!) : Container(),
            pictures.isNotEmpty ? PictureList(pictures) : Container(),
          ]),
        ),
      ]),
    );
  }
}

class AnimeographyList extends StatelessWidget {
  const AnimeographyList(this.list, {required this.type});

  final BuiltList<dynamic> list;
  final ItemType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(height: 0.0),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 12.0),
          child: Text(
            type == ItemType.anime ? 'Animeography' : 'Mangaography',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        SizedBox(
          height: kImageHeightM,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              dynamic anime = list.elementAt(index);
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: TitleAnime(
                  anime.malId,
                  anime.title,
                  anime.imageUrl,
                  width: kImageWidthM,
                  height: kImageHeightM,
                  type: type,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.0),
      ],
    );
  }
}

class VoiceList extends StatelessWidget {
  const VoiceList(this.list);

  final BuiltList<PersonMeta> list;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(height: 0.0),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 12.0),
          child: Text('Voice Actors', style: Theme.of(context).textTheme.headline6),
        ),
        SizedBox(
          height: kImageHeightM,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              PersonMeta person = list.elementAt(index);
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: SubtitleAnime(
                  person.malId,
                  person.name,
                  person.language!,
                  person.imageUrl,
                  type: ItemType.people,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.0),
      ],
    );
  }
}
