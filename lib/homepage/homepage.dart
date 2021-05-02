import 'package:apple_clone/animated_list/animated_child.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePageTabs {
  ///[page] is the Widget that will be displayed when this tab is active
  final Widget page;

  /// [label] is the label that appears on the navigation menu
  final String label;

  /// apart from changing the tab, if you need to do anything else , you may define other actions here
  void Function()? onTap;

  HomePageTabs({
    required this.page,
    required this.label,
    this.onTap,
  });
}

class HomePage extends StatefulWidget {
  /// provide a list of [HomePageTabs]
  final List<HomePageTabs> tabs;

  /// provide the [PageController] that will be used to switch between tabs
  /// use the same to change tabs from anywhere in the app
  final PageController pagecontroller;

  /// in case other parts of your app needs to know the current tab, user this method to get the current tab and work accoiringly
  final Null Function(int index)? onTabChange;

  /// action to be performed when the user inputs some text in the searchbar and hits enter
  final Future<dynamic> Function(String query) onQueryUpdate;

  /// user this channel to feed new suggestions to the suggestion list
  /// to be used together with [onQueryUpdate]  , [searchInBackground]
  /// use [toSuggestion] extension on list<String> or Map<String,String> to auto create suggestions.
  /// example : onQueryUpdate: (String query) async {
  ///               //getting previous suggestions
  ///               final previousSuggestions =
  ///                   suggestions.value.suggestions!.map((e) => e).toList();
  ///              suggestions.value = SearchSuggestions(
  ///                 suggestions: (previousSuggestions
  ///                 // adding new suggestions , you may have an api call here to get suggestions for query
  ///                     ..addAll([query].toSuggestion(onTap: (e) {}))));
  ///               return 0;
  ///             },
  final ValueNotifier<SearchSuggestions> suggestionChannel;

  /// when user has typed some query and has paused, this callback gets called
  /// use this to get search suggestions
  /// searchInBackground: (String query) async {
  ///               suggestions.value = SearchSuggestions(
  ///                   message: 'Loading',
  ///                   suggestions:
  ///                       ['Searching for $query'].toSuggestion(onTap: (e) {
  ///                     debugPrint('i am not tappable');
  ///                   }));
  ///               //await API call here
  ///               await Future.delayed(Duration(seconds: 2));
  ///               suggestions.value = SearchSuggestions(
  ///                   suggestions: [
  ///                 'First result   ${UniqueKey()} $query',
  ///                 'Seconds result  this${UniqueKey()}'
  ///               ].toSuggestion(onTap: (e) {}));
  ///
  ///               return 0;
  ///             },
  final Future<dynamic> Function(String query)? searchInBackground;

