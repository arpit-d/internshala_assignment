import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internshala_assignment/model.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Size s;
  Future<Size> _calculateImageDimension() {
    Completer<Size> completer = Completer();
    Image image = Image.asset("assets/testinv.jpeg");
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  @override
  void initState() {
    _calculateImageDimension().then((size) {
      setState(() {
        s = size;
        print(s.toString());
      });
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: FutureBuilder(
            future: DefaultAssetBundle.of(context)
                .loadString('assets/imagetotext.json'),
            builder: (context, snapshot) {
              if (!(snapshot.connectionState == ConnectionState.done)) {
                return CircularProgressIndicator();
              }

              var t = json.decode(snapshot.data);
              List l = (t['responses'][0]['textAnnotations']);
              
             
              return Stack(
                children: [
                  CustomPaint(
                    foregroundPainter: PainterClass(s,l),
                    child: Container(
                      child: Image.asset('assets/testinv.jpeg'),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class PainterClass extends CustomPainter {
  PainterClass(this.absoluteImageSize, this.l);

  final Size absoluteImageSize;
  final List l;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(l) {
      return Rect.fromLTRB(
        l.boundingBox.left * scaleX,
        l.boundingBox.top * scaleY,
        l.boundingBox.right * scaleX,
        l.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (var i in l) {
      canvas.drawRect(scaleRect(i), paint);  
    }
  }

  @override
  bool shouldRepaint(PainterClass oldDelegate) {
    return true;
  }
}
