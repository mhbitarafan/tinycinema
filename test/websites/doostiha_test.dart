
import 'package:test/test.dart';
import 'package:tinycinema/logic/websites/models.dart';
import 'package:tinycinema/logic/websites/websites.dart';

void main() async {
  Doostiha doostiha = Doostiha();

  group("doostiha category page", () {
    late List<Post> page1cat0;
    setUp(() async {
      page1cat0 =
          await doostiha.parseHtmlPage(doostiha.categories["فیلم"]!, 1);
    });
    test("testing doostiha category parser", () async {
      expect(page1cat0.length, 10);
      expect(page1cat0[0].title, isNot(""));
      expect(page1cat0[0].slug, isNot(""));
      expect(page1cat0[0].image, isNot(""));
    });
  });

  group("doostiha single page", () {
    // https://www.doostihaa.com/1393/07/14/harry-potter-and-the-sorcerers-stone-2001.html
    // https://www.doostihaa.com/1400/09/21/funny-thing-about-love-2021.html
    // late SinglePageModel funnyThingAboutLove;
    // late SinglePageModel harryPotter;
    // late SinglePageModel witcherS1;
    setUp(() async {
    //   funnyThingAboutLove = await doostiha.parseSinglePage(
    //       "https://www.doostihaa.com/1400/09/21/funny-thing-about-love-2021.html");
    //   harryPotter = await doostiha.parseSinglePage(
    //       "https://www.doostihaa.com/1393/07/14/harry-potter-and-the-sorcerers-stone-2001.html");
    // });
  // witcherS1 = await doostiha.parseSinglePage(
          // "https://www.doostihaa.com/1398/10/03/%d9%81%d8%b5%d9%84-%d8%a7%d9%88%d9%84-%d8%b3%d8%b1%db%8c%d8%a7%d9%84-%d9%88%db%8c%da%86%d8%b1-the-witcher-season-1.html");
    });
    test("testing doostiha single page parser", () {
      // expect(harryPotter.links["دوبله فارسی"]["1080"],
      //     "https://cdn.irdanlod.ir/?s=3&f=/Films/2001/H/Harry.Potter.and.the.Sorcerers.Stone.2001.1080p.Farsi.Dubbed.mkv");
      // expect(funnyThingAboutLove.links["زیرنویس فارسی"]["1080"],
      //     "https://cdn.irdanlod.ir/?s=4&f=/files/Movie/2021/F/Funny.Thing.About.Love.2021.1080p.Farsi.Subbed.mkv");
    });
  });
}
