import 'package:flutter/material.dart';
import 'back/data_fetch.dart';
import 'package:korea_regexp/korea_regexp.dart';
import 'result_page.dart';
import 'not_found.dart';
import 'widget.dart';
import 'drawer.dart';

class SearchTag extends StatefulWidget {
  const SearchTag({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchTag> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    WriteCaches('recentSearches', recentSearches.join('\n'));
    _searchController.dispose();
    super.dispose();
  }

  void clickTagBottons(int tag) {
    setState(() {
      // selectedTags = []; //[](빈 리스트)로 수정 예정
      // for (int i = 0; i < isSelected.length; i++) {
      //   if (isSelected[i]) {
      //     selectedTags.add(tags[i].substring(0)); //#제외
      //   }else{
      //     selectedTags.remove(tags[i].substring(0));
      //   }
      // }
      if (isSelected[tag]) {
        selectedTags.add(tags[tag]);
      } else {
        selectedTags.remove(tags[tag]);
      }
    });
  }

  void clickCategoryBottons(int cate) {
    setState(() {
      // selectedCates = []; //[](빈 리스트)로 수정 예정
      // for (int i = 0; i < isSelectedCate.length; i++) {
      //   if (isSelectedCate[i]) {
      //     selectedCates.add(cate[i].substring(0)); //#제외
      //   }else{
      //     selectedCates.remove(cate[i].substring(0));
      //   }
      // }
      if (isSelectedCate[cate]) {
        selectedCates.add(categorys[cate]);
      } else {
        selectedCates.remove(categorys[cate]);
      }
    });
  }

  List<bool> isSelected = []; //태그들 선택여부 리스트
  List<String> selectedTags = []; //선택된태그 리스트
  List<bool> isSelectedCate = []; //카테고리 선택여부 리스트
  List<String> selectedCates = []; //선택된카테고리 리스트
  String searchText = '';
  List<int> resultlist = [];

  @override
  void initState() {
    super.initState();
    isSelected = List.generate(tags.length, (index) => false); // isSelected 초기화
    isSelectedCate =
        List.generate(categorys.length, (index) => false); // isSelectedCate 초기화
    resultlist = [];
  }

  void _submitSearch() async {
    // 검색어 리스트가 5개 이상이면 가장 오래된 검색어 삭제
    if (recentSearches.length >= 5) {
      recentSearches.removeLast();
    }
    for (var element in recentSearches) {
      print(element);
    }
    setState(() {
      searchText = _searchController.text.trim();
      setState(() {
        // 최근 검색어 리스트에 새로운 검색어 추가
        if (searchText.isNotEmpty && !recentSearches.contains(searchText)) {
          recentSearches.insert(0, searchText);
        }
      });
    });
    // 최근 검색어 리스트를 캐시에 저장
    WriteCaches('recentSearches', recentSearches.join('\n'));
    // 검색 기능을 구현하는 로직을 추가

    changeSearchTerm(searchText, selectedTags, selectedCates);
    //검색어, 태그리스트, 최근검색어리스트를 다른 페이지로 넘기기
    if (resultlist.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotFound()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => searchList(resultlist, "검색 결과")),
      );
    }
  }

  List<String> tagCheck(List<String> tags, List<String> cate) {
    List<String> result = [];
    List<int> tmp = Iterable<int>.generate(listfood.length).toList();
    for (int i = 0; i < tags.length; i++) {
      tmp.removeWhere((item) => !tag[tags[i]].contains(item));
    }
    for (int i = 0; i < cate.length; i++) {
      tmp.removeWhere((item) => !category[cate[i]].contains(item));
    }
    for (int i = 0; i < tmp.length; i++) {
      result.add(listfood[tmp[i]]["name"]);
    }
    return result;
  }

  void changeSearchTerm(String text, List<String> tags, List<String> cate) {
    print("태그 $tags");
    print("카테고리 $cate");
    List<String> list = tagCheck(tags, cate);
    late List<String> terms;
    List<int> tmp = [];
    print("리스트 $list");
    if (text.isNotEmpty) {
      RegExp regExp = getRegExp(
          text,
          RegExpOptions(
            initialSearch: true,
            startsWith: false,
            endsWith: false,
            fuzzy: false,
            ignoreSpace: true,
            ignoreCase: false,
          ));
      print(regExp);
      terms = list.where((element) => regExp.hasMatch(element)).toList();
      print(terms);
      for (var i in terms) {
        tmp.add(name[i]);
      }

      var catlist = category.keys.toList();
      List<dynamic> textcat =
          catlist.where((element) => regExp.hasMatch(element)).toList();
      for (var i in textcat) {
        for (var idx in category[i]) {
          if (!tmp.contains(idx)) {
            tmp.add(idx);
          }
        }
      }
      var taglist = tag.keys.toList();
      List<dynamic> texttag =
          taglist.where((element) => regExp.hasMatch(element)).toList();
      for (var i in texttag) {
        for (var idx in tag[i]) {
          if (!tmp.contains(idx)) {
            tmp.add(idx);
          }
        }
      }
      resultlist = tmp;
    } else {
      for (var restaurantname in list) {
        tmp.add(name[restaurantname]);
      }
      resultlist = tmp;
    }
    print("idx $resultlist");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      endDrawer: const SafeArea(
        child: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), bottomLeft: Radius.circular(50)),
          ),
          child: CustomDrawer(), // CustomDrawer 위젯 사용
        ),
      ),
      body: ListView(
        children: [
          const titleSection("태그 검색"),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Column(
                  children: [
                    // 태그 선택하는 박스
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          children: [
                            // 메뉴 선택 줄
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '메뉴',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "NanumSquare_ac",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          spacing: 15,
                                          runSpacing: 10,
                                          children: [
                                            for (int i = 0;
                                                i < categorys.length;
                                                i++)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                  color: isSelectedCate[i]
                                                      ? Colors.amber[300]
                                                      : Colors.grey[200],
                                                  border: Border.all(
                                                    color: isSelectedCate[i]
                                                        ? const Color.fromARGB(
                                                            255, 255, 213, 79)
                                                        : const Color.fromARGB(
                                                            255, 238, 238, 238),
                                                    width: 3,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    isSelectedCate[i] =
                                                        !isSelectedCate[i];
                                                    clickCategoryBottons(i);
                                                  },
                                                  child: Text(
                                                    categorys[i],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily:
                                                          "NanumSquare_ac",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 장소 선택 줄
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '장소',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "NanumSquare_ac",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          spacing: 15,
                                          runSpacing: 10,
                                          children: [
                                            for (int i = 0;
                                                i < categorys.length;
                                                i++)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                  color: isSelectedCate[i]
                                                      ? Colors.amber[300]
                                                      : Colors.grey[200],
                                                  border: Border.all(
                                                    color: isSelectedCate[i]
                                                        ? const Color.fromARGB(
                                                            255, 255, 213, 79)
                                                        : const Color.fromARGB(
                                                            255, 238, 238, 238),
                                                    width: 3,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    isSelectedCate[i] =
                                                        !isSelectedCate[i];
                                                    clickCategoryBottons(i);
                                                  },
                                                  child: Text(
                                                    categorys[i],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily:
                                                          "NanumSquare_ac",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 가격대 선택 줄
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '가격대',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "NanumSquare_ac",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          spacing: 15,
                                          runSpacing: 10,
                                          children: [
                                            for (int i = 0;
                                                i < categorys.length;
                                                i++)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                  color: isSelectedCate[i]
                                                      ? Colors.amber[300]
                                                      : Colors.grey[200],
                                                  border: Border.all(
                                                    color: isSelectedCate[i]
                                                        ? const Color.fromARGB(
                                                            255, 255, 213, 79)
                                                        : const Color.fromARGB(
                                                            255, 238, 238, 238),
                                                    width: 3,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    isSelectedCate[i] =
                                                        !isSelectedCate[i];
                                                    clickCategoryBottons(i);
                                                  },
                                                  child: Text(
                                                    categorys[i],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily:
                                                          "NanumSquare_ac",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 검색결과 리스트
          //Container(child: _resultList,)
        ],
      ),
    );
  }
}
