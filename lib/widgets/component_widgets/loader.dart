import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Loader extends StatefulWidget {
  Color loaderColor;
  Color bgColor;
  Loader({this.loaderColor, this.bgColor});
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Opacity(
        opacity: 0.5,
        child: ModalBarrier(dismissible: false, color: widget.bgColor),
      ),
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 65,
              width: 65,
              child: LoadingIndicator(
                  indicatorType: Indicator.values[12],
                  color: widget.loaderColor),
            ),
          ],
        ),
      ),
    ]);
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class Loader extends StatelessWidget {
//   Loader(
//       {Key key,
//       this.opacity: 0.5,
//       this.isCustom: false,
//       this.dismissibles: false,
//       this.color: Colors.black,
//       this.loadingTxt: 'Loading...'})
//       : super(key: key);

//   final bool isCustom;
//   final double opacity;
//   final bool dismissibles;
//   final Color color;
//   final String loadingTxt;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Opacity(
//           opacity: opacity,
//           child: const ModalBarrier(dismissible: false, color: Colors.black),
//         ),
//         Center(
//             child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               child: isCustom
//                   ? Container(
//                       width: 30,
//                       height: 30,
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.only(top: 10),
//                       decoration: new BoxDecoration(
//                         image: new DecorationImage(
//                           image: new AssetImage("assets/spinner.gif"),
//                         ),
//                       ),
//                     )
//                   : Container(
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.only(top: 10),
//                       child: CircularProgressIndicator(),
//                     ),
//             ),
//             Container(
//               margin: const EdgeInsets.only(top: 5),
//               child: Text(loadingTxt,
//                   style: TextStyle(color: Colors.white70, fontSize: 18)),
//             ),
//           ],
//         )),
//       ],
//     );
//   }
// }
