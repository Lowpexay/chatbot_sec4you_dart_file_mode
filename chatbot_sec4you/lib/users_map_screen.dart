import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UsersMapScreen extends StatelessWidget {
  const UsersMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Usuários')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user_locations').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final markers = <Marker>[];
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            markers.add(
              Marker(
                width: 40,
                height: 40,
                point: LatLng(data['latitude'], data['longitude']),
                child: const Icon(Icons.person_pin_circle, color: Colors.purple, size: 36),
              ),
            );
          }
          return FlutterMap(
            options: MapOptions(
              center: markers.isNotEmpty ? markers.first.point : LatLng(0, 0),
              zoom: 2,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}