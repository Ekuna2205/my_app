import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const QuizMasterApp());
}

class QuizMasterApp extends StatefulWidget {
  const QuizMasterApp({super.key});

  @override
  State<QuizMasterApp> createState() => _QuizMasterAppState();
}

class _QuizMasterAppState extends State<QuizMasterApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
    });
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[850],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeToggle: _toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class Category {
  final String name;
  final Color color;
  final IconData icon;
  final List<Question> questions;

  Category(this.name, this.color, this.icon, this.questions);
}

class Question {
  final String question;
  final List<String> options;
  final int correctIndex;

  Question(this.question, this.options, this.correctIndex);
}

final List<Question> historyQuestions = [
  Question('Монголын анхны хаан хэн бэ?', [
    'Өгөдэй',
    'Чингис хаан',
    'Хубилай',
    'Мөнх хаан',
  ], 1),
  Question('АНУ-ын анхны ерөнхийлөгч хэн байсан бэ?', [
    'Абрахам Линкольн',
    'Жорж Вашингтон',
    'Томас Жефферсон',
    'Жон Адамс',
  ], 1),
];

final List<Question> scienceQuestions = [
  Question('Усны химийн томъёо юу вэ?', ['CO2', 'H2O', 'O2', 'NaCl'], 1),
  Question('Нарны аймгийн хамгийн том гараг аль нь вэ?', [
    'Дэлхий',
    'Бархасбадь',
    'Санчир',
    'Тэнгэрийн ван',
  ], 1),
];

final List<Question> sportQuestions = [
  Question('Олимпийн наадам хэдэн жилд нэг удаа болдог вэ?', [
    '2',
    '4',
    '6',
    '8',
  ], 1),
  Question('Футболын талбайд хэдэн тоглогч байдаг вэ?', [
    '10',
    '11',
    '12',
    '9',
  ], 1),
];

final List<Question> movieQuestions = [
  Question('"The Godfather" киног хэн найруулсан бэ?', [
    'Стивен Спилберг',
    'Фрэнсис Форд Коппола',
    'Мартин Скорсезе',
    'Кристофер Нолан',
  ], 1),
  Question('Титаник кинонд Жекийг хэн тоглосон бэ?', [
    'Брэд Питт',
    'Леонардо Ди Каприо',
    'Том Круз',
    'Жонни Депп',
  ], 1),
];

final List<Question> flutterQuestions = [
  Question('Flutter-ийг хэн бүтээсэн бэ?', [
    'Facebook',
    'Google',
    'Microsoft',
    'Apple',
  ], 1),
  Question('Flutter ямар хэл дээр бичигддэг вэ?', [
    'Java',
    'Kotlin',
    'Dart',
    'Swift',
  ], 2),
  Question('Flutter-д hot reload гэж юу вэ?', [
    'Апп шинээр эхлүүлэх',
    'Код өөрчлөлтийг шууд харах',
    'Апп устгах',
    'Debug mode',
  ], 1),
  Question('Flutter-д гол widget-ийн 2 төрөл юу вэ?', [
    'Stateful ба Functional',
    'Stateless ба Stateful',
    'Dynamic ба Static',
    'Container ба Column',
  ], 1),
  Question('Flutter-д StatefulWidget-ийн lifecycle-ийн эхний метод юу вэ?', [
    'build()',
    'initState()',
    'dispose()',
    'setState()',
  ], 1),
  Question('Flutter-д "key" гэж юу вэ?', [
    'Widget-ийг танихад ашигладаг',
    'Өнгө тодорхойлдог',
    'Animation үүсгэдэг',
    'State хадгалдаг',
  ], 0),
  Question('Flutter-д setState() юу хийдэг вэ?', [
    'Widget-ийг дахин зурна',
    'Апп-ыг шинээр эхлүүлнэ',
    'State-ийг устгана',
    'Animation эхлүүлнэ',
  ], 0),
  Question('Flutter-д MaterialApp болон CupertinoApp-ийн ялгаа юу вэ?', [
    'Material – Android стиль, Cupertino – iOS стиль',
    'Material – web, Cupertino – mobile',
    'Ялгаагүй',
    'Material – dark mode, Cupertino – light mode',
  ], 0),
  Question('Flutter-д Provider гэж юу вэ?', [
    'State management package',
    'Animation package',
    'Networking package',
    'Database package',
  ], 0),
  Question('Flutter-д async/await ашиглахыг юу гэдэг вэ?', [
    'Синхрон код бичих',
    'Асинхрон код бичих',
    'Animation үүсгэх',
    'Widget үүсгэх',
  ], 1),
  Question('Flutter-д Navigator 2.0 гэж юу вэ?', [
    'Declarative routing',
    'Imperative routing',
    'State management',
    'Animation',
  ], 0),
  Question('Flutter-д Riverpod яагаад Provider-ээс илүү вэ?', [
    'Immutable state, илүү scalable',
    'Илүү хурдан',
    'Илүү гоё UI',
    'Ялгаагүй',
  ], 0),
  Question('Flutter-д Impeller гэж юу вэ?', [
    'Шинэ rendering engine (performance сайжруулсан)',
    'State management',
    'Package manager',
    'Testing tool',
  ], 0),
  Question('Flutter-д null safety гэж юу вэ?', [
    'Null утгаас сэргийлэх feature',
    'Animation safety',
    'State safety',
    'Network safety',
  ], 0),
  Question('Flutter-д "build()" метод яагаад State дээр байдаг вэ?', [
    'StatefulWidget immutable учраас',
    'StatelessWidget-д байдаг',
    'Performance-д',
    'Design pattern',
  ], 0),
];

