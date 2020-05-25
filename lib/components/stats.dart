import 'dart:convert';
import 'app_bar.dart';
import 'loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TotalStats {
  List<CountryStats> countryStatsList;
  final int recovered;
  final int deaths;

  TotalStats({this.countryStatsList, this.recovered, this.deaths});

  factory TotalStats.fromJson(Map<String, dynamic> json) {
    Iterable regionList = json['Countries'];
    List<CountryStats> regionsStats =
        regionList.map((i) => CountryStats.fromJson(i)).toList();
    return TotalStats(
      countryStatsList: regionsStats,
      recovered: json['TotalRecovered'],
      deaths: json['TotalDeaths'],
    );
  }
}

class CountryStats {
  final String country;
  final int totalConfirmed;
  final int totalDeaths;
  final int totalRecovered;

  CountryStats(
      {this.country,
      this.totalConfirmed,
      this.totalDeaths,
      this.totalRecovered});

  factory CountryStats.fromJson(Map<String, dynamic> json) {
    return CountryStats(
        country: json['Country'],
        totalRecovered: json['TotalConfirmed'],
        totalDeaths: json['TotalDeaths'],
        totalConfirmed: json['TotalRecovered']);
  }
}

class Stats extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  Future<TotalStats> futureData;

  Future<TotalStats> getData() async {
    final response = await http.get('https://api.covid19api.com/summary');
    return TotalStats.fromJson(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    futureData = getData();
  }

  Future<TotalStats> _refresh() {
    futureData = getData();
    return futureData;
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  TextStyle columnText = TextStyle(fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CountryStats> data = snapshot.data.countryStatsList;
          List<DataRow> rows = [
            DataRow(cells: <DataCell>[
              DataCell(Text(
                'Summary',
                style: TextStyle(color: Colors.red[400]),
              )),
              DataCell(
                Text(
                  'Cases',
                  //snapshot.data.recovered.toString(),
                  style: TextStyle(color: Colors.red[400]),
                ),
              ),
              DataCell(Text(
                'Deaths',
                //snapshot.data.deaths.toString(),
                style: TextStyle(color: Colors.red[400]),
              )),
              DataCell(Text(
                'Recovered',
                style: TextStyle(color: Colors.red[400]),
              )),
            ])
          ];
          for (var i = 0; i < data.length; i++) {
            rows.add(DataRow(cells: <DataCell>[
              DataCell(
                Text(
                  data[i].country[0].toUpperCase() +
                      data[i].country.substring(1),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                Text(
                  data[i].totalConfirmed.toString(),
                ),
              ),
              DataCell(Text(
                data[i].totalDeaths.toString(),
              )),
              DataCell(Text(
                data[i].totalRecovered.toString(),
              ))
            ]));
          }

          return Scaffold(
              appBar: appBar,
              body: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  child: Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(columns: <DataColumn>[
                        DataColumn(
                            label: Text(
                          'Country',
                          style: columnText,
                        )),
                        DataColumn(label: Text('Cases', style: columnText)),
                        DataColumn(label: Text('Deaths', style: columnText)),
                        DataColumn(label: Text('Recovered', style: columnText)),
                      ], rows: rows),
                    ),
                  ),
                ),
              ));
        }

        return LoadingScreen();
      },
    );
  }
}