  ///similar to [suggestionChannel] but for quick links
  final ValueNotifier<SearchSuggestions>? quickLinks;
  final List<Widget>? actions;
  const HomePage(
      {Key? key,
      required this.tabs,
      this.onTabChange,
      required this.suggestionChannel,
      required this.onQueryUpdate,
      this.searchInBackground,
      this.quickLinks,
      required this.pagecontroller,
      this.actions})
      : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controllerReversed;
  final FocusNode searchFieldFocusNode = FocusNode();
  late final List<String> tabNames;
  late final ValueNotifier<int> currentPageIndexNotifier;
  bool shouldCancelSearch = false;
  final TextEditingController _searchQueryController =
      TextEditingController(text: '');
  @override
  void initState() {
    //only add listener to search query update if user has assigned callback to listen to background search query updates
    if (widget.searchInBackground != null) {
      _searchQueryController.addListener(() {
        _backgroungSuggestionFetch(_searchQueryController.text);
      });
    }
    _pageController = widget.pagecontroller;
    currentPageIndexNotifier = ValueNotifier<int>(0);
    tabNames = widget.tabs.map((e) => e.label).toList();
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
    //play animataion when loaded
    _play();
    // to hide search box whenever user taps anywhere else
    searchFieldFocusNode.addListener(() {
      if (!searchFieldFocusNode.hasFocus && shouldCancelSearch) {
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

  void _cancleSearch() {
    shouldCancelSearch = false;
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
          buildBodyWidget(context),
          buildTabsMenuWidget(context),
          buildSearchBarWidget(),
          buildSearchSuggestionsDropDown(context),
        ],
      ),
    );
  }

  Positioned buildSearchSuggestionsDropDown(BuildContext context) {
    return Positioned(
      top: heightOffset,
      child: ValueListenableBuilder<bool>(
          valueListenable: showSearch,
          builder: (_, shouldShowSearch, w) => AnimatedSwitcher(
                reverseDuration: const Duration(
                  milliseconds: 100,
                ),
                duration: const Duration(milliseconds: 400),
                child: shouldShowSearch
                    ? Material(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        elevation: 26,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: width(context),
                           // minHeight: 250,
                            maxHeight: 300,
                          ),
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
    );
  }

  ValueListenableBuilder<bool> buildSearchBarWidget() {
    return ValueListenableBuilder<bool>(
        valueListenable: showSearch,
        builder: (_, b, w) => AnimatedSwitcher(
              switchInCurve: Curves.easeOut,
              reverseDuration: const Duration(
                milliseconds: 100,
              ),
              duration: const Duration(seconds: 2),
              child: b
                  ? searchWidget()
                  : SizedBox.shrink(
                      key: UniqueKey(),
                    ),
            )

        //
        );
  }

  GestureDetector buildTabsMenuWidget(BuildContext context) {
    return GestureDetector(
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
        color: Theme.of(context).primaryColor,
        //color: Colors.black,
        //color: Color(0xFF291D52),
        child: CustomAnimatedList.row(
          children: tabNames.map(_textBuilder).toList().toAnimatedChildren()
            ..add(AnimatedChild(
                child: GestureDetector(
              onTap: () {
                _reverse();
              },
              child: const Icon(
                Icons.search,
                size: 20,
              ),
            )))
            ..add(AnimatedChild(
                child: Row(
              children: widget.actions ?? [],
            ))),
          controller: _controller,
        ),
      ),
    );
  }

  GestureDetector buildBodyWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        shouldCancelSearch = true;
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
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [...widget.tabs.map((e) => e.page)],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSuggestions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<SearchSuggestions>(
              valueListenable: widget.suggestionChannel,
              builder: (c, incommingsuggestions, s) {
                final val = incommingsuggestions.suggestions;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (val!.isNotEmpty &&
                              _searchQueryController.text.isNotEmpty)
                          ? 'Search result'
                          : "Quick Links",
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
                                    : widget.quickLinks!.value.suggestions)!
                                .map((e) => Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ListTile(
                                      hoverColor: Colors.transparent,
                                      trailing: incommingsuggestions.hasMessage
                                          ? const SizedBox(
                                              height: 40,
                                              child:
                                                  CircularProgressIndicator())
                                          : null,
                                      onTap: incommingsuggestions.hasErrors
                                          ? null
                                          : () => e.onTap(e),
                                      title: Text(
                                        '${e.suggestion}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    )))
                                .toList()
                                .toAnimatedChildren(),
                            controller: _controllerReversed)),
                  ],
                );
              }),
        ],
      ),
    );
  }

