
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_service_example/article.dart';
import 'package:news_service_example/news_change_notifier.dart';
import 'package:news_service_example/news_service.dart';



class BadMockNewsService implements NewsService{
  bool getArticlesCalled =false;
  @override
  Future<List<Article>> getArticles() async{
    getArticlesCalled = true;
   return [
    Article(title: 'title 1', content: 'test 1'),
    Article(title: 'title 2', content: 'test 2'),
    Article(title: 'title 3', content: 'test 3')
   ];
  }

}

class MockNewsService extends Mock implements NewsService{}

void main(){
  // sut is system under testing
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService; 

  // setup for initializing and setup variables you need for sigle test
  // run before every test
  setUp((){
    mockNewsService =MockNewsService();
    /// FALSE AND BAD MOCKING ..
    // sut=NewsChangeNotifier(BadMockNewsService());
    /// TRUE MOCKING ..
    sut=NewsChangeNotifier(mockNewsService);
  }); 
 
  test(
   "initial values correct",
   () async {
   expect(sut.articles, []);
   expect(sut.isLoading, false);
   },
  );

  group('getArticles', (){
    final articlesFromAPI =[
       Article(title: 'title 1', content: 'test 1'),
       Article(title: 'title 2', content: 'test 2'),
    ];
    void arrangeNewsServiceReturn3Articles() async{
          when(()=>mockNewsService.getArticles()).thenAnswer((_) async=> articlesFromAPI); 
    }
   test(
    "get articles using the NewsService",
    () async {
      // test about assert verify(   if
      //  act (getArticles) calling before or not by checking
      // when (NewsService getArticles) called number.
     //  )
      //arrange
      //when I call getArticles, the return will be []
      when(()=>mockNewsService.getArticles()).thenAnswer((_) async=>[] ); 
      //or we can use another when:
      // when(()=>mockNewsService.getArticles()).thenAnswer((_) async=>articlesFromAPI); 
 
      //act
      // here I put the method that I want to test
      await sut.getArticles();

      //assert
      // here I check from the return of the calling method
      verify(() => mockNewsService.getArticles()).called(1);
     
    },
   );

  
   test(
    """indicates loading of data,
    sets articles to the ones from the service, 
    indicates that data is not being loaded anymore"""
    ,
    () async {
      arrangeNewsServiceReturn3Articles();
      final future= sut.getArticles();
      expect(sut.isLoading, true);
      await future;
      expect(sut.articles,articlesFromAPI );
      expect(sut.isLoading, false);
    },
   );
  });
}