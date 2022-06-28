import 'package:flutter/material.dart';
import 'package:tinycinema/config.dart';
import 'package:tinycinema/types.dart';
import 'package:tinycinema/ui/helpers/color_utils.dart';
import 'package:tinycinema/ui/pages/single_page.dart';
import 'package:transparent_image/transparent_image.dart';

class VideoCard extends StatefulWidget {
  VideoCard({
    Key? key,
    required this.image,
    required this.title,
    required this.imageHeight,
    required this.slug,
    this.imageWidth = double.infinity,
    this.summary,
    this.meta,
    this.websiteType,
    this.websiteKey,
  }) : super(key: key);

  final String image, title, slug;
  final double imageHeight;
  final double imageWidth;
  final String? summary, websiteKey;
  final List<String>? meta;
  final WebsiteType? websiteType;

  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  late Color cardColor;
  bool hasFocus = false;

  onFocusChanged(_hasFocus) {
    setState(() {
      hasFocus = _hasFocus;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cardColor = Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor() {
      if (!hasFocus) return Colors.transparent;
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.grey[700]!;
    }

    return InkWell(
      focusColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed(
          "/singlepage",
          arguments: SinglePageArgs(
              widget.title, widget.image, widget.slug, widget.websiteType!),
        );
      },
      onFocusChange: onFocusChanged,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1.5,
              color: borderColor(),
            ),
            borderRadius: BorderRadius.circular(5)),
        child: Card(
          color: hasFocus ? darken(cardColor, .1) : cardColor,
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
                margin: EdgeInsets.all(7),
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
      ),
    );
  }
}

int cardCountCalc(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final mainWidth = width - sidebarWidth;
  return mainWidth ~/ (cardWidth);
}