final List<Question> dartQuestions = [
  Question('Dart хэлийг хэн бүтээсэн бэ?', [
    'Google',
    'Microsoft',
    'Apple',
    'Facebook',
  ], 0),
  Question('Dart нь ямар төрлийн хэл вэ?', [
    'Compiled',
    'Interpreted',
    'Both (AOT & JIT)',
    'Scripting only',
  ], 2),
  Question('Dart-д main() функц ямар байх ёстой вэ?', [
    'void main()',
    'main()',
    'static void main()',
    'public static void main()',
  ], 0),
  Question('Dart-д null safety гэж юу вэ?', [
    'Null утгаас сэргийлэх feature (2021 оноос)',
    'Optional chaining',
    'Null pointer exception',
    'Ялгаагүй',
  ], 0),
  Question('Dart-д "?" тэмдэг юуг илэрхийлдэг вэ?', [
    'Nullable type (String?)',
    'Ternary operator',
    'Optional parameter',
    'Spread operator',
  ], 0),
  Question('Dart-д "!" тэмдэг юу хийдэг вэ?', [
    'Null assertion operator (value!)',
    'Not operator',
    'Force unwrap',
    'Bang operator',
  ], 0),
  Question('Dart-д async/await ашиглахад ямар keyword шаардлагатай вэ?', [
    'Future',
    'Stream',
    'async',
    'await',
  ], 2),
  Question('Dart-д List, Map, Set-ийн ялгаа юу вэ?', [
    'List – ordered, Map – key-value, Set – unique',
    'Бүгд ижил',
    'List – unique, Set – key-value',
    'Map – ordered',
  ], 0),
  Question('Dart-д cascade notation (..) гэж юу вэ?', [
    'Олон метод дараалан дуудах (..add()..remove())',
    'Spread operator',
    'Collection if',
    'Collection for',
  ], 0),
  Question('Dart-д mixin гэж юу вэ?', [
    'Multiple inheritance-ийн оронд ашигладаг',
    'Abstract class',
    'Interface',
    'Extension',
  ], 0),
  Question('Dart-д extension гэж юу вэ?', [
    'Бэлэн класс дээр шинэ метод нэмэх',
    'Inheritance',
    'Composition',
    'Mixin',
  ], 0),
  Question('Dart-д isolates гэж юу вэ?', [
    'Multi-threading (separate memory)',
    'Async tasks',
    'Futures',
    'Streams',
  ], 0),
  Question('Dart-д "late" keyword юу хийдэг вэ?', [
    'Lazy initialization (null safety-д)',
    'Final variable',
    'Const variable',
    'Static',
  ], 0),
  Question('Dart-д generics ашиглах жишээ аль вэ?', [
    'List<String>',
    'List',
    'String',
    'dynamic List',
  ], 0),
  Question('Dart 3.0-оос ямар шинэ feature нэмэгдсэн бэ?', [
    'Records, Patterns, Class modifiers',
    'Null safety',
    'Async',
    'Extension methods',
  ], 0),
];

