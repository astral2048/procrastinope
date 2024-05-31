import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class DetailedWeatherScreen extends StatelessWidget {
  final String city;

  DetailedWeatherScreen({required this.city});

  final WeatherService weatherService = WeatherService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: weatherService.fetchWeather(city),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final weatherData = snapshot.data!;
            final temperature = weatherData['main']['temp'];
            final tempMin = weatherData['main']['temp_min'];
            final tempMax = weatherData['main']['temp_max'];
            final description = weatherData['weather'][0]['description'];
            final humidity = weatherData['main']['humidity'];
            final windSpeed = weatherData['wind']['speed'];
            final pressure = weatherData['main']['pressure'];
            final sunrise = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunrise'] * 1000);
            final sunset = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunset'] * 1000);
            final city = weatherData['name'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    city,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  _buildWeatherDetailCard(
                    title: 'Current Temperature',
                    value: '$temperature°C',
                    icon: Icons.thermostat_outlined,
                  ),
                  _buildWeatherDetailCard(
                    title: 'Description',
                    value: description,
                    icon: _getWeatherIcon(description),
                  ),
                  _buildWeatherDetailCard(
                    title: 'Temperature Range',
                    value: 'Min: $tempMin°C, Max: $tempMax°C',
                    icon: Icons.thermostat,
                  ),
                  _buildWeatherDetailCard(
                    title: 'Humidity',
                    value: '$humidity%',
                    icon: Icons.water_drop_outlined,
                  ),
                  _buildWeatherDetailCard(
                    title: 'Wind Speed',
                    value: '$windSpeed m/s',
                    icon: Icons.wind_power,
                  ),
                  _buildWeatherDetailCard(
                    title: 'Pressure',
                    value: '$pressure hPa',
                    icon: Icons.speed_outlined,
                  ),
                  _buildWeatherDetailCard(
                    title: 'Sunrise',
                    value: DateFormat.jm().format(sunrise),
                    icon: Icons.wb_sunny_outlined,
                  ),
                  _buildWeatherDetailCard(
                    title: 'Sunset',
                    value: DateFormat.jm().format(sunset),
                    icon: Icons.nights_stay_outlined,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildWeatherDetailCard({required String title, required String value, required IconData icon}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
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
}
