import 'package:flutter/material.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/ui/helpers/color_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class VideoCard extends StatefulWidget {
  VideoCard({
    Key? key,
    required this.image,
    required this.title,
    required this.imageHeight,
    this.imageWidth = double.infinity,
    required this.onTap,
    this.summary,
    this.meta,
  }) : super(key: key);

  final String image;
  final double imageHeight;
  final double imageWidth;
  final String title;
  final String? summary;
  final List<String>? meta;
  final void Function() onTap;
  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  late Color cardColor;
  bool _isFlipped = false;
  double cardScale = 1;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cardColor = Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onFocusChange: (hasFocus) {
        setState(() {
          if (hasFocus) {
            cardColor = darken(cardColor);
            cardScale = 1.04;
            _isFlipped = true;
          } else {
            cardColor = Theme.of(context).cardColor;
            if (cardScale > 1) {
              cardScale = 1;
              _isFlipped = false;
            }
          }
        });
      },
      child: Stack(
        children: [
          Card(
            color: cardColor,
            child: Column(
              children: [
                FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: widget.image,
                  fit: BoxFit.cover,
                  height: widget.imageHeight,
                  width: widget.imageWidth,
                  alignment: Alignment.topCenter,
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          if (widget.meta != null || widget.summary != null)
            Visibility(
              visible: _isFlipped,
              child: Container(
                color: Theme.of(context).cardColor.withOpacity(.93),
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                      child: Text(
                        widget.summary ?? "",
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      widget.meta?.join("\n") ?? "",
                      overflow: TextOverflow.fade,
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

int cardCountCalc(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final mainWidth = width - sidebarWidth;
  return mainWidth ~/ (cardWidth);
}