final List<Question> javascriptQuestions = [
  Question('JavaScript-г хэн бүтээсэн бэ?', [
    'Brendan Eich',
    'Tim Berners-Lee',
    'Bill Gates',
    'Elon Musk',
  ], 0),
  Question('JS-д "===" гэж юуг шалгадаг вэ?', [
    'Value only',
    'Type only',
    'Value and type',
    'Reference',
  ], 2),
  Question('JS-д hoisting гэж юу вэ?', [
    'Variable/function declaration дээш "өргөгдөх"',
    'Loop optimization',
    'Memory management',
    'Async handling',
  ], 0),
  Question('JS-д Promise гэж юу вэ?', [
    'Asynchronous operation-ийн объект',
    'Array method',
    'Loop',
    'Function',
  ], 0),
  Question('JS-д "this" keyword ямар утгатай вэ?', [
    'Global object',
    'Current function',
    'Context-д хамаарна',
    'Always window',
  ], 2),
  Question('JS-д async/await юуг орлох вэ?', [
    'Callbacks',
    'Promises',
    'Both',
    'None',
  ], 2),
  Question('JS-д event loop гэж юу вэ?', [
    'Asynchronous code-ийг зохицуулах механизм',
    'Loop for events',
    'DOM manipulation',
    'Memory allocation',
  ], 0),
  Question('JS-д closure гэж юу вэ?', [
    'Function + lexical scope',
    'Object',
    'Array',
    'Promise',
  ], 0),
  Question('JS-д let, const, var-ийн ялгаа юу вэ?', [
    'Scope and hoisting',
    'Type',
    'Performance',
    'Ялгаагүй',
  ], 0),
  Question('JS-д arrow function ямар онцлогтой вэ?', [
    '"this" bind хийгддэггүй',
    'Shorter syntax',
    'No arguments object',
    'Бүгд',
  ], 3),
  Question('JS-д spread operator (...) юу хийдэг вэ?', [
    'Array/object copy or merge',
    'Math operation',
    'Loop',
    'Condition',
  ], 0),
  Question('JS-д module system аль вэ?', [
    'CommonJS',
    'ES6 Modules',
    'AMD',
    'Бүгд',
  ], 3),
];

final List<Question> pythonQuestions = [
  Question('Python-г хэн бүтээсэн бэ?', [
    'Guido van Rossum',
    'Brendan Eich',
    'Linus Torvalds',
    'James Gosling',
  ], 0),
  Question('Python-д indentation яагаад чухал вэ?', [
    'Syntax-д зориулагдсан (block тодорхойлдог)',
    'Style only',
    'Performance',
    'Optional',
  ], 0),
  Question('Python-д list comprehension гэж юу вэ?', [
    'Short way to create list',
    'Dictionary method',
    'Loop',
    'Function',
  ], 0),
  Question('Python-д *args, **kwargs юу вэ?', [
    'Variable arguments',
    'Fixed arguments',
    'Keywords only',
    'None',
  ], 0),
  Question('Python-д GIL гэж юу вэ?', [
    'Global Interpreter Lock',
    'Graphics Interface Library',
    'General Input Loop',
    'Game Instruction Language',
  ], 0),
  Question('Python-д decorator гэж юу вэ?', [
    'Function wrapper',
    'Class method',
    'Loop',
    'Variable',
  ], 0),
  Question('Python-д lambda функц юу вэ?', [
    'Anonymous function',
    'Named function',
    'Class',
    'Module',
  ], 0),
  Question('Python-д "is" vs "==" ялгаа юу вэ?', [
    '"is" – identity, "==" – equality',
    'Ялгаагүй',
    '"is" – value',
    '"==" – type',
  ], 0),
  Question('Python-д virtual environment яагаад хэрэглэдэг вэ?', [
    'Package dependency зохицуулах',
    'Performance',
    'Security',
    'Style',
  ], 0),
  Question('Python-д generator гэж юу вэ?', [
    'Memory efficient iterator (yield)',
    'List',
    'Dictionary',
    'Set',
  ], 0),
  Question('Python-д type hint гэж юу вэ?', [
    'Variable type тодорхойлох (mypy-д)',
    'Runtime type check',
    'Mandatory',
    'Optional',
  ], 3),
  Question('Python-д asyncio гэж юу вэ?', [
    'Asynchronous programming library',
    'Sync library',
    'Threading',
    'Multiprocessing',
  ], 0),
];

class LeaderboardEntry {
  final String name;
  final int score;
  final int streak;

  LeaderboardEntry({
    required this.name,
    required this.score,
    required this.streak,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'streak': streak,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'],
      score: json['score'],
      streak: json['streak'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalScore = 0;
  int streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalScore = prefs.getInt('totalScore') ?? 0;
      streak = prefs.getInt('streak') ?? 0;
    });
  }

