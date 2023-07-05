class UserModel {
  final String userName;
  final String userId;
  final List<Map<String, double>> targetLocations;
  final String photoUrl;
  final String phoneNumber;
  final bool isOnline;
  final List<String> focusModeTimes;
  final String focusMode;
  final List<int> focusLocations;

  UserModel({
    required this.userName,
    required this.userId,
    required this.targetLocations,
    required this.photoUrl,
    required this.phoneNumber,
    required this.isOnline,
    required this.focusModeTimes,
    required this.focusMode,
    required this.focusLocations,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['userName'],
      userId: json['userId'],
      targetLocations: List<Map<String, double>>.from(
          json['targetLocations'].map((location) => location)),
      photoUrl: json['photoUrl'],
      phoneNumber: json['phoneNumber'],
      isOnline: json['isOnline'],
      focusModeTimes:
          List<String>.from(json['focusModeTimes'].map((time) => time)),
      focusMode: json['focusMode'],
      focusLocations:
          List<int>.from(json['focusLocations'].map((location) => location)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userId': userId,
      'targetLocations': targetLocations,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isOnline': isOnline,
      'focusModeTimes': focusModeTimes,
      'focusMode': focusMode,
      'focusLocations': focusLocations,
    };
  }
}
