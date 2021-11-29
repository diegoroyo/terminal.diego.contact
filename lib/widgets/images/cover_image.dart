import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';

class CoverImage extends StatelessWidget {
  final String title;
  final AssetImage image;
  final bool showTitle;

  CoverImage(
      {Key? key,
      required this.title,
      required String imageString,
      this.showTitle = false})
      : image = AssetImage(TerminalAssets.projectImage(imageString)),
        super(key: key);

  CoverImage.fromContext({Key? key, required RenderContext context})
      : this(
            key: key,
            title: context.tree.element!.attributes['title']!,
            imageString: context.tree.element!.attributes['image']!);

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      height: 100.0,
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover, image: image),
      ),
      child: showTitle
          ? Center(child: Text(title, style: TerminalStyle.monospaced()))
          : Container());
}
