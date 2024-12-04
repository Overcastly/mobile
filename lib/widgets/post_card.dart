import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_detail_view.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String body;
  final String? imageData;
  final String authorId;
  final List<String> tags;
  final String postId;
  final DateTime createdAt;
  final String? userToken;
  final String? userId;

  const PostCard({
    super.key,
    required this.title,
    required this.body,
    this.imageData,
    required this.authorId,
    required this.tags,
    required this.postId,
    required this.createdAt,
    required this.userToken,
    required this.userId,
  });

  bool isValidUrl(String str) {
    return str.toLowerCase().startsWith('http');
  }

  Future<Map<String, dynamic>> getAuthorInfo() async {
    try {
      print('DEBUG: BASE_URL is: ${dotenv.env['BASE_URL']}');
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');
      print('DEBUG: UserData String from SharedPreferences: $userDataString');

      final url = '${dotenv.env['BASE_URL']}/users/$authorId';
      print('DEBUG: Making API call to: $url');
      print('DEBUG: With headers: ${{
        'Content-Type': 'application/json',
      }}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG: API Response status: ${response.statusCode}');
      print('DEBUG: API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("--JSON RESPONSE DATA--: $responseData");
        print('DEBUG: Complete image data: ${responseData['image']}');
        return responseData;
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

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedTags = tags.length > 5 ? tags.sublist(0, 5) : tags;
    final remainingTags = tags.length > 5 ? tags.length - 5 : 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailView(
              postId: postId,
              userToken: userToken,
              userId: userId,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: getAuthorInfo(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: snapshot.hasData &&
                                  snapshot.data!['image'] != null
                              ? _buildProfileImage(snapshot.data!['image'])
                              : null,
                          child: (!snapshot.hasData ||
                                  snapshot.data!['image'] == null)
                              ? Text(
                                  snapshot.hasData
                                      ? '${snapshot.data!['firstName'][0]}${snapshot.data!['lastName'][0]}'
                                      : '??',
                                  style: const TextStyle(fontSize: 12),
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
                        Text(
                          getTimeAgo(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (imageData != null && imageData!.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.4,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: _buildImage(),
                  ),
                ),

              // Body
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...displayedTags.map((tag) => Chip(
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
                          )),
                      if (remainingTags > 0)
                        Chip(
                          label: Text(
                            '+$remainingTags more',
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
                ),
            ],
          );
        }),
      ),
    );
  }

  ImageProvider? _buildProfileImage(String imageData) {
    try {
      if (isValidUrl(imageData)) {
        return NetworkImage(imageData);
      }
      return null;
    } catch (e) {
      print('DEBUG: Error processing profile image: $e');
      return null;
    }
  }

  Widget _buildImage() {
    try {
      if (isValidUrl(imageData!)) {
        return Image.network(
          imageData!,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return child;
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            );
          },
        );
      }
      return const SizedBox.shrink();
    } catch (e) {
      print('Error processing image: $e');
      return const SizedBox.shrink();
    }
  }
}