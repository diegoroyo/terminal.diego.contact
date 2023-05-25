import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/window_callbacks.dart';
import 'package:terminal/widgets/buttons/animated_elevated_button.dart';

class ProjectButton extends StatefulWidget {
  final WindowCallbacks windowCallbacks;
  final String id;
  final ImageProvider image;
  final String description;
  final Color color;

  ProjectButton(
      {Key? key,
      required this.windowCallbacks,
      required this.id,
      required String imageString,
      required this.description,
      required List<int> color})
      : image = AssetImage(TerminalAssets.projectImage(imageString)),
        color = Color.alphaBlend(
            Colors.black45, Color.fromARGB(255, color[0], color[1], color[2]));

  ProjectButton.fromContext(
      {Key? key,
      required RenderContext context,
      required WindowCallbacks windowCallbacks})
      : this(
            key: key,
            windowCallbacks: windowCallbacks,
            id: context.tree.element!.attributes['id']!,
            imageString: context.tree.element!.attributes['image']!,
            description: context.tree.element!.attributes['desc']!,
            color: context.tree.element!.attributes['color']!
                .split(',')
                .map(int.parse)
                .toList());

  @override
  _ProjectButtonState createState() => _ProjectButtonState(id);
}

class _ProjectButtonState extends State<ProjectButton> {
  String title, detailsFilename;

  _ProjectButtonState(String id)
      : title = TerminalAssets.PROJECT_MAP[id]!.item1,
        detailsFilename = TerminalAssets.PROJECT_MAP[id]!.item2;

  Widget buildBubbleText(
          {required String text,
          required Color color,
          FontStyle fontStyle = FontStyle.normal,
          FontWeight fontWeight = FontWeight.normal}) =>
      Container(
          padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 13.0),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38,
                    blurRadius: 3.0,
                    offset: Offset(0.0, 3.0))
              ]),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TerminalStyle.monospaced(
                  fontStyle: fontStyle, fontWeight: fontWeight)));

  @override
  Widget build(BuildContext context) => Container(
      margin: EdgeInsets.only(top: 7.0),
      child: AnimatedElevatedButton(
          color: widget.color,
          style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              side: BorderSide(color: Colors.white24, width: 2.0),
              backgroundColor: Colors.black12,
              padding: EdgeInsets.zero),
          maxElevation: 8.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          onPressed: () => widget.windowCallbacks.openWindow(
              widget.windowCallbacks.buildWindow(WindowData.html(
                  title: title, htmlFilename: detailsFilename))),
          child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      image: DecorationImage(
                        colorFilter:
                            ColorFilter.mode(Colors.black26, BlendMode.darken),
                        fit: BoxFit.cover,
                        image: widget.image,
                      )),
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  child: Center(
                      child: Column(children: [
                    buildBubbleText(
                        text: title,
                        color: Colors.black.withAlpha(180),
                        fontWeight: FontWeight.bold),
                    Container(height: 5.0),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: buildBubbleText(
                            text: widget.description,
                            color: Colors.grey[900]!.withAlpha(150))),
                  ]))))));
}
