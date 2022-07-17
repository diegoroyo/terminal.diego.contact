import 'package:flutter/material.dart';

class ExpandableImage extends StatelessWidget {
  final Size size;
  final ImageProvider image;

  const ExpandableImage({Key? key, required this.size, required this.image})
      : super(key: key);

  Widget buildExpandedCaption(BuildContext context) => GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Stack(children: [
        Positioned.fill(
            child: Center(
                child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: Image(
                        width: size.width * 3.0,
                        height: size.height * 3.0,
                        fit: BoxFit.contain,
                        image: image)))),
      ]));

  @override
  Widget build(BuildContext context) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (context) => buildExpandedCaption(context)),
          child: Image(
              image: image,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null) {
                  return child;
                }
                return Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black38),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)));
              },
              width: size.width,
              height: size.height,
              fit: BoxFit.cover)));
}
