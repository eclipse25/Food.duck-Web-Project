import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
import 'drawer.dart';
import 'widget.dart'; //appBar
import 'back/data_fetch.dart';
import 'dart:html';
import 'dart:ui_web' as ui;
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';



class RenderLinkImage extends StatefulWidget {
  final src;

  const RenderLinkImage({super.key, this.src});

  @override
  _RenderLinkImageState createState() => _RenderLinkImageState();
}

class _RenderLinkImageState extends State<RenderLinkImage> {
  var randomString = getRandomString(17);
  @override
  Widget build(BuildContext context) {
    ui.platformViewRegistry.registerViewFactory(
      "link_image_instance$randomString",
      (int viewId) {
        ImageElement element = ImageElement()
          ..src = widget.src
          ..style.width = "100%"
          ..style.height = "100%"
          ..style.objectFit = "contain"
          ..style.border = "none";
        element.height = element.naturalHeight;
        element.width = element.naturalWidth;
        return element;
      },
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.height * 0.45,
      child: HtmlElementView(
        viewType: "link_image_instance$randomString",
      ),
    );
  }

  static getRandomString(len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }
}

class resultlist extends StatefulWidget {
  final Idx;
  const resultlist(this.Idx, {super.key});

  @override
  Result createState() => Result();
}

class Result extends State<resultlist> {
  var Index;
  late String storeName;
  late String menu;
  late String position;
  // String pricelevel = "1,000,000원 대";
  late String description;
  late String storeimage;
  late List<dynamic> foodtag;
  late String tagstring;
  late RenderLinkImage img;
  late Uri _url;
  late Uri maplink;

  @override
  void initState() {
    Index = widget.Idx;
    storeName = listfood[Index]["name"];
    menu = listfood[Index]["category"];
    position = listfood[Index]["address"];
    description = listfood[Index]["OneLiner"];
    storeimage = listfood[Index]["image"];
    foodtag = List.generate(listfood[Index]["tags"].length,
        (index) => '#${listfood[Index]["tags"][index]}');
    tagstring = foodtag.join(" ");
    img = RenderLinkImage(src: storeimage);
    _url = Uri.parse('https://forms.gle/J5nnWwScc6ehhUuQ6');
    maplink = Uri.parse(listfood[Index]["MapLink"]);
    super.initState();
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }


  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    //스트링 예시 리스트에서 각 변수로 넣으면 동작함
    const String letterstyle = 'NanumSquareB.ttf';
    var width = MediaQuery.of(context).size.width;

