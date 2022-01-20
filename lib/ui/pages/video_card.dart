import 'package:flutter/material.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/controller/video_info_state.dart';
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
  double cardScale = 1;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cardColor = Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      onTap: widget.onTap,
      onFocusChange: (hasFocus) {
        setState(() {
          if (hasFocus) {
            videoSummary.value = widget.summary ?? "";
            videoMeta.value = widget.meta?.join("\n") ?? "";
            setState(() {
              cardColor = darken(cardColor, .1);
            });
          } else {
            videoSummary.value = "";
            videoMeta.value = "";
            setState(() {
              cardColor = Theme.of(context).cardColor;
            });
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
