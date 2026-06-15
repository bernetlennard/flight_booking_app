class BookingRequest {
  final int flightId;

  BookingRequest({
    required this.flightId,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      flightId: json['flightId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flightId': flightId,
    };
  }
}
