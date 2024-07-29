import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewLocationPage extends StatefulWidget {
  final double? latitude; // Made optional to handle potential null values
  final double? longitude; // Made optional to handle potential null values

  const ViewLocationPage({this.latitude, this.longitude});

  @override
  _ViewLocationPageState createState() => _ViewLocationPageState();
}

class _ViewLocationPageState extends State<ViewLocationPage> {
  late CameraPosition _initialCameraPosition;
  bool _mapLoadingError = false; // Flag to indicate map loading error

  @override
  void initState() {
    super.initState();

    // Handle cases where latitude or longitude might be null
    if (widget.latitude == null || widget.longitude == null) {
      _mapLoadingError = true; // Set error flag if coordinates are missing
    } else {
      _initialCameraPosition = CameraPosition(
        target: LatLng(widget.latitude!, widget.longitude!), // Use '!' for non-null assertion
        zoom: 16, // Adjust zoom level as needed
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Location'),
      ),
      body: _mapLoadingError
          ? Center(
        child: Text('loading....'),
      )
          : GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        mapType: MapType.normal, // Choose your preferred map type (normal, hybrid, satellite)
      ),
    );
  }
}