  Future<void> _saveStats(int score) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalScore += score;
      streak += 1;
    });
    await prefs.setInt('totalScore', totalScore);
    await prefs.setInt('streak', streak);
  }

  final List<Category> categories = [
    Category('Түүх', Colors.purple, Icons.history, historyQuestions),
    Category('Шинжлэх Ухаан', Colors.blue, Icons.science, scienceQuestions),
    Category('Спорт', Colors.green, Icons.sports_soccer, sportQuestions),
    Category('Кино', Colors.orange, Icons.movie, movieQuestions),
    Category('Flutter', Colors.teal, Icons.flutter_dash, flutterQuestions),
    Category('Dart', Colors.orange[700]!, Icons.code, dartQuestions),
    Category(
      'JavaScript',
      Colors.yellow[700]!,
      Icons.code,
      javascriptQuestions,
    ),
    Category('Python', Colors.blue[800]!, Icons.functions, pythonQuestions),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizMaster'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.onThemeToggle(!isDark);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 6,
              color: isDark ? Colors.grey[850] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$totalScore',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'Нийт оноо',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$streak',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Streak 🔥',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final cardOpacity = isDark ? 0.7 : 1.0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              QuizScreen(category: cat, onComplete: _saveStats),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 8,
                      color: cat.color.withOpacity(cardOpacity),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon, size: 60, color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            cat.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${cat.questions.length} асуулт',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddCustomQuestionDialog(),
          );
        },
        backgroundColor: Colors.indigo[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList('leaderboard') ?? [];
    setState(() {
      entries = jsonList
          .map(
            (json) => LeaderboardEntry.fromJson(
              Map<String, dynamic>.from(jsonDecode(json)),
            ),
          )
          .toList();
      entries.sort((a, b) => b.score.compareTo(a.score));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard 🏆'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(
                'Одоогоор тоглогч байхгүй байна. Тоглоод эрэмбэд орцгоо! 🎮',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final rank = index + 1;
                final medal = rank == 1
                    ? '🥇'
                    : rank == 2
                    ? '🥈'
                    : rank == 3
                    ? '🥉'
                    : '#$rank';

                return Card(
                  elevation: 4,
                  color: isDark ? Colors.grey[850] : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Text(medal, style: const TextStyle(fontSize: 32)),
                    title: Text(
                      entry.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Streak: ${entry.streak} 🔥'),
                    trailing: Text(
                      '${entry.score} оноо',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// QuizScreen, AddCustomQuestionDialog классууд өмнөх шигээ (бүтэн кодод байгаа)

class QuizScreen extends StatefulWidget {
  final Category category;
  final Function(int) onComplete;

  const QuizScreen({
    super.key,
    required this.category,
    required this.onComplete,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;
  int timeLeft = 30;
  late Timer _timer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          score -= 5;
          nextQuestion();
        }
      });
    });
  }

  void nextQuestion() {
    _timer.cancel();
    if (currentQuestion < widget.category.questions.length - 1) {
      setState(() {
        currentQuestion++;
        timeLeft = 30;
      });
      startTimer();
    } else {
      _timer.cancel();
      widget.onComplete(score);
      if (score > widget.category.questions.length * 5) {
        _confettiController.play();
      }
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Баяр хүсье! 🎉'),
          content: Text(
            'Таны оноо: $score / ${widget.category.questions.length * 10}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Буцах'),
            ),
          ],
        ),
      );
    }
  }

  void answer(int selectedIndex) {
    _timer.cancel();
    if (selectedIndex ==
        widget.category.questions[currentQuestion].correctIndex) {
      score += 10;
    } else {
      score -= 5;
    }
    nextQuestion();
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.category.questions[currentQuestion];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: widget.category.color,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: timeLeft / 30,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[700],
                        valueColor: AlwaysStoppedAnimation(
                          timeLeft > 10 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    Text(
                      '$timeLeft',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Асуулт ${currentQuestion + 1}/${widget.category.questions.length}',
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                LinearProgressIndicator(
                  value:
                      (currentQuestion + 1) / widget.category.questions.length,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation(widget.category.color),
                ),
                const SizedBox(height: 40),
                FlipCard(
                  front: Card(
                    elevation: 8,
                    color: isDark ? Colors.grey[800] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          question.question,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  back: Card(
                    elevation: 8,
                    color: Colors.green[isDark ? 900 : 100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          question.options[question.correctIndex],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green[200],
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ...question.options.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () => answer(entry.key),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.indigo[700]
                            : Colors.indigo[100],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 100,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class AddCustomQuestionDialog extends StatefulWidget {
  const AddCustomQuestionDialog({super.key});

  @override
  State<AddCustomQuestionDialog> createState() =>
      _AddCustomQuestionDialogState();
}

class _AddCustomQuestionDialogState extends State<AddCustomQuestionDialog> {
  final _categoryController = TextEditingController();
  final _questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      title: Text(
        'Шинэ асуулт нэмэх ✏️',
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Категори нэр',
              labelStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: 'Асуулт бичих',
              labelStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Болих',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_categoryController.text.isNotEmpty &&
                _questionController.text.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '"${_questionController.text}" асуулт "${_categoryController.text}" категори-д нэмэгдлээ!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green[700],
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Нэмэх'),
        ),
      ],
    );
  }
}
