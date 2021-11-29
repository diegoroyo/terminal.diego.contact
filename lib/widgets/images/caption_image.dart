import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';

class CaptionImage extends StatelessWidget {
  static const SIZE = 250.0;
  final String? caption;
  final AssetImage image;
  final double widthX, heightX;

  CaptionImage(
      {Key? key,
      required this.caption,
      required String imageString,
      this.widthX = 1,
      this.heightX = 1})
      : image = AssetImage(TerminalAssets.projectImage(imageString)),
        super(key: key);

  CaptionImage.fromContext({Key? key, required RenderContext context})
      : this(
            key: key,
            caption: context.tree.element!.attributes['caption'],
            imageString: context.tree.element!.attributes['image']!,
            widthX: double.parse(
                context.tree.element!.attributes['width-x'] ?? '1'),
            heightX: double.parse(
                context.tree.element!.attributes['height-x'] ?? '1'));

  @override
  Widget build(BuildContext context) => SizedBox(
      width: SIZE * widthX,
      child: Column(
        children: [
          Center(
              child: Image(
                  image: image,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    if (frame != null) {
                      return child;
                    }
                    return Container(
                        width: SIZE * widthX,
                        height: SIZE * heightX,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.black38),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.white)));
                  },
                  width: SIZE * widthX,
                  height: SIZE * heightX,
                  fit: BoxFit.contain)),
          caption == null || caption!.trim().isEmpty
              ? Container()
              : Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Text(caption!,
                      style: TerminalStyle.monospaced(),
                      textAlign: TextAlign.center)),
        ],
      ));
}
