import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // For reverse geocoding

class SearchPage extends StatefulWidget {
  final Function(String) onCitySelected;

  SearchPage({required this.onCitySelected});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  List<String> cities = [
    'Lahore', 'Faisalabad', 'Rawalpindi', 'Multan', 'Gujranwala', 'Sialkot',
    'Sargodha', 'Bahawalpur', 'Sahiwal', 'Sheikhupura', 'Dera Ghazi Khan',
    'Jhelum', 'Okara', 'Vehari', 'Kasur', 'Chiniot', 'Gujrat', 'Rahim Yar Khan',
    'Mianwali', 'Khanewal', 'Attock', 'Muzaffargarh', 'Pakpattan', 'Narowal',
    'Khushab', 'Mandi Bahauddin', 'Bhakkar', 'Lodhran', 'Jhang', 'Toba Tek Singh',
    'Hafizabad', 'Rajanpur', 'Chakwal', 'Shorkot', 'Kabirwala', 'Daska', 'Kharian',
    'Kamalia', 'Kot Addu', 'Burewala', 'Tandlianwala', 'Samundri', 'Jaranwala',
    'Arifwala', 'Chishtian', 'Pattoki', 'Fort Abbas', 'Murree', 'Wazirabad',
    'Pir Mahal', 'Hasilpur', 'Bakhshan Khan', 'hilo',
  ];
  List<String> filteredCities = [];
  bool _isLoadingLocation = false; // For location loading state

  @override
  void initState() {
    super.initState();
    filteredCities = cities; // Initially show all cities
  }

  // Filter cities based on input
  void _filterCities(String query) {
    final List<String> filtered = cities
        .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    setState(() {
      searchQuery = query;
      filteredCities = filtered;
    });
  }

  // Select a city from the list or use the typed city if no match
  void _onCitySelected(String city) {
    widget.onCitySelected(city); // Pass the selected city back to the main page
    Navigator.pop(context); // Go back to the main page
  }

  // Get the user's current location and reverse-geocode it to get the city name
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        String city = placemarks.first.locality ?? 'Unknown City';
        _onCitySelected(city);
      } else {
        _showErrorDialog('Could not determine the city from your location.');
      }
    } catch (e) {
      _showErrorDialog('Error getting location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Show an error dialog for location issues
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search City'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Color(0xFF7ACBD7),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  _filterCities(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Image.asset(
                      'assets/images/location1.png',
                      height: 24.0,
                      width: 24.0,
                    ),
                    onPressed: _getCurrentLocation,
                  ),
                ),
              ),
              SizedBox(height: 10),
              _isLoadingLocation
                  ? CircularProgressIndicator()
                  : SizedBox.shrink(),
              SizedBox(height: 20),
              filteredCities.isNotEmpty
                  ? Expanded(
                child: Card(
                  elevation: 20,
                  child: ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      return ListTile(
                        title: Text(city),
                        onTap: () {
                          _onCitySelected(city);
                        },
                      );
                    },
                  ),
                ),
              )
                  : Column(
                children: [
                  Text(
                    'No matching cities found',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _onCitySelected(searchQuery); // Select the typed city
                    },
                    child: Text('Use "$searchQuery"'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
