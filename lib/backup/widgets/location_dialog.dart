import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:mobile/views/dashboard/services/location_service.dart';

class LocationDialog extends StatefulWidget {
 final VoidCallback onLocationUpdated;
 
 const LocationDialog({
   super.key,
   required this.onLocationUpdated,
 });

 @override
 State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
 final LocationService _locationService = LocationService();
 final TextEditingController _searchController = TextEditingController();
 Timer? _debounceTimer;
 List<dynamic> _searchResults = [];
 bool _isLoading = false;
 String _currentLocation = 'Alafaya, FL';

 @override
 void initState() {
   super.initState();
   _loadCurrentLocation();
 }

 Future<void> _loadCurrentLocation() async {
   final prefs = await SharedPreferences.getInstance();
   setState(() {
     _currentLocation = prefs.getString('locationName') ?? 'Alafaya, FL';
   });
 }

 Future<void> _searchLocation(String query) async {
   if (query.isEmpty) return;

   setState(() {
     _isLoading = true;
   });

   try {
     final results = await _locationService.searchLocation(query);
     setState(() {
       _searchResults = results;
       _isLoading = false;
     });
   } catch (e) {
     setState(() {
       _isLoading = false;
     });
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error searching location: $e')),
       );
     }
   }
 }

 Future<void> _setLocation(Map<String, dynamic> location) async {
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString('latitude', location['lat']);
   await prefs.setString('longitude', location['lon']);
   
   String displayName = location['display_name'];
   if (displayName.length > 15) {
     displayName = '${displayName.substring(0, 15)}...';
   }
   
   await prefs.setString('locationName', displayName);
   await prefs.setString('locationMetadata', jsonEncode(location));

   setState(() {
     _currentLocation = displayName;
   });

   if (mounted) {
     Navigator.of(context).pop();
     widget.onLocationUpdated();
   }
 }

 @override
 Widget build(BuildContext context) {
   return Dialog(
     child: Container(
       padding: const EdgeInsets.all(16),
       constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Row(
             children: [
               const Text(
                 'Set Location',
                 style: TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const Spacer(),
               IconButton(
                 icon: const Icon(Icons.close),
                 onPressed: () => Navigator.of(context).pop(),
               ),
             ],
           ),
           const SizedBox(height: 16),
           TextField(
             controller: _searchController,
             decoration: const InputDecoration(
               hintText: 'Search for a location...',
               prefixIcon: Icon(Icons.search),
               border: OutlineInputBorder(),
             ),
             onChanged: (value) {
               if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
               _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                 _searchLocation(value);
               });
             },
           ),
           const SizedBox(height: 16),
           Expanded(
             child: _isLoading
                 ? const Center(child: CircularProgressIndicator())
                 : ListView.builder(
                     itemCount: _searchResults.length,
                     itemBuilder: (context, index) {
                       final result = _searchResults[index];
                       return ListTile(
                         title: Text(result['display_name']),
                         onTap: () => _setLocation(result),
                       );
                     },
                   ),
           ),
         ],
       ),
     ),
   );
 }

 @override
 void dispose() {
   _searchController.dispose();
   _debounceTimer?.cancel();
   super.dispose();
 }
}