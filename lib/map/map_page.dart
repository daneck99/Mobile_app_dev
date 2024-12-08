import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:security/style/colors.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(37.505753, 126.957317); // 중앙대학교 310관 위치
  LatLng? _currentPosition;
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 초기 위치
    _startLocationUpdates(); // 실시간 위치 업데이트
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      _moveCameraToPosition(_currentPosition!);
    }
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('위치 서비스가 꺼져 있습니다.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('위치 권한이 영구적으로 거부되었습니다.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _moveCameraToPosition(_currentPosition!);
  }

  // 실시간 위치 업데이트 스트림 시작
  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 최소 10미터 이동 시 업데이트
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _moveCameraToPosition(_currentPosition!);
    });
  }

  // 카메라 위치 이동 함수
  void _moveCameraToPosition(LatLng position) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 16.0),
    ));
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '현재 위치',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 16.0,
            ),
            markers: {
              if (_currentPosition != null)
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: _currentPosition!,
                  infoWindow: InfoWindow(title: '현재 위치'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              Marker(
                markerId: MarkerId('cau310'),
                position: _initialPosition,
                infoWindow: InfoWindow(
                  title: '중앙대학교 310관',
                  snippet: '100주년 기념관',
                ),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FloorInfoPage_310()),
                    );
                  },
                  child: Text(
                    '310관',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FloorInfoPage_208()),
                    );
                  },
                  child: Text(
                    '208관',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FloorInfoPage_207()),
                    );
                  },
                  child: Text(
                    '207관',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 층별 정보 페이지
class FloorInfoPage_310 extends StatelessWidget {
  // 지하 6층부터 지상 10층까지의 층별 정보 리스트
  final List<String> floorInfo = [
    '지하 6층',
    '지하 5층',
    '지하 4층',
    '지하 3층',
    '지하 2층',
    '지하 1층',
    '1층',
    '2층',
    '3층',
    '4층',
    '5층',
    '6층',
    '7층',
    '8층',
    '9층',
    '10층',
    '11층',
    '12층'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('310관 층별 정보'),
      ),
      body: ListView.builder(
        itemCount: floorInfo.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(floorInfo[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FloorDetailPage(floorName: floorInfo[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 층별 정보 페이지
class FloorInfoPage_208 extends StatelessWidget {
  final List<String> floorInfo = [
    '1층',
    '2층',
    '3층',
    '4층',
    '5층',
    '6층',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('208관 층별 정보'),
      ),
      body: ListView.builder(
        itemCount: floorInfo.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(floorInfo[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FloorDetailPage(floorName: floorInfo[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FloorInfoPage_207 extends StatelessWidget {
  final List<String> floorInfo = [
    '1층',
    '2층',
    '3층',
    '4층',
    '5층',
    '6층',
    '7층',
    '8층',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('207관 층별 정보'),
      ),
      body: ListView.builder(
        itemCount: floorInfo.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(floorInfo[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FloorDetailPage(floorName: floorInfo[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FloorDetailPage extends StatelessWidget {
  final String floorName;

  FloorDetailPage({required this.floorName});

  String _getImagePath(String floorName) {
    final Map<String, String> floorImages = {
      '지하 6층': 'assets/parking.png',
      '지하 5층': 'assets/parking.png',
      '지하 4층': 'assets/parking.png',
      '지하 3층': 'assets/parking.png',
      '지하 2층': 'assets/floor_b2.png',
      '지하 1층': 'assets/floor_b1.png',
      '1층': 'assets/floor_1.png',
      '2층': 'assets/floor_2.png',
      '3층': 'assets/floor_3.png',
      '4층': 'assets/floor_4.png',
      '5층': 'assets/floor_5.png',
      '6층': 'assets/floor_5.png',
      '7층': 'assets/floor_5.png',
      '8층': 'assets/floor_5.png',
      '9층': 'assets/floor_5.png',
      '10층': 'assets/floor_5.png',
    };

    return floorImages[floorName] ?? 'assets/default_floor.png';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getImagePath(floorName);

    return Scaffold(
      appBar: AppBar(
        title: Text(floorName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$floorName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  '이미지를 불러올 수 없습니다.',
                  style: TextStyle(color: Colors.red),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
