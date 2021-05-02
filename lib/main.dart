import 'package:apple_clone/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'homepage/homepage.dart';

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

  final ValueNotifier<SearchSuggestions> _suggestions =
      ValueNotifier(SearchSuggestions(suggestions: []));
  final ValueNotifier<SearchSuggestions> _quickLinks =
      ValueNotifier(SearchSuggestions(
          suggestions: ['something', 'relevant'].toSuggestion(onTap: (link) {
    debugPrint(link.suggestion);
  })));
  final PageController _pageControlelr = PageController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: HomePage(
            // actions: const [Icon(AntIcons.closeCircleFilled)],
            pagecontroller: _pageControlelr,
            quickLinks: _quickLinks,
            searchInBackground: searchInBackground,
            onQueryUpdate: onQueryUpdate,
            // onVoiceQueryUpdate: (String query) {
            //   final previous =
            //       suggestions.value.map((e) => e.toString()).toList();
            //   suggestions.value = (previous..add(query));
            // },
            suggestionChannel: _suggestions,
            onTabChange: (int index) {},
            tabs: [
              HomePageTabs(
                  page: const Text('page1'),
                  label: 'Mac',
                  onTap: () {
                    debugPrint('malai theexho');
                  }),
              HomePageTabs(
                  page: const Text('ele'),
                  label: 'Electronics ',
                  onTap: () async {
                    debugPrint('malai theexho2');
                  }),
              HomePageTabs(
                  page: const Text('men'),
                  label: "Men's wear",
                  onTap: () async {
                    debugPrint('malai theexho2');
                  }),
              HomePageTabs(
                  page: const Text('holi'),
                  label: 'Holi Special ',
                  onTap: () async {
                    debugPrint('malai theexho2');
                  })
            ],
          ),
        ),
        MaterialButton(
            onPressed: () {
              _quickLinks.value = SearchSuggestions(
                  suggestions: ["A new quick ${UniqueKey()}"]
                      .toSuggestion(onTap: (e) {}));
              return;
              if (false) {
                final previous =
                    _suggestions.value.suggestions!.map((e) => e).toList();
                _suggestions.value = SearchSuggestions(
                    suggestions: (previous
                      ..addAll(['query'].toSuggestion(onTap: (e) {}))));
              } else {
                _suggestions.value = SearchSuggestions(
                    suggestions: ["A new list ${UniqueKey()}"]
                        .toSuggestion(onTap: (e) {}));
              }
            },
            child: const Text('sdsd'))
      ],
    );
  }

  Future searchInBackground(String query) async {
    _suggestions.value = SearchSuggestions(
        message: 'Loading',
        suggestions: ['Searching for $query'].toSuggestion(onTap: (e) {
          debugPrint('i am not tappable');
        }));
    //await API call here
    await Future.delayed(const Duration(seconds: 2));
    _suggestions.value = SearchSuggestions(
        suggestions: {
      'first': 'First result   ${UniqueKey()} $query',
      'seconds': 'Seconds result ${UniqueKey()}'
    }.toSuggestion(onTap: (e) {
      debugPrint(e.id);
    }));

    return 0;
  }

  Future onQueryUpdate(String query) async {
    final previous = _suggestions.value.suggestions!.map((e) => e).toList();
    _suggestions.value = SearchSuggestions(
        suggestions: (previous..addAll([query].toSuggestion(onTap: (e) {}))));
    return 0;
  }
}
