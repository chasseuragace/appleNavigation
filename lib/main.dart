import 'package:apple_clone/animated_list/animated_child.dart';
import 'package:apple_clone/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apple Clone',
      theme: myTheme,
      home: Wrapper(),
    );
  }
}

class Wrapper extends StatelessWidget {
  Wrapper({
    Key? key,
  }) : super(key: key);

  late ValueNotifier<List<String>> suggestions = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: HomePage(
            searchInBackground: (String query) async {
              suggestions.value = ['Searching for $query'];
              await Future.delayed(Duration(seconds: 2));
              suggestions.value = [
                'yeauta yo ${UniqueKey()} $query',
                'aarko yo${UniqueKey()}'
              ];
              return 0;
            },
            onQueryUpdate: (String query) async {
              final previous =
                  suggestions.value.map((e) => e.toString()).toList();
              suggestions.value = (previous..add(query));
              return 0;
            },
            // onVoiceQueryUpdate: (String query) {
            //   final previous =
            //       suggestions.value.map((e) => e.toString()).toList();
            //   suggestions.value = (previous..add(query));
            // },
            suggestionChannel: suggestions,
            onTabChange: (int index) {},
            tabs: [
              HomePageTabs(
                  page: Text('page1'),
                  label: 'Fast Foof',
                  onTap: () {
                    print('malai theexho');
                  }),
              HomePageTabs(
                  page: Text('page2'),
                  label: 'Electronics ',
                  onTap: () async {
                    print('malai theexho2');
                  }),
              HomePageTabs(
                  page: Text('page2'),
                  label: "Men's wear",
                  onTap: () async {
                    print('malai theexho2');
                  }),
              HomePageTabs(
                  page: Text('page2'),
                  label: 'Kurtha Set ',
                  onTap: () async {
                    print('malai theexho2');
                  })
            ],
          ),
        ),
        MaterialButton(
            onPressed: () {
              if (false) {
                final previous =
                    suggestions.value.map((e) => e.toString()).toList();
                suggestions.value = (previous..add("skdj"));
              } else {
                suggestions.value = ["A new list ${UniqueKey()}"];
              }
            },
            child: const Text('sdsd'))
      ],
    );
  }
}

class HomePageTabs {
  final Widget page;
  final String label;
  void Function()? onTap;
  void Function(String query)? onSearchQueeryChange;

  HomePageTabs({
    required this.page,
    required this.label,
    this.onTap,
  });
}

class HomePage extends StatefulWidget {
  final List<HomePageTabs> tabs;
  Null Function(int index)? onTabChange;
  Future<dynamic> Function(String query) onQueryUpdate;
  ValueNotifier<List<String>> suggestionChannel;
  Future<dynamic> Function(String query)? searchInBackground;
  HomePage(
      {Key? key,
      required this.tabs,
      this.onTabChange,
      required this.suggestionChannel,
      required this.onQueryUpdate,
      this.searchInBackground})
      : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerReversed;
  final FocusNode _node = FocusNode();
  late final List<String> texts;
  late final ValueNotifier<int> currentPageIndexNotifier;
  bool shouldCancleSearch = false;
  final TextEditingController _searchQueryController =
      TextEditingController(text: '');
  @override
  void initState() {
    if (widget.searchInBackground != null) {
      _searchQueryController.addListener(() {
        _backgroungSuggestionFetch(_searchQueryController.text);
      });
    }
    _pageController = PageController();
    currentPageIndexNotifier = ValueNotifier<int>(0);
    texts = widget.tabs.map((e) => e.label).toList();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _controllerReversed = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _play();
    _node.addListener(() {
      if (!_node.hasFocus && shouldCancleSearch) {
        _cancleSearch();
      }
    });
    _pageController.addListener(() {
      if (currentPageIndexNotifier.value !=
          (_pageController.page?.ceil() ?? 0)) {
        currentPageIndexNotifier.value = _pageController.page?.ceil() ?? 0;
      }
    });
    super.initState();
  }

  _cancleSearch() {
    shouldCancleSearch = false;
    _play();
  }

  ValueNotifier<bool> showSearch = ValueNotifier<bool>(false);

  final heightOffset = 50.0;
  late final PageController _pageController;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onTap: () {
              shouldCancleSearch = true;
              FocusScope.of(context).unfocus();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.grey.shade300,
              child: Column(
                children: [
                  SizedBox(
                    height: heightOffset,
                  ),
                  Expanded(
                    child: Scaffold(
                      body: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: [...widget.tabs.map((e) => e.page)],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _cancleSearch();
            },
            child: Container(
              /*     decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Color(0xFF291D52), Colors.deepPurple])),*/
              height: heightOffset,
              padding: const EdgeInsets.all(8),
              //color: Theme.of(context).primaryColor,
              //color: Colors.black,
              color: Color(0xFF291D52),
              child: CustomAnimatedList.row(
                children: texts.map(_textBuilder).toList().toAnimatedChildren()
                  ..add(AnimatedChild(
                      child: GestureDetector(
                    onTap: () {
                      _reverse();
                    },
                    child: const Icon(
                      Icons.search,
                      size: 20,
                    ),
                  ))),
                controller: _controller,
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: showSearch,
              builder: (_, b, w) => AnimatedSwitcher(
                    switchInCurve: Curves.easeOut,
                    reverseDuration: const Duration(
                      milliseconds: 100,
                    ),
                    duration: const Duration(seconds: 2),
                    child: b
                        ? _showSearch()
                        : SizedBox.shrink(
                            key: UniqueKey(),
                          ),
                  )

              //
              ),
          Positioned(
            top: heightOffset,
            child: ValueListenableBuilder<bool>(
                valueListenable: showSearch,
                builder: (_, b, w) => AnimatedSwitcher(
                      reverseDuration: const Duration(
                        milliseconds: 100,
                      ),
                      duration: const Duration(milliseconds: 400),
                      child: b
                          ? Material(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              elevation: 26,
                              child: SizedBox(
                                width: width(context),
                                //height: 250,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: buildSuggestions(),
                                ),
                              ),
                            )
                          : SizedBox.shrink(
                              key: UniqueKey(),
                            ),
                    )

                //
                ),
          ),
        ],
      ),
    );
  }

