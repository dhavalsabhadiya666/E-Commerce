import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomImage extends StatelessWidget {
  final String imgURL;
  final String placeholderImg;
  final double height;
  final double width;
  final BoxFit fit;

  CustomImage({
    @required this.imgURL,
    this.height,
    this.width,
    this.placeholderImg = "assets/images/no_image.jpg",
    this.fit = BoxFit.cover,
  });

  Widget _buildCacheImage() {
    return (imgURL.isEmpty || imgURL == null)
        ? Container(
            color: Color(0xFFEEF0F2),
            child: Image.asset(
              placeholderImg,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
            ),
          )
        : CachedNetworkImage(
            imageUrl: imgURL,
            placeholder: (context, url) => Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: SpinKitCircle(
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
            errorWidget: (context, url, error) => Image.asset(
              placeholderImg,
              fit: BoxFit.cover,
              height: height,
              width: width,
            ),
            fit: fit,
            height: height,
            width: width,
          );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCacheImage();
  }
}
