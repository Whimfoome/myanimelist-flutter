import 'package:flutter/material.dart';
import 'package:myanimelist/constants.dart';
import 'package:myanimelist/screens/anime_screen.dart';
import 'package:myanimelist/screens/character_screen.dart';
import 'package:myanimelist/screens/manga_screen.dart';
import 'package:myanimelist/screens/person_screen.dart';

class TitleAnime extends StatelessWidget {
  const TitleAnime(this.id, this.title, this.image,
      {this.width = kImageWidthL, this.height = kImageHeightL, this.type = ItemType.anime, this.showTitle = true});

  final int id;
  final String title;
  final String image;
  final double width;
  final double height;
  final ItemType type;
  final bool showTitle;

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
        child: title != '' && showTitle
            ? Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  Image.asset('images/box_shadow.png', width: width, height: 40.0, fit: BoxFit.cover),
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: kTextStyleShadow,
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
