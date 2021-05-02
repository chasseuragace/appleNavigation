import 'package:apple_clone/imdb_api/movies_resonse_a_p_i.dart';
import 'package:flutter/foundation.dart';
import 'package:tmdb_api/tmdb_api.dart';

import 'key.dart';

class TMDBAPI {
  TMDB tmdbWithLogs = TMDB(
    ApiKeys(apikey, readkey),
    logConfig: ConfigLogger.showAll(),
  );
  Future fetchMovies(String query,
      {Null Function(List<Results>?)? onSuccess,
      Null Function()? onError}) async {
    int wassuccess = 0;
    await (tmdbWithLogs.v3.search.queryMovies(query).then((value) {
      wassuccess = 1;
      onSuccess!(MoviesResonseAPI.fromJson(value).results);
    })
      ..timeout(const Duration(seconds: 6))
      ..onError((e, s) {
        onError!();
      }));
    print('returning $wassuccess');
    return wassuccess;
    //onSuccess(response.results);
  }

  void fetch(String query) async {
    var res = await tmdbWithLogs.v3.movies.getPouplar();
    var res2 = await tmdbWithLogs.v3.geners.getMovieList();
    var response = MoviesResonseAPI.fromJson(res);
    debugPrint(response.toJson().toString());
  }
}
