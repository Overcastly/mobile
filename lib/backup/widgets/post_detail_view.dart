import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PostDetailView extends StatefulWidget {
  final String postId;

  const PostDetailView({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  Map<String, dynamic>? post;
  List<dynamic> replies = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _replyController = TextEditingController();
  String? userToken;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPostAndReplies();
  }

  bool isValidUrl(String str) {
    return str.toLowerCase().startsWith('http');
  }

  Widget _buildImageWidget(String imageData) {
    try {
      if (isValidUrl(imageData)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageData,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return child;
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 24),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    } catch (e) {
      print('Error processing image: $e');
      return const SizedBox.shrink();
    }
  }

  Future<String?> _getLocationName(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse')
            .replace(queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['address']['city'] ??
            data['address']['town'] ??
            data['address']['village'] ??
            data['display_name'];
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
    return null;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      userToken = userData['token'];
      userId = userData['userId'];
    }
  }

  Future<Map<String, dynamic>> getAuthorInfo(String authorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final userDataString = prefs.getString('userData');
      // if (userDataString == null) throw Exception('No user data found');

      // final userData = jsonDecode(userDataString);
      // final token = userData['token'];

      final url = '${dotenv.env['BASE_URL']}/users/$authorId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer: $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load author info');
      }
    } catch (e) {
      print('Error fetching author info: $e');
      return {
        'firstName': 'Unknown',
        'lastName': 'User',
        'username': 'unknown'
      };
    }
  }

  Future<void> _loadPostAndReplies() async {
    try {
      final postResponse = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/posts/${widget.postId}'),
        headers: {'Content-Type': 'application/json'},
      );

      final repliesResponse = await http.get(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/posts/${widget.postId}/getreplies'),
        headers: {'Content-Type': 'application/json'},
      );

      if (postResponse.statusCode == 200 && repliesResponse.statusCode == 200) {
        setState(() {
          post = jsonDecode(postResponse.body);
          replies = jsonDecode(repliesResponse.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load post or replies';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.isEmpty || userToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/createreply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer: $userToken',
        },
        body: jsonEncode({
          'body': _replyController.text,
          'originalPostId': widget.postId,
        }),
      );

      if (response.statusCode == 201) {
        _replyController.clear();
        _loadPostAndReplies();
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post reply')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  DateTime _getDateFromId(String id) {
    final timestamp = int.parse(id.substring(0, 8), radix: 16);
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  String _formatDateTime(DateTime dateTime) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d, yyyy');
    return '${timeFormat.format(dateTime)} · ${dateFormat.format(dateTime)}';
  }

  ImageProvider? _buildProfileImage(String? imageData) {
    if (imageData == null) return null;

    try {
      if (isValidUrl(imageData)) {
        return NetworkImage(imageData);
      }
      return null;
    } catch (e) {
      print('Error with profile image: $e');
      return null;
    }
  }

  Widget _buildAuthorInfo(String authorId, {bool isReply = false}) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getAuthorInfo(authorId),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundImage:
                    snapshot.hasData && snapshot.data!['image'] != null
                        ? _buildProfileImage(snapshot.data!['image'])
                        : null,
                child: (!snapshot.hasData || snapshot.data!['image'] == null)
                    ? Text(
                        snapshot.hasData
                            ? '${snapshot.data!['firstName'][0]}${snapshot.data!['lastName'][0]}'
                            : '??',
                        style: TextStyle(fontSize: isReply ? 10 : 12),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.hasData
                          ? '${snapshot.data!['firstName']} ${snapshot.data!['lastName']}'
                          : 'Loading...',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '@${snapshot.hasData ? snapshot.data!['username'] : '...'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(error ?? 'Post not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAuthorInfo(post!['authorId']),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                post!['title'] ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Text(
                              _formatDateTime(_getDateFromId(post!['_id'])),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (post!['latitude'] != null &&
                            post!['longitude'] != null)
                          FutureBuilder<String?>(
                            future: _getLocationName(
                                double.parse(post!['latitude'].toString()),
                                double.parse(post!['longitude'].toString())),
                            builder: (context, snapshot) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    Expanded(
                                      child: Text(
                                        snapshot.data ??
                                            ' ${double.parse(post!['latitude'].toString()).toStringAsFixed(4)}, ${double.parse(post!['longitude'].toString()).toStringAsFixed(4)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        Text(post!['body'] ?? ''),
                        if (post!['image'] != null &&
                            post!['image'].toString().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildImageWidget(post!['image']),
                        ],
                        if (post!['tags'] != null &&
                            (post!['tags'] as List).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (var tag in post!['tags'])
                                Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  backgroundColor: Colors.black,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.all(2),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Replies',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                for (var reply in replies) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAuthorInfo(reply['authorId'], isReply: true),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reply['body']),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDateTime(_getDateFromId(reply['_id'])),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (reply['image'] != null &&
                              reply['image'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildImageWidget(reply['image']),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Write a reply...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitReply,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}