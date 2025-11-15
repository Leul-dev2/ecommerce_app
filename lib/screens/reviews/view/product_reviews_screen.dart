import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

class Review {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Anonymous',
      avatarUrl: json['avatarUrl'] ?? '',
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ProductReviewsScreen extends StatefulWidget {
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;

  const ProductReviewsScreen({
    Key? key,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  }) : super(key: key);

  @override
  _ProductReviewsScreenState createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  List<Review> reviews = [];
  bool isLoading = true;
  bool isSubmitting = false;
  bool showAddReview = false;
  double newRating = 4.0;
  final commentController = TextEditingController();

  // ✅ Replace with your actual backend URL
  final String backendBaseUrl = 'https://backend-ecomm-jol4.onrender.com/api';

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$backendBaseUrl/products/${widget.productId}/reviews');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          reviews = data.map((json) => Review.fromJson(json)).toList();
        });
      } else {
        debugPrint('Failed to fetch reviews. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitReview() async {
    if (isSubmitting) return;

    final comment = commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review comment.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final url = Uri.parse('$backendBaseUrl/products/${widget.productId}/reviews');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'name': widget.userName,
          'avatarUrl': widget.userAvatar,
          'rating': newRating,
          'comment': comment,
        }),
      );

      debugPrint('Submit review response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201) {
        commentController.clear();
        setState(() {
          newRating = 4.0;
          showAddReview = false;
        });
        await fetchReviews();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Reviews')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton.icon(
              icon: Icon(showAddReview ? Icons.close : Icons.add_comment, color: Colors.blue),
              label: Text(
                showAddReview ? 'Cancel' : 'Add a Review',
                style: const TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                setState(() {
                  showAddReview = !showAddReview;
                });
              },
            ),
          ),
          if (showAddReview)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Rating:'),
                  RatingBar.builder(
                    initialRating: newRating,
                    minRating: 1,
                    maxRating: 5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        newRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send),
                      label: Text(isSubmitting ? 'Submitting...' : 'Submit'),
                      onPressed: isSubmitting ? null : submitReview,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                    ? const Center(child: Text('No reviews yet.'))
                    : ListView.separated(
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, index) {
                          final r = reviews[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: r.avatarUrl.isNotEmpty ? NetworkImage(r.avatarUrl) : null,
                              child: r.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                RatingBarIndicator(
                                  rating: r.rating,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 16,
                                  unratedColor: Colors.amber.withAlpha(50),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeAgo(r.createdAt),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(r.comment),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
