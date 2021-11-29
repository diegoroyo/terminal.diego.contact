import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:screenshot/screenshot.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';

class ScreenshotImage extends StatefulWidget {
  final String? caption;
  final double widthX, heightX;

  ScreenshotImage(
      {Key? key, required this.caption, this.widthX = 1, this.heightX = 1})
      : super(key: key);

  ScreenshotImage.fromContext({Key? key, required RenderContext context})
      : this(
            key: key,
            caption: context.tree.element!.attributes['caption'],
            widthX: double.parse(
                context.tree.element!.attributes['width-x'] ?? '1'),
            heightX: double.parse(
                context.tree.element!.attributes['height-x'] ?? '1'));

  @override
  _ScreenshotImageState createState() => _ScreenshotImageState();
}

class _ScreenshotImageState extends State<ScreenshotImage> {
  static const SIZE = 250.0;
  ImageProvider? image;
  bool imageIsLoading = false;

  void setDefaultImage() {
    // idk why screenshot does not work on mobile, lets just put a
    // placeholder there for now
    setState(() => image = AssetImage(TerminalStyle.IS_VERTICAL
        ? TerminalAssets.projectImage('terminal/backup-vertical.png')
        : TerminalAssets.projectImage('terminal/backup-horizontal.png')));
  }

  @override
  Widget build(BuildContext context) {
    if (!imageIsLoading) {
      setState(() => imageIsLoading = true);
      Screenshot screenshot =
          context.findAncestorWidgetOfExactType<Screenshot>()!;
      screenshot.controller
          .capture(pixelRatio: 0.3, delay: Duration(seconds: 1))
          .then((capturedImage) async {
        if (capturedImage != null) {
          setState(() => image = MemoryImage(capturedImage));
        } else {
          setDefaultImage();
        }
      }).onError((_, __) {
        setDefaultImage();
      });
    }
    return SizedBox(
        width: SIZE * widget.widthX,
        child: Column(
          children: [
            Center(
                child: image == null
                    ? Container(
                        width: SIZE * widget.widthX,
                        height: SIZE * widget.heightX,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.black38),
                        child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)))
                    : Image(
                        image: image!,
                        width: SIZE * widget.widthX,
                        height: SIZE * widget.heightX,
                        fit: BoxFit.contain)),
            widget.caption == null || widget.caption!.trim().isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(widget.caption!,
                        style: TerminalStyle.monospaced(),
                        textAlign: TextAlign.center)),
          ],
        ));
  }
}