    if (width < 900) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: CustomAppBar(scaffoldKey: scaffoldKey),
        endDrawer: const SafeArea(
          child: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50)),
            ),
            child: CustomDrawer(), // CustomDrawer 위젯 사용
          ),
        ),
        body: Padding(
          //스크롤(열(컨테이너(행(가게이름,오리아이콘)),컨테이너(열(가게사진,설명,컨테이너(짧은설명문))))) 형태로 구성됨
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextScroll(
                        storeName,
                        velocity:
                            const Velocity(pixelsPerSecond: Offset(30, 0)),
                        pauseBetween: const Duration(milliseconds: 1000),
                        mode: TextScrollMode.bouncing,
                        fadedBorder: true,
                        fadeBorderVisibility: FadeBorderVisibility.auto,
                        fadeBorderSide: FadeBorderSide.right,
                        style: const TextStyle(
                          fontSize: 36,
                          fontFamily: "NanumSquare_ac",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        liked.contains(Index) ? Icons.star : Icons.star_border,
                        color: liked.contains(Index) ? Colors.yellow : null,
                        semanticLabel: liked.contains(Index)
                            ? 'Remove from saved'
                            : 'Save',
                        size: 36,
                      ),
                      onPressed: () async {
                        int flag = 0;
                        if (liked.contains(Index)) {
                          flag = 1;
                          await WriteCaches(listfood[Index]["name"], '0');
                        } else {
                          flag = 0;
                          await WriteCaches(listfood[Index]["name"], '1');
                        }
                        setState(() {
                          if (flag == 1) {
                            liked.remove(Index);
                          } else {
                            liked.add(Index);
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: img,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 23),
                        child: Text(
                          tagstring,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "NanumSquare_ac",
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.fromLTRB(23, 10, 23, 0),
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            const TextSpan(
                                text: "메뉴: ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "NanumSquare_ac",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  height: 1.5,
                                )),
                            TextSpan(
                                text: '$menu\n',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "NanumSquare_ac",
                                  fontWeight: FontWeight.w200,
                                  color: Colors.black,
                                  height: 1.5,
                                )),
                            const TextSpan(
                                text: "위치: ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "NanumSquare_ac",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  height: 1.5,
                                )),
                            TextSpan(
                                text: '$position\n',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "NanumSquare_ac",
                                  fontWeight: FontWeight.w200,
                                  color: Colors.black,
                                  height: 1.5,
                                ))
                          ]),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 120,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "NanumSquare_ac",
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _launchUrl(maplink),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent.shade200, // Text Color
                        ),
                        child: const Text(
                          '식당 위치 지도로 보기',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "NanumSquare_ac",
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap:  () => _launchUrl(_url),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(30),
                                  color: Colors.grey[400],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: const Text(
                                  "관리자에게 제보하기",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "NanumSquare_ac",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: CustomAppBar(scaffoldKey: scaffoldKey),
        endDrawer: const SafeArea(
          child: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50)),
            ),
            child: CustomDrawer(), // CustomDrawer 위젯 사용
          ),
        ),
        body: Padding(
          //스크롤(열(컨테이너(행(가게이름,오리아이콘)),컨테이너(열(가게사진,설명,컨테이너(짧은설명문))))) 형태로 구성됨
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextScroll(
                        storeName,
                        velocity:
                            const Velocity(pixelsPerSecond: Offset(30, 0)),
                        pauseBetween: const Duration(milliseconds: 1000),
                        mode: TextScrollMode.bouncing,
                        fadedBorder: true,
                        fadeBorderVisibility: FadeBorderVisibility.auto,
                        fadeBorderSide: FadeBorderSide.right,
                        style: const TextStyle(
                          fontSize: 36,
                          fontFamily: "NanumSquare_ac",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        liked.contains(Index) ? Icons.star : Icons.star_border,
                        color: liked.contains(Index) ? Colors.yellow : null,
                        semanticLabel: liked.contains(Index)
                            ? 'Remove from saved'
                            : 'Save',
                        size: 36,
                      ),
                      onPressed: () async {
                        int flag = 0;
                        if (liked.contains(Index)) {
                          flag = 1;
                          await WriteCaches(listfood[Index]["name"], '0');
                        } else {
                          flag = 0;
                          await WriteCaches(listfood[Index]["name"], '1');
                        }
                        setState(() {
                          if (flag == 1) {
                            liked.remove(Index);
                          } else {
                            liked.add(Index);
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.fromLTRB(12, 20, 12, 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: img,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 23),
                                child: Text(
                                  tagstring,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "NanumSquare_ac",
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin:
                                    const EdgeInsets.fromLTRB(23, 10, 23, 0),
                                child: RichText(
                                  text: TextSpan(children: <TextSpan>[
                                    const TextSpan(
                                        text: "메뉴: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "NanumSquare_ac",
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          height: 1.5,
                                        )),
                                    TextSpan(
                                        text: '$menu\n',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: "NanumSquare_ac",
                                          fontWeight: FontWeight.w200,
                                          color: Colors.black,
                                          height: 1.5,
                                        )),
                                    const TextSpan(
                                        text: "위치: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "NanumSquare_ac",
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          height: 1.5,
                                        )),
                                    TextSpan(
                                        text: '$position\n',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: "NanumSquare_ac",
                                          fontWeight: FontWeight.w200,
                                          color: Colors.black,
                                          height: 1.5,
                                        ))
                                  ]),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: 120,
                                margin:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                child: Text(
                                  description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: "NanumSquare_ac",
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _launchUrl(maplink),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent.shade200, // Text Color
                                ),
                                child: const Text(
                                  '식당 위치 지도로 보기',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "NanumSquare_ac",
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap:  () => _launchUrl(_url),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.grey[400],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: const Text(
                                          "관리자에게 제보하기",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: "NanumSquare_ac",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ),
      );
    }
  }
}
