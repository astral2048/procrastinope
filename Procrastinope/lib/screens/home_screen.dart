import 'package:flutter/material.dart';
import 'package:procrastinope/screens/focus_screen.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/weather_widget.dart'; // Import the WeatherWidget
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import Google Mobile Ads

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3432470212336005/3848445088',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Your Tasks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => AddTaskScreen(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                int currentExp = taskProvider.totalExp;
                int expForNextLevel = taskProvider.level * 100;
                int level = taskProvider.level;
                double progress = currentExp / expForNextLevel;

                return Column(
                  children: [
                    // Display user stats
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Focus Level: $level', style: TextStyle(fontSize: 24, color: Colors.white)),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.5)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 20,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('$currentExp / $expForNextLevel EXP', style: const TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                    // Display current weather
                    WeatherWidget(), // Add the WeatherWidget here
                    // Display task list
                    Expanded(
                      child: ListView.builder(
                        itemCount: taskProvider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = taskProvider.tasks[index];
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Card(
                              child: ListTile(
                                title: Text(task.name),
                                subtitle: Text('Category: ${task.category}\nPriority: ${task.priority}\nDeadline: ${DateFormat.yMMMd().add_jm().format(task.deadline)}'),
                                trailing: Checkbox(
                                  value: task.completed,
                                  onChanged: (value) {
                                    DateTime currentTime = DateTime.now();
                                    if (currentTime.isAfter(task.deadline)) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Missed Deadline'),
                                            content: Text("You've missed the deadline! You won't receive any EXP for this task. \n\nYou better stop procrastinating! :)"),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      taskProvider.unfinishedTask(task.id);
                                    } else {
                                      taskProvider.markTaskAsCompleted(task.id);
                                    }
                                  },
                                ),

                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Focus Session button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FocusScreen()),
                        );
                      },
                      child: Text('Start Focus Session'),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isAdLoaded)
            Container(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }
}