  Column buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<List<String>>(
            valueListenable: widget.suggestionChannel,
            builder: (c, val, s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      val.isNotEmpty ? 'Search result' : "Quick Links",
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(letterSpacing: 1),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 18),
                        child: CustomAnimatedList.column(
                            useSlide: true,
                            children: ((val.isNotEmpty &&
                                        _searchQueryController.text.isNotEmpty)
                                    ? val
                                    : ['Something ', 'relevant'])
                                .map((e) => Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      e,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    )))
                                .toList()
                                .toAnimatedChildren(),
                            controller: _controllerReversed)),
                  ],
                )),
      ],
    );
  }

  Widget _textBuilder(String text) {
    var currentindex =
        widget.tabs.indexWhere((element) => element.label == text);
    return TextButton(
      onPressed: () {
        var currentindex =
            widget.tabs.indexWhere((element) => element.label == text);
        widget.tabs.singleWhere((element) => element.label == text).onTap!();
        _pageController.jumpToPage(currentindex);
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: currentPageIndexNotifier,
              builder: (c, p, ch) => Column(
                children: [
                  Text(text,
                      style: p != currentindex
                          ? Theme.of(context).primaryTextTheme.subtitle2
                          : Theme.of(context)
                              .primaryTextTheme
                              .subtitle2
                              ?.copyWith(color: Colors.white.withOpacity(.7))),
                  SizedBox(
                    height: 10,
                    child: ValueListenableBuilder(
                        valueListenable: currentPageIndexNotifier,
                        builder: (c, p, ch) => AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 200,
                              ),
                              child: p == currentindex
                                  ? const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 2,
                                    )
                                  : const SizedBox.shrink(),
                            )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  double width(BuildContext context) => MediaQuery.of(context).size.width * .6;
  Widget _showSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _node.requestFocus();
    });
    return SizedBox(
      width: width(context),
      height: heightOffset,
      child: _makeSlideTween(context,
          curve: Curves.easeInOutCirc,
          initialOffset: const Offset(260, 0),
          milliseconds: 600,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.search),
              ),
              Expanded(
                child: Padding(
                  //color: Colors.red,
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextField(
                    controller: _searchQueryController,
                    onSubmitted: (query) async {
                      isWorkingOnBackground = true;
                      await widget.onQueryUpdate(query);
                      isWorkingOnBackground = false;
                    },
                    focusNode: _node,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                        // contentPadding: const EdgeInsets.all(2),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintText: "Search everything here",
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                ),
              )
            ],
          )),
    );
  }

  _play() {
    showSearch.value = false;
    _controller.forward();
    _controllerReversed.reverse();
  }

  _reverse() {
    showSearch.value = true;
    _controller.reverse();
    _controllerReversed.forward();
  }

  String lastSearchedkeywordInbackGround = '';
  bool isWorkingOnBackground = false;
  void _backgroungSuggestionFetch(String text) {
    var currentText = _searchQueryController.text;

    if (currentText.trim().isEmpty) {
      widget.suggestionChannel.value = <String>[];
      lastSearchedkeywordInbackGround = '';
      isWorkingOnBackground = false;
    }
    Future.delayed(Duration(seconds: 1), () async {
      if (_searchQueryController.text.trim() != '' &&
          _searchQueryController.text == currentText &&
          !isWorkingOnBackground &&
          lastSearchedkeywordInbackGround !=
              _searchQueryController.text.trim()) {
        isWorkingOnBackground = true;
        lastSearchedkeywordInbackGround = _searchQueryController.text;
        //  print("searching ${_textEditingController.text}");
        await widget.searchInBackground!(_searchQueryController.text.trim());
        isWorkingOnBackground = false;
      }
    });
  }
}

Widget _makeSlideTween(BuildContext context,
    {required Widget child,
    required int milliseconds,
    required Offset initialOffset,
    Cubic curve = Curves.ease}) {
  return TweenAnimationBuilder<Offset>(
      curve: curve,
      tween: Tween<Offset>(begin: initialOffset, end: Offset.zero),
      duration: Duration(milliseconds: milliseconds),
      builder: (_, value, child) => Transform.translate(
            offset: value,
            child: child,
          ),
      child: child);
}

Widget _makeScaleTween(
  BuildContext context, {
  required Widget child,
  required int milliseconds,
}) {
  return TweenAnimationBuilder<double>(
    curve: Curves.easeInCubic,
    tween: Tween<double>(begin: 0, end: 1),
    duration: Duration(milliseconds: milliseconds),
    builder: (_, value, child) => Transform.scale(
      scale: value,
      child: child,
    ),
    child: child,
  );
}
