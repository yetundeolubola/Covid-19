import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CountryN();
  }
}

Future<CountryName> fetchCountries() async {
  final response = await http.get('https://api.covid19api.com/countries');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return CountryName.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Country');
  }
}

class CountryName {
  final String countries;

  CountryName({this.countries});
  factory CountryName.fromJson(Map<String, dynamic> json) {
    return CountryName(countries: json['Country']);
  }
}

class CountryN extends StatefulWidget {
  @override
  _CountryNState createState() => _CountryNState();
}

class _CountryNState extends State<CountryN> {
  final TextEditingController _filter = new TextEditingController();
  Future<CountryName> futureCountryName;
  String _searchText = "";
  List countries = new List();
  List filteredCountries = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Search Example');

  _CountryNState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredCountries = countries;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureCountryName = fetchCountries();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: FutureBuilder<CountryName>(
          future: futureCountryName,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.countries);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      List tempList = new List();
      for (int i = 0; i < filteredCountries.length; i++) {
        if (filteredCountries[i]['Country']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredCountries[i]);
        }
      }
      filteredCountries = tempList;
    }
    return ListView.builder(
      itemCount: countries == null ? 0 : filteredCountries.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredCountries[index]['Country']),
          onTap: () => print(filteredCountries[index]['Country']),
        );
      },
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search Example');
        filteredCountries = countries;
        _filter.clear();
      }
    });
  }
}
