import 'dart:convert';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Country {
  final String countries;
  final String slug;
  Country({this.countries, this.slug});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(countries: json['Country'], slug: json['Slug']);
  }
}

class CountryState extends StatefulWidget {
  @override
  _CountryStateState createState() => _CountryStateState();
}

class _CountryStateState extends State<CountryState> {
  final SearchBarController<Country> _searchBarController =
      SearchBarController();

  Future<List<Country>> fetchCountries(String fetchCountries) async {
    final response = await http.get('https://api.covid19api.com/countries');
    var countryList = List<Country>();

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var countryJson = json.decode(response.body);
      for (var lCountryJson in countryJson) {
        countryList.add(Country.fromJson(lCountryJson));
      }
      // If the server did not return a 200 OK response,
      // then throw an exception.
    }
    return countryList;
  }

//  @override
//  void initState() {
//    fetchCountries().then((value) {
//      setState(() {
//        _country.addAll(value);
//      });
//    });
//    super.initState();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Country'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xff2B5E80),
            Color(0xff5BAFE7),
          ])),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar<Country>(
            searchBarController: _searchBarController,
            onSearch: fetchCountries,
            onItemFound: (Country post, int index) {
              return ListTile(
                title: Text(post.countries),
                subtitle: Text(post.slug),
              );
            },
            header: Row(
              children: <Widget>[
                RaisedButton(
                    child: Text('Sort'),
                    onPressed: () {
                      _searchBarController.sortList((Country a, Country b) {
                        return a.countries.compareTo(b.countries);
                      });
                    }),
                RaisedButton(
                    child: Text("Desort"),
                    onPressed: () {
                      _searchBarController.removeSort();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
