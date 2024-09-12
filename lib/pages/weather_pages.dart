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
  List<Weather> _hourlyWeather = [];
  List<Weather> _weeklyWeather = [];

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      final hourlyWeather = await _weatherService.getHourlyWeather(cityName);
      final weeklyWeather = await _weatherService.getWeeklyWeather(cityName);

      print('Fetched weather: $weather');
      print('Fetched hourly weather: $hourlyWeather');
      print('Fetched weekly weather: $weeklyWeather');

      setState(() {
        _weather = weather;
        _hourlyWeather = hourlyWeather;
        _weeklyWeather = _aggregateDailyWeather(weeklyWeather);
      });
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  List<Weather> _aggregateDailyWeather(List<Weather> forecast) {
    Map<String, Weather> dailyWeatherMap = {};

    for (var weather in forecast) {
      final date = DateTime.parse(weather.time).toLocal();
      final formattedDate = "${date.year}-${date.month}-${date.day}";

      if (!dailyWeatherMap.containsKey(formattedDate)) {
        dailyWeatherMap[formattedDate] = Weather(
          cityName: weather.cityName,
          temperature: weather.temperature,
          mainCondition: weather.mainCondition,
          day: formattedDate,
          time: weather.time,
          rainProbability: weather.rainProbability,
        );
      }
    }

    return dailyWeatherMap.values.toList();
  }

  String _getWeatherImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'cloudy':
      case 'overcast':
        return 'assets/images/cloudy.png';
      case 'clear':
      case 'clean':
        return 'assets/images/sunny.png';
      case 'rain':
      case 'drizzle':
        return 'assets/images/rainy.png';
      default:
        return 'assets/images/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWeather,
        child: Container(
          height: screenSize.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
                child: Column(
                  children: [
                    // First Container: Location
                    Container(
                      height: 75,
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00BCD4), Color(0xFF008BA3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _weather?.cityName ?? "Loading City...",
                        style: TextStyle(
                          fontSize: screenSize.width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Second Container: Image, Temperature, and Rain Probability
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            _weather != null
                                ? _getWeatherImage(_weather!.mainCondition)
                                : 'assets/images/loading.png',
                            height: screenSize.width * 0.25,
                            width: screenSize.width * 0.25,
                          ),
                          Column(
                            children: [
                              Text(
                                _weather != null
                                    ? '${_weather!.temperature.toString()}°C'
                                    : '',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                _weather != null
                                    ? 'Rain: ${_weather!.rainProbability.toString()}%'
                                    : '',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.045,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Third Container: Hourly Forecast for One Day (e.g., every 3 hours)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Forecast (Every 3 Hours)",
                            style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          _hourlyWeather.isNotEmpty
                              ? Container(
                            height: screenSize.width * 0.4, // Adjust the height as needed
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _hourlyWeather.length,
                              itemBuilder: (context, index) {
                                final hourlyData = _hourlyWeather[index];
                                final time = DateTime.parse(hourlyData.time).toLocal();
                                final formattedTime = "${time.hour}:00";

                                return Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Card(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Container(
                                    width: screenSize.width * 0.25, // Adjust the width as needed
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.04,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '${hourlyData.temperature.toString()}°C',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.045,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Image.asset(
                                          _getWeatherImage(hourlyData.mainCondition),
                                          height: screenSize.width * 0.15,
                                          width: screenSize.width * 0.15,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ),
                                );
                              },
                            ),
                          )
                              : Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 22),

                    // Fourth Container: Weekly Forecast
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Forecast',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          _buildWeeklyForecast(screenSize),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast(Size screenSize) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _weeklyWeather.length,
      itemBuilder: (context, index) {
        final dailyWeather = _weeklyWeather[index];
        final date = DateTime.parse(dailyWeather.time).toLocal();
        final formattedDate = "${date.day}/${date.month}/${date.year}";

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.white.withOpacity(0.8),
            child: ListTile(
              leading: Image.asset(
                _getWeatherImage(dailyWeather.mainCondition),
                height: screenSize.width * 0.15,
                width: screenSize.width * 0.15,
              ),
              title: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: screenSize.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                '${dailyWeather.temperature.toString()}°C',
                style: TextStyle(
                  fontSize: screenSize.width * 0.04,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
