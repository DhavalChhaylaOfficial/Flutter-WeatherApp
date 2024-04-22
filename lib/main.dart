import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/UI/splash.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/UI/weather_item.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/UI/about.dart';
import 'package:share/share.dart';

class WeatherData {
  final DateTime date;
  final double temperature;
  final String description;
  final image;

  WeatherData(
      {required this.date,
      required this.temperature,
      required this.description,
      required this.image});
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

final Shader linearGradient = const LinearGradient(
  colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

class _WeatherAppState extends State<WeatherApp> {
  String _cityName = "";
  Map<String, dynamic> _weatherData = {};
  bool _isLoading = false;
  String _currentDate = "";
  String imageUrl = '';
  late List<WeatherData> weatherData = [];

  final Color primaryColor = const Color(0xff38BDF8);

  @override
  void initState() {
    super.initState();
    _loadSavedCity();
    _updateCurrentDate();
  }

  Future<void> _fetchSevenDayForecast(String city) async {
    const String apiKey = 'efddeb09d94f05c40fad8b660300a185';
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        weatherData = List<WeatherData>.generate(8, (index) {
          final DateTime date = DateTime.now().add(Duration(days: index));
          final temperature = jsonData['list'][index]['main']['temp'];
          final description = jsonData['list'][index]['weather'][0]['main'];
          final image = jsonData['list'][index]['weather'][0]['main']
              .replaceAll(' ', '')
              .toLowerCase();
          return WeatherData(
              date: date,
              temperature: temperature,
              description: description,
              image: image);
        });
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void _updateCurrentDate() {
    setState(() {
      _currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    });
  }

  Future<void> _loadSavedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedCity = prefs.getString('cityName') ?? '';
    if (savedCity.isNotEmpty) {
      _fetchWeather(savedCity);
    } else {
      _fetchWeatherForCurrentLocation();
    }
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cityName', city);

    String apiKey = 'efddeb09d94f05c40fad8b660300a185';
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    http.Response response = await http.get(Uri.parse(apiUrl));

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        _weatherData = json.decode(response.body);
        _fetchSevenDayForecast(city);

        // Fetch current date
        String currentDate = _getCurrentDate(_weatherData['timezone']);
        // Update state with current date
        setState(() {
          _currentDate = currentDate;
        });
      } else if (_weatherData.isEmpty || response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('City not found.'),
          ),
        );
      } else {
        // Handle other status codes (e.g., 404 for city not found)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error fetching weather data: ${response.statusCode}'),
          ),
        );
        _weatherData = {}; // Clear weather data in case of error
      }

      imageUrl =
          _weatherData['weather'][0]['main'].replaceAll(' ', '').toLowerCase();
    });
  }

  String _getCurrentDate(int timezoneOffset) {
    // Get current UTC time
    DateTime currentTime = DateTime.now().toUtc();
    // Calculate offset duration based on timezone
    Duration offsetDuration = Duration(seconds: timezoneOffset);
    // Convert UTC time to local time of searched city
    DateTime localTime = currentTime.add(offsetDuration);
    // Format date
    String formattedDate = DateFormat('MMMM dd, yyyy').format(localTime);
    return formattedDate;
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        bool shouldRequestPermission = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
                'This app requires access to your location to fetch weather data. Please grant permission in the settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Grant'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );

        if (shouldRequestPermission == true) {
          permission = await Geolocator.requestPermission();
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permission denied.'),
          ));
          return;
        }
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permission denied.'),
        ));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String cityName =
          placemarks.isNotEmpty ? placemarks[0].locality ?? '' : '';
      if (cityName.isNotEmpty) {
        _fetchWeather(cityName);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('City name not found.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error getting current location: $e'),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          backgroundColor: primaryColor,
          elevation: 0.0,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Our profile image
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Text(
                    'Weather App',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                //our location dropdown
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PopupMenuButton<String>(
                      icon: Image.asset(
                        'assets/menu-bar.png', // Replace with your asset path
                        width: 30, // Adjust size as needed
                        height: 30,
                      ),
                      onSelected: (value) {
                        if (value == 'fetch_location') {
                          _fetchWeatherForCurrentLocation();
                        } else if (value == 'about_us') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutPage()),
                          );
                        } else if (value == 'thanks') {
                          _shareApp(context);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {
                          'fetch_location': 'Weather of Current Location',
                          'about_us': 'About Us',
                          'thanks': 'Share',
                        }.entries.map((MapEntry<String, String> entry) {
                          return PopupMenuItem<String>(
                            value: entry.key,
                            child: Row(
                              children: [
                                if (entry.key == 'fetch_location' ||
                                    entry.key == 'about_us' ||
                                    entry.key == 'thanks')
                                  const SizedBox(width: 8),
                                // Add some spacing between icon and text
                                Text(entry.value),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  height: 200,
                  width: 200,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 20.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _cityName = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter City Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                _fetchWeather(_cityName);
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_weatherData['name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30.0,
                              ),
                            ),
                            Text(
                              _currentDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Container(
                              width: size.width,
                              height: 200,
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(.5),
                                      offset: const Offset(0, 25),
                                      blurRadius: 10,
                                      spreadRadius: -12,
                                    )
                                  ]),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                      top: -60,
                                      left: 5,
                                      child: LottieBuilder.asset(
                                        'assets/$imageUrl.json',
                                        width: 180,
                                      )),
                                  Positioned(
                                    bottom: 30,
                                    left: 20,
                                    child: Text(
                                      '${_weatherData['weather'][0]['description']}'
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            '${_weatherData['main']['temp']}',
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          '°C',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: weatherItem(
                                          text: 'Wind Speed',
                                          value:
                                              '${_weatherData['wind']['speed']}',
                                          unit: ' m/s',
                                          imageUrl: 'assets/windspeed.png',
                                        ),
                                      ),
                                      Expanded(
                                        child: weatherItem(
                                          text: 'Sunrise',
                                          value: _formatTime(
                                              _weatherData['sys']['sunrise']),
                                          unit: '',
                                          imageUrl: 'assets/sunrise.png',
                                        ),
                                      ),
                                      Expanded(
                                        child: weatherItem(
                                          text: 'Sunset',
                                          value: _formatTime(
                                              _weatherData['sys']['sunset']),
                                          unit: '',
                                          imageUrl: 'assets/sunset.png',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Adding some space between the rows
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: weatherItem(
                                          text: 'Humidity',
                                          value:
                                              '${_weatherData['main']['humidity']}',
                                          unit: ' %',
                                          imageUrl: 'assets/humidity.png',
                                        ),
                                      ),
                                      Expanded(
                                        child: weatherItem(
                                          text: 'Min Temp',
                                          value:
                                              '${_weatherData['main']['temp_min']}',
                                          unit: '°C',
                                          imageUrl: 'assets/min-temp.png',
                                        ),
                                      ),
                                      Expanded(
                                        child: weatherItem(
                                          text: 'Max Temp',
                                          value:
                                              '${_weatherData['main']['temp_max']}',
                                          unit: '°C',
                                          imageUrl: 'assets/max-temp.png',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  'Next 7 Days',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color(0xff38BDF8)),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: weatherData.length,
                                itemBuilder: (context, index) {
                                  final data = weatherData[index];
                                  String today =
                                      DateFormat('d/M').format(DateTime.now());

                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color:
                                            '${data.date.day}/${data.date.month}' ==
                                                    today
                                                ? primaryColor
                                                : Colors.black54
                                                    .withOpacity(.1),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xffc5dde5)
                                                .withOpacity(.5),
                                            offset: const Offset(0, 25),
                                            blurRadius: 10,
                                            spreadRadius: -12,
                                          )
                                        ]),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${data.date.day}/${data.date.month}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                '${data.date.day}/${data.date.month}' ==
                                                        today
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          data.description,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                '${data.date.day}/${data.date.month}' ==
                                                        today
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        LottieBuilder.asset(
                                          'assets/${data.image}.json',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${data.temperature.toStringAsFixed(1)}°C',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                '${data.date.day}/${data.date.month}' ==
                                                        today
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ));
  }

  String _formatTime(int millisecondsSinceEpoch) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch * 1000);
    String formattedTime = DateFormat.Hm().format(dateTime); // HH:MM format
    return formattedTime;
  }
}

void _shareApp(BuildContext context) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  Share.share(
    'Check out this awesome Weather app!\n https://play.google.com/store/apps/details?id=com.dhaval.weather_app',
    subject: 'Share App',
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Weather App',
    home: GetStarted(),
  ));
}
