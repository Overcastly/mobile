import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../mongodb.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  int activeStep = 0; //Track the active step
  bool isNextButtonEnabled = false;
  LatLng? selectedLocation;
  File? selectedImage;
  String? imageBase64String;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final List<String> hashtags = [];

  @override
  void initState() {
    super.initState();
    //Add listeners to text fields to monitor changes
    _titleController.addListener(_validateInputs);
    _descriptionController.addListener(_validateInputs);
    _hashtagController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    //Clean up controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      if (activeStep == 1) {
        isNextButtonEnabled = selectedLocation != null;
      } else {
        isNextButtonEnabled = _titleController.text.trim().isNotEmpty &&
            _descriptionController.text.trim().isNotEmpty;
      }
    });
  }

  //Add a hashtag to the list
  void addHashtag() {
    final String hashtag = _hashtagController.text.trim();

    if (hashtag.isNotEmpty && !hashtag.contains(' ') && !(hashtags.contains('#$hashtag'))) {
      setState(() {
        hashtags.add('#$hashtag');
      });
      _hashtagController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid, unique hashtag (one word, no spaces)."),
        ),
      );
    }
  }

  void _removeHashtag(String hashtag) {
    setState(() {
      hashtags.remove(hashtag);
      _validateInputs(); // Re-validate after removing a hashtag
    });
  }

  //Ensures the user cannot proceed to the next step unless title and description are filled
  bool _canProceedToNextStep() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      selectedLocation = position;
      _validateInputs(); // Re-validate when location is selected
    });
  }

  Future<void> _pickImage() async {
    try {
      // Open file picker to pick an image
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        File imageFile = File(filePath);

        // Convert the image file to Base64 string
        _convertImageToBase64(imageFile);
      } else {
        // No file selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected")),
        );
      }
    } catch (e, stacktrace) {
      debugPrint("Error while picking an image: $e");
      debugPrint("Stacktrace: $stacktrace");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick an image. Please try again.")),
      );
    }
  }

  Future<void> _convertImageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();

      //Encode the bytes to Base64 string
      String base64String = base64Encode(imageBytes);

      setState(() {
        selectedImage = imageFile;
        imageBase64String = base64String;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error converting image to Base64")),
      );
    }
  }

  void createPost(BuildContext context) async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields before submitting.")),
      );
      return;
    }

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final List<String> tags = hashtags;
    final double lat = selectedLocation!.latitude;
    final double lng = selectedLocation!.longitude;
    final String imageUrl = imageBase64String!;

    final error = await MongoDatabase.doCreatePost(title, description, tags, lat, lng, imageUrl);

    if(error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error as String)),
      );
    } else {
      Navigator.pop(context);
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Create Post",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // EasyStepper widget
          EasyStepper(
            activeStep: activeStep,
            lineStyle: const LineStyle(
              lineLength: 70,
              lineType: LineType.normal,
              lineThickness: 3,
              lineSpace: 1,
              lineWidth: 10,
              unreachedLineType: LineType.dashed,
              defaultLineColor: Colors.grey,
              finishedLineColor: Colors.green,
            ),
            stepRadius: 28,
            activeStepTextColor: Colors.blue,
            finishedStepTextColor: Colors.green,
            internalPadding: 20,
            steps: const [
              EasyStep(
                icon: Icon(Icons.info),
                title: 'Info',
              ),
              EasyStep(
                icon: Icon(Icons.location_on),
                title: 'Location',
              ),
              EasyStep(
                icon: Icon(Icons.image),
                title: 'Images',
              ),
            ],
            //Prevent step navigation if not valid
            onStepReached: (index) {
              if (index == activeStep) return; // Prevent redundant navigation to the same step

              if (index == 0 || index < activeStep) {
                // Allow navigation to previous or current steps
                setState(() {
                  activeStep = index;
                });
              } else if (activeStep == 0 && index == 1) {
                // Step 1: Ensure title and description are filled before moving to "Location"
                if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in the title and description to proceed.")),
                  );
                } else {
                  setState(() {
                    activeStep = 1;
                  });
                }
              } else if (activeStep == 1 && index == 2) {
                // Step 2: Ensure location is selected before moving to "Images"
                if (selectedLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a location on the map to proceed.")),
                  );
                } else {
                  setState(() {
                    activeStep = 2;
                  });
                }
              } else {
                // Prevent skipping steps
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Complete the steps in order.")),
                );
              }
            },
          ),
          Expanded(
            child: _getStepContent(activeStep),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: activeStep > 0
                      ? () {
                    setState(() {
                      activeStep--;
                    });
                  }
                      : null,
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: isNextButtonEnabled
                      ? () {
                    setState(() {
                      if (activeStep < 2) {
                        activeStep++;
                        _validateInputs(); // Re-validate for the next step
                      } else {
                        // Handle submission on the last step
                        createPost(context);
                      }
                    });
                  }
                      : null,
                  child: Text(activeStep == 2 ? 'Post' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///Returns content for each step
  Widget _getStepContent(int step) {
    switch (step) {

      ///INFO STEP
      case 0:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Input
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Post Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Input
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Post Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Hashtag Input Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _hashtagController,
                        decoration: const InputDecoration(
                          labelText: "Add Hashtag",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _hashtagController.text.trim().isNotEmpty ? addHashtag : null,
                      child: const Text("Add"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Display Added Hashtags
                Text(
                  "Added Hashtags:",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: hashtags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeHashtag(tag),
                    ),
                    )
                    .toList(),
                  ),
                ),
              ],
            ),
          ),
        );

      ///LOCATION STEP
      case 1:
        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                onTap: (tapPosition, latlng) {
                  _onMapTapped(latlng); // Update `selectedLocation` when the map is tapped
                },
                initialCenter: const LatLng(28.538336, -81.379234),
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    const LatLng(-90, -180.0), const LatLng(90.0, 180.0),
                  ),
                ),
                initialZoom: 10,
                minZoom: 2,
                interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.overcastly.app',
                ),
                if (selectedLocation != null)
                   MarkerLayer(
                    markers: [
                      Marker(point: selectedLocation!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        );

      ///IMAGES STEP
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Please Insert an Image. This step is optional.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.attach_file),
                label: const Text("Attach Image"),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedImage != null)
              Column(
                children: [
                  Image.file(
                    selectedImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Base64 String:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      imageBase64String ?? 'No Base64 String available',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        );

      default:
        return const Center(child: Text("Invalid Step"));
    }
  }
}