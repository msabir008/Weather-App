import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/models/weather_model.dart';
import 'package:weather/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('5b8185a6dcba1e13dfd61198c025142b');
  Weather? _weather;
  List<Weather> _weeklyWeather = [];

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      final weeklyWeather = await _weatherService.getWeeklyWeather(cityName);
      setState(() {
        _weather = weather;
        _weeklyWeather = weeklyWeather;
      });
    } catch (e) {
      print(e);
    }
  }

  String _getWeatherImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'cloudy':
        return 'asset/images/cloudy.png';
      case 'sunny':
        return 'asset/images/sunny.png';
      case 'rainy':
        return 'asset/images/rainy.png';
      default:
        return 'asset/images/default.png';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _weather != null ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: Column(
                  children: [
                    Text(
                      _weather?.cityName ?? "Loading City...",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Image.asset(
                              _weather != null
                                  ? _getWeatherImage(_weather!.mainCondition)
                                  : 'asset/images/loading.png',
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(height: 10),
                            Text(
                              _weather != null
                                  ? '${_weather!.temperature.toString()}°C'
                                  : 'Loading Temperature...',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _weather != null
                                  ? 'Rain: ${_weather!.rainProbability.toString()}%'
                                  : 'Loading Rain Probability...',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _weather != null
                    ? _buildWeeklyForecast()
                    : Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _weeklyWeather.length,
      itemBuilder: (context, index) {
        final dailyWeather = _weeklyWeather[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 120,
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dailyWeather.day,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.asset(
                    _getWeatherImage(dailyWeather.mainCondition),
                    height: 50,
                    width: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${dailyWeather.temperature.toString()}°C',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