//Sidebar tabs
  Widget _textBuilder(String text) {
    final currentindex =
        widget.tabs.indexWhere((element) => element.label == text);
    return TextButton(
      onPressed: () {
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
                  //text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(text,
                        style: p != currentindex
                            ? Theme.of(context).primaryTextTheme.subtitle2
                            : Theme.of(context)
                                .primaryTextTheme
                                .subtitle2
                                ?.copyWith(
                                    color: Colors.white.withOpacity(.7))),
                  ),
                  //bubble
                  AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    child: p == currentindex
                        ? const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 2,
                          )
                        : const SizedBox.shrink(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

//width of the search widget
  double width(BuildContext context) => MediaQuery.of(context).size.width * .6;

  Widget searchWidget() {
    Future.delayed(const Duration(milliseconds: 100), () {
      searchFieldFocusNode.requestFocus();
    });
    return SizedBox(
      width: width(context),
      height: heightOffset,
      child: _makeSlideTween(context,
          curve: Curves.easeInOutCirc,
          initialOffset: const Offset(260, 0),
          milliseconds: 600,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.search),
              ),
              _searchTextField()
            ],
          )),
    );
  }

  Widget _searchTextField() {
    return Expanded(
      child: Padding(
        //color: Colors.red,
        padding: const EdgeInsets.only(bottom: 12.0),
        child: TextField(
          controller: _searchQueryController,
          onSubmitted: (query) async {
            searchFieldFocusNode.requestFocus();
            isWorkingOnBackground = true;
            lastSearchedkeywordInbackGround = query.trim();
            await widget.onQueryUpdate(query);
            isWorkingOnBackground = false;
          },
          focusNode: searchFieldFocusNode,
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
    );
  }

  void _play() {
    showSearch.value = false;
    _controller.forward();
    _controllerReversed.reverse();
  }

  void _reverse() {
    showSearch.value = true;
    _controller.reverse();
    _controllerReversed.forward();
  }

  String lastSearchedkeywordInbackGround = '';
  bool isWorkingOnBackground = false;
  void _backgroungSuggestionFetch(String text) {
    final currentText = _searchQueryController.text;

    if (currentText.trim().isEmpty) {
      widget.suggestionChannel.value =
          SearchSuggestions(suggestions: <SingleSuggestionItem>[]);
      lastSearchedkeywordInbackGround = '';
      isWorkingOnBackground = false;
    }
    Future.delayed(const Duration(seconds: 1), () async {
      if (_searchQueryController.text.trim() != '' &&
          _searchQueryController.text == currentText &&
          !isWorkingOnBackground &&
          lastSearchedkeywordInbackGround !=
              _searchQueryController.text.trim()) {
        isWorkingOnBackground = true;
        lastSearchedkeywordInbackGround = _searchQueryController.text.trim();
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

class SearchSuggestions {
  /// for displaying messages eg. Loading... or anything
  /// if value is provided , suggestions are not tapable
  String? message;

  /// list of suggestions
  /// /// if you've assigned [message] or [error]  limit the count to 1 ie use only one suggestion in the list
  final List<SingleSuggestionItem>? suggestions;

  /// if present, suggestions wont be tapable
  String? error;

  ///not for you :)
  bool get hasErrors => error != null;

  bool get hasMessage => message != null;
  SearchSuggestions({this.message, this.suggestions, this.error});
}

class SingleSuggestionItem {
  ///the suggestion text
  String? suggestion;

  ///the suggestion description - keep it short
  String? description;

  /// id of suggestion
  String id;

  /// holder for additional data
  Map<String, dynamic>? attributes;

  Null Function(SingleSuggestionItem) onTap;
  SingleSuggestionItem(
      {this.suggestion,
      this.description,
      required this.id,
      this.attributes,
      required this.onTap});
}

extension Helper on List<String> {
  /// this will convert list of strings to suggestions for HomePage
  /// when id is irrelevant or the [suggestion] text serves as id
  List<SingleSuggestionItem> toSuggestion(
      {required Null Function(SingleSuggestionItem) onTap}) {
    return map((e) => SingleSuggestionItem(
        id: UniqueKey().toString(), suggestion: e, onTap: onTap)).toList();
  }
}

extension Helper2 on Map<String, String> {
  /// this will convert list of strings to suggestions for HomePage
  /// when you need to work with id
  List<SingleSuggestionItem> toSuggestion(
      {required Null Function(SingleSuggestionItem) onTap}) {
    return entries
        .map((key) => SingleSuggestionItem(
            id: key.key, suggestion: key.value, onTap: onTap))
        .toList();
  }
}
