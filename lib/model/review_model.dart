class ReviewModel {
  final String bookingId;
  final String userId;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final String barberId;

  ReviewModel({
    required this.bookingId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.barberId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'barberId': barberId,
    };
  }
}