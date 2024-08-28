class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double rainProbability; // New field for rain probability
  final String day;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.day,
    this.rainProbability = 0.0, // Default value if not provided
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    double rainProbability = 0.0;

    // Extract rain probability if it exists
    if (json.containsKey('rain')) {
      if (json['rain'].containsKey('1h')) {
        rainProbability = (json['rain']['1h'] as num).toDouble();
      } else if (json['rain'].containsKey('3h')) {
        rainProbability = (json['rain']['3h'] as num).toDouble();
      }
    }

    return Weather(
      cityName: json['name'] ?? '', // This may be null for the forecast API
      temperature: (json['main']['temp'] as num).toDouble(),
      mainCondition: json['weather'][0]['main'] as String,
      day: json.containsKey('dt_txt') // Specific to forecast API
          ? DateTime.parse(json['dt_txt']).weekday.toString()
          : '', // Default or empty for current weather
      rainProbability: rainProbability,
    );
  }
}
