import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:jikan_api/jikan_api.dart';
import 'package:myanimelist/constants.dart';
import 'package:myanimelist/models/user_data.dart';
import 'package:myanimelist/screens/person_screen.dart';
import 'package:myanimelist/widgets/top/custom_view.dart';
import 'package:myanimelist/widgets/top/rank_image.dart';
import 'package:provider/provider.dart';

class TopPeopleScreen extends StatelessWidget {
  final Jikan jikan = Jikan();
  final NumberFormat f = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top People'),
        actions: <Widget>[CustomView()],
      ),
      body: Scrollbar(
        child: Provider.of<UserData>(context).gridView
            ? PagewiseGridView.extent(
                pageSize: kDefaultPageSize,
                maxCrossAxisExtent: kImageWidthM,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: kImageWidthM / kImageHeightM,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, top, index) => RankImage(top, index, type: ItemType.people),
                pageFuture: (pageIndex) => jikan.getTopPeople(page: pageIndex! + 1),
              )
            : PagewiseListView(
                pageSize: kDefaultPageSize,
                itemBuilder: _itemBuilder,
                padding: const EdgeInsets.all(12.0),
                pageFuture: (pageIndex) => jikan.getTopPeople(page: pageIndex! + 1),
              ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Person top, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonScreen(top.malId),
            settings: RouteSettings(name: 'PersonScreen'),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Image.network(
                    top.imageUrl,
                    width: kImageWidthS,
                    height: kImageHeightS,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      '${index + 1}. ${top.name}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        f.format(top.favorites),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Icon(Icons.person, color: Colors.grey),
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
