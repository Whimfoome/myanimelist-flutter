import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('MyAnimeList App', () {
    final menuIconFinder = find.byTooltip('Open navigation menu');
    final userTextFinder = find.text('User');
    final animeTextFinder = find.text('Anime');
    final mangaTextFinder = find.text('Manga');
    final industryTextFinder = find.text('Industry');

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('home screen', () async {
      await driver.waitUntilNoTransientCallbacks();
      await driver.tap(find.byValueKey('season_icon'));
      await driver.tap(find.pageBack());
      await driver.tap(find.byValueKey('airing_icon'));
      await driver.tap(find.pageBack());
      await driver.tap(find.byValueKey('upcoming_icon'));
      await driver.tap(find.pageBack());
      await driver.tap(find.byTooltip('Search anime'));
      await driver.tap(find.byTooltip('Back'));
    });

    test('login dialog', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(find.text('Login'));
      await driver.enterText('javoeria');
      await driver.tap(find.text('OK'));
      await driver.waitUntilNoTransientCallbacks();
      await driver.tap(menuIconFinder);
      await driver.tap(find.byTooltip('Theme'));
    });

    test('profile screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(userTextFinder);
      await driver.tap(find.text('Profile'));
      await driver.tap(find.pageBack());
    });

    test('anime list screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(userTextFinder);
      await driver.tap(find.text('Anime List'));
      await driver.tap(find.text('Currently Watching'));
      await driver.tap(find.text('Completed'));
      await driver.tap(find.text('On Hold'));
      await driver.tap(find.text('Dropped'));
      await driver.tap(find.text('Plan to Watch'));
      await driver.tap(find.pageBack());
    });

    test('manga list screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(userTextFinder);
      await driver.tap(find.text('Manga List'));
      await driver.tap(find.text('Currently Reading'));
      await driver.tap(find.text('Completed'));
      await driver.tap(find.text('On Hold'));
      await driver.tap(find.text('Dropped'));
      await driver.tap(find.text('Plan to Read'));
      await driver.tap(find.pageBack());
    });

    test('search anime screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(animeTextFinder);
      await driver.tap(find.text('Anime Search'));
      await driver.waitUntilNoTransientCallbacks();
      await driver.enterText('shingeki');
      await driver.tap(find.text('Shingeki no Kyojin'));
      await driver.tap(find.text('Shingeki no Kyojin Season 3 Part 2'));
      await driver.tap(find.text('Videos'));
      await driver.tap(find.text('Episodes'));
      await driver.tap(find.text('Reviews'));
      await driver.tap(find.text('Recommendations'));
      await driver.tap(find.text('Stats'));
      await driver.tap(find.text('Characters & Staff'));
      await driver.tap(find.text('News'));
      await driver.tap(find.text('Forum'));
      await driver.tap(find.pageBack());
    });

    test('top anime screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(animeTextFinder);
      await driver.tap(find.text('Top Anime'));
      await driver.tap(find.text('Top Airing'));
      await driver.tap(find.text('Top Upcoming'));
      await driver.tap(find.text('Top TV Series'));
      await driver.tap(find.text('Top Movies'));
      await driver.tap(find.text('Top OVAs'));
      await driver.tap(find.text('Top Specials'));
      await driver.tap(find.text('Most Popular'));
      await driver.tap(find.text('Most Favorited'));
      await driver.tap(find.pageBack());
    });

    test('seasonal anime screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(animeTextFinder);
      await driver.tap(find.text('Seasonal Anime'));
      await driver.tap(find.text('ONA'));
      await driver.tap(find.text('OVA'));
      await driver.tap(find.text('Movie'));
      await driver.tap(find.text('Special'));
      await driver.tap(find.pageBack());
    });

    test('search manga screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(mangaTextFinder);
      await driver.tap(find.text('Manga Search'));
      await driver.tap(find.byTooltip('Back'));
    });

    test('top manga screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(mangaTextFinder);
      await driver.tap(find.text('Top Manga'));
      // await driver.tap(find.text('Top Manga'));
      await driver.tap(find.text('Top Novels'));
      await driver.tap(find.text('Top One-shots'));
      await driver.tap(find.text('Top Doujinshi'));
      await driver.tap(find.text('Top Manhwa'));
      await driver.tap(find.text('Top Manhua'));
      await driver.tap(find.text('Most Popular'));
      await driver.tap(find.text('Most Favorited'));
      await driver.tap(find.pageBack());
    });

    test('top industry screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(industryTextFinder);
      await driver.tap(find.text('People'));
      await driver.tap(find.pageBack());
      await driver.tap(menuIconFinder);
      await driver.tap(industryTextFinder);
      await driver.tap(find.text('Characters'));
      await driver.tap(find.pageBack());
    });

    test('settings screen', () async {
      await driver.tap(menuIconFinder);
      await driver.tap(find.byTooltip('Settings'));
      await driver.tap(find.pageBack());
    });
  });
}
