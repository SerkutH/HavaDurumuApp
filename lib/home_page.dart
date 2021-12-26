import 'package:flutter/material.dart';
import 'search_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'Ankara';
  int? sicaklik;
  var locationData;
  var woeid;
  String abbr = 'c';
  Position? position;

  Future<void> getDevicePosition () async {
    try {position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);}
    catch (error) {
      print ('Şu hata oluştu $error');
    }
  }

  Future<void> getLocationTemperature() async {
    var response =
    await http.get('https://www.metaweather.com/api/location/$woeid/');
    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      sicaklik = temperatureDataParsed['consolidated_weather'][0]['the_temp'].round();
      abbr  = temperatureDataParsed['consolidated_weather'][0]['weather_state_abbr'];
      print('calıstı');
    });
  }


  Future<void> getLocationData() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?query=$sehir');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?lattlong=${position!.latitude},${position!.longitude}');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
    sehir = locationDataParsed[0]['title'];
  }


  void getDataFromAPI() async {
    await getDevicePosition();
    await getLocationDataLatLong();
    await getLocationTemperature();
  }

  void getDataFromAPIbyCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    getDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/$abbr.jpg'),
        ),
      ),
      child: sicaklik == null
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/$abbr.png'),
                    ),
                    Text(
                      '$sicaklik',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 70),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$sehir',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        IconButton(
                            onPressed: () async {
                              sehir = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchPage(),
                                ),
                              );
                              getDataFromAPIbyCity();
                              setState(() {
                                sehir = sehir;
                              });
                            },
                            icon: Icon(Icons.search))
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
