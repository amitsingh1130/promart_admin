class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String photoUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    required this.address,
    this.photoUrl = '',
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone'] ?? '',
      address: data['address'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'photoUrl': photoUrl,
    };
  }
}
