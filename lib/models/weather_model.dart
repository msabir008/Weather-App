class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double rainProbability; // This is a percentage
  final String day;
  final String time;
  final double feelsLike; // New field for "feels like" temperature
  final int humidity;     // New field for humidity percentage
  final int pressure;     // New field for pressure in hPa

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.day,
    required this.time,
    this.rainProbability = 0.0,  // Default value if not provided
    this.feelsLike = 0.0,        // Default value for feels like temperature
    this.humidity = 0,           // Default value for humidity
    this.pressure = 0,           // Default value for pressure
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Default rain probability
    double rainProbability = 0.0;

    // Extract rain probability if it exists
    if (json.containsKey('rain')) {
      if (json['rain'] != null && json['rain'].containsKey('1h')) {
        rainProbability = (json['rain']['1h'] as num?)?.toDouble() ?? 0.0;
      } else if (json['rain'] != null && json['rain'].containsKey('3h')) {
        rainProbability = (json['rain']['3h'] as num?)?.toDouble() ?? 0.0;
      }
    }

    return Weather(
      cityName: json['city']?['name'] ?? json['name'] ?? 'Unknown City', // Default to 'Unknown City' if name is missing
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0.0, // Feels like temperature
      humidity: (json['main']?['humidity'] as int?) ?? 0,                  // Humidity percentage
      pressure: (json['main']?['pressure'] as int?) ?? 0,                  // Pressure in hPa
      mainCondition: json['weather']?[0]['main'] as String? ?? 'Unknown',
      day: json.containsKey('dt_txt')
          ? DateTime.parse(json['dt_txt']).weekday.toString()
          : '', // Handle forecast data specifically
      time: json.containsKey('dt_txt')
          ? DateTime.parse(json['dt_txt']).toLocal().toString()
          : '', // Handle forecast time specifically
      rainProbability: rainProbability,
    );
  }
}
