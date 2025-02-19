import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'services/news_service.dart';
import 'model/news_model.dart';
import 'widgets/news_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsModel>> newsFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = fetchNews();
  }

  Future<List<NewsModel>> fetchNews() async {
    final newsService = NewsService();
    final data = await newsService.fetchNews();
    final articles = data['articles'] as List;
    return articles.map((article) => NewsModel.fromJson(article)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News App')),
      body: FutureBuilder<List<NewsModel>>(
        future: newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitFadingCircle(color: Colors.blue, size: 50.0),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading news:',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        newsFuture = fetchNews(); // Retry fetching news
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No news available', style: TextStyle(fontSize: 18)),
            );
          } else {
            final newsList = snapshot.data!;
            return ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return NewsCard(news: newsList[index]);
              },
            );
          }
        },
      ),
    );
  }
}
