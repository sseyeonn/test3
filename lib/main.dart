import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
// import 'package:desktop_window/desktop_window.dart';

void main() {
  // DesktopWindow.setWindowSize(Size(500, 500));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // frame - StatelessWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 101, 169, 238)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // 버튼을 상태에 연결 - 임의의 새 WordPair를 current에 재할당
  void getNext() {
    current = WordPair.random();
    notifyListeners(); // ChangeNotifier의 메서드 - MyAppState를 보고 있는 사람에게 보내는 알림
  }

  // 좋아요 기능 추가
  var favorites = <WordPair>[];

  void toggleFavorite() {
    // 좋아요에 추가되어 있는지 확인 후 포함/삭제
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  // 좋아요 한 객체 삭제
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  // Content - StatefulWidget 실제 화면에 나타나는 내용들
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page; // widget 유형의 새 변수 page 선언
    switch (selectedIndex) {
      // 현재 값에 따라 page에 할당
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage(); // PlaceHolder : 미완성 표시 ▨ - 바뀔 페이지
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          // SafeArea와 Extended로 나눔
          children: [
            SafeArea(
              child: NavigationRail(
                // extended: true, // 반응성 - 공간이 충분하면 자동으로 라벨 표시
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  // print('selected: $value');
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            )
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      // Color.fromARGB(255, 197, 33, 0);
      icon = Icons.favorite; // 좋아요 누른 단어면 채워진 하트 아이콘
    } else {
      //color: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 101, 169, 238)),
      icon = Icons.favorite_border; // 좋아요 안 누른 단어면 빈 하트 아이콘
    }

    return Center(
      child: Column(
        // 수직에서 center 세로 기준 안에서
        mainAxisAlignment: MainAxisAlignment.center, // 임의의 단어쌍을 화면 중앙에 배치
        children: [
          // Text('A random Awesome idea:'), // 지워도 됨
          // Text(appState.current.asLowerCase), // 이것을 별도의 위젯으로 추출해야 함
          BigCard(
              pair:
                  pair), // -> Text 위젯이 더 이상 전체 appState을 참조하지 않음 Text(pair.asLowerCase), 에서 Text를 refactor 해줌(extract widget)

          SizedBox(height: 10), // 시각적 간격을 위함

          // 버튼 추가
          Row(
            // ex) div 옆으로 쌓음
            mainAxisSize: MainAxisSize.min,
            children: [
              // like 버튼
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                    // print('button pressed!'); // 버튼을 누르면 debug console에 출력되는 문구
                  },
                  icon: Icon(
                    icon,
                    color: Color.fromARGB(255, 197, 33, 0),
                  ),
                  label: Text('Like') // 버튼에 나타나는 이름
                  ),

              SizedBox(width: 10), // 버튼끼리의 간격

              // next 버튼
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                  // print('button pressed!'); // 버튼을 누르면 debug console에 출력되는 문구
                },
                child: Text('Next'), // 버튼에 나타나는 이름
              ),
            ],
          )
        ], // 쉼표 없어도 됨
      ),
    );
  }
}

// Column의 일부
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // return Text(pair.asLowerCase); // Text를 refactor 후 wrap with padding
    // return Padding(
    //   padding: const EdgeInsets.all(20.0), // padding은 Text의 속성이 아닌 위젯
    //   child: Text(pair.asLowerCase),
    // ); // 이번엔 Padding refactor 후 wrap with widget

    final theme = Theme.of(context); // 앱의 현재 테마 요청

    final style = theme.textTheme.displayMedium!.copyWith(
      // 앱의 글꼴 테마에 액세스, displayMedium : 큰 스타일(짧고 중요)
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme
          .primary, // colorScheme 속성과 동일하도록 카드의 색상 정의, primary 대신 secondary, surface등 여러 색상

      child: Padding(
        padding: const EdgeInsets.all(20.0), // padding은 Text의 속성이 아닌 위젯
        child: Text(
          // '${pair.first} ${pair.second}', // 보간해서 개별 두 단어 이용으로 식별을 더 정확히 할 수 있도록 함
          pair.asPascalCase, // ph를 f로 발음할 수도 있음 // 소문자, 파스칼, 캐스케이드 등
          style: style,
          semanticsLabel:
              '${pair.first} ${pair.second}', // 시각적 단순화를 위해 시맨틱 콘텐츠로 재정의
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      // 즐겨찾기 목록이 비어있으면
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: Color.fromARGB(255, 197, 33, 0),
            size: 40,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No favorites yet!',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ));
    }

    // 비어있지 않으면
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${appState.favorites.length} favorites :',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        for (var pair in appState.favorites) // 목록 표시
          // ListTile(
          //   leading: Icon(Icons.delete_outline),
          //   title: Text(pair.asPascalCase),
          //   iconColor: Color.fromARGB(255, 236, 102, 18),
          // ),
          Dismissible(
            key: ValueKey(pair),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              appState.removeFavorite(pair);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: FavoriteIcon(pair: pair),
              title: Text(
                pair.asPascalCase,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
      ],
    );
  }
}

class FavoriteIcon extends StatefulWidget {
  // 상태를 가지는 위젯
  final WordPair pair;

  // 아이콘과 단어 연결
  const FavoriteIcon({Key? key, required this.pair}) : super(key: key);

  @override
  _FavoriteIconState createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();

    return InkWell(
      onHover: (hovering) {
        setState(() {
          _hovering = hovering;
        });
      },
      onTap: () {
        appState.removeFavorite(widget.pair);
      },
      child: Icon(
        _hovering ? Icons.delete : Icons.delete_outlined,
        color: Color.fromARGB(255, 95, 95, 95),
      ),
    );
  }
}
