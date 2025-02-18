import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:myanimelist/constants.dart';
import 'package:myanimelist/widgets/top/rank_image.dart';

class TopGrid extends StatefulWidget {
  const TopGrid({this.type, this.subtype, this.anime = true});

  final TopType? type;
  final TopSubtype? subtype;
  final bool anime;

  @override
  _TopGridState createState() => _TopGridState();
}

class _TopGridState extends State<TopGrid> with AutomaticKeepAliveClientMixin<TopGrid> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scrollbar(
      child: PagewiseGridView.extent(
        pageSize: kDefaultPageSize,
        maxCrossAxisExtent: kImageWidthM,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: kImageWidthM / kImageHeightM,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, top, index) =>
            RankImage(top, index, type: widget.anime ? ItemType.anime : ItemType.manga),
        pageFuture: (pageIndex) => widget.anime
            ? Jikan().getTopAnime(type: widget.type, subtype: widget.subtype, page: pageIndex! + 1)
            : Jikan().getTopManga(type: widget.type, subtype: widget.subtype, page: pageIndex! + 1),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
