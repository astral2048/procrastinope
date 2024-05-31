import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../screens/detailed_weather_screen.dart';

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService weatherService = WeatherService();
  late TextEditingController _cityController;
  String _city = 'Lahore';

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: _city);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedWeatherScreen(city: _city),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'City: $_city',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showCityInputDialog(context),
                  ),
                ],
              ),
              SizedBox(height: 8),
              FutureBuilder<Map<String, dynamic>>(
                future: weatherService.fetchWeather(_city),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final weatherData = snapshot.data!;
                    final temperature = weatherData['main']['temp'];
                    final description = weatherData['weather'][0]['description'];
                    IconData weatherIcon = _getWeatherIcon(description);

                    return Row(
                      children: [
                        Icon(weatherIcon, size: 48),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$temperature°C',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$description',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    if (description.contains('rain')) {
      return Icons.waves; // Example rain icon
    } else if (description.contains('cloud')) {
      return Icons.cloud; // Example cloud icon
    } else {
      return Icons.wb_sunny; // Example sunny icon
    }
  }

  Future<void> _showCityInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter City Name'),
        content: TextField(
          controller: _cityController,
          decoration: InputDecoration(hintText: 'City Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _city = _cityController.text;
              });
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
