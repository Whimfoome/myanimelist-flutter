import 'package:flutter/material.dart';
import 'package:myanimelist/constants.dart';
import 'package:myanimelist/screens/anime_screen.dart';
import 'package:myanimelist/screens/character_screen.dart';
import 'package:myanimelist/screens/manga_screen.dart';
import 'package:myanimelist/screens/person_screen.dart';

class SubtitleAnime extends StatelessWidget {
  const SubtitleAnime(this.id, this.title, this.subtitle, this.image, {this.type = ItemType.anime});

  final int id;
  final String title;
  final String subtitle;
  final String image;
  final ItemType type;
  final double width = kImageWidthM;
  final double height = kImageHeightM;

  @override
  Widget build(BuildContext context) {
    return Ink.image(
      image: NetworkImage(image),
      width: width,
      height: height,
      fit: BoxFit.cover,
      child: InkWell(
        onTap: () {
          switch (type) {
            case ItemType.anime:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimeScreen(id, title),
                  settings: RouteSettings(name: 'AnimeScreen'),
                ),
              );
              break;
            case ItemType.manga:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaScreen(id, title),
                  settings: RouteSettings(name: 'MangaScreen'),
                ),
              );
              break;
            case ItemType.people:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonScreen(id),
                  settings: RouteSettings(name: 'PersonScreen'),
                ),
              );
              break;
            case ItemType.characters:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterScreen(id),
                  settings: RouteSettings(name: 'CharacterScreen'),
                ),
              );
              break;
            default:
              throw 'ItemType Error';
          }
        },
        child: title != ''
            ? Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  Image.asset('images/box_shadow.png', width: width, height: 40.0, fit: BoxFit.cover),
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: kTextStyleShadow,
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white60, fontSize: 10.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }
}
