class User {
  final String uid;
  final String name;

  User({required this.uid, required this.name});
}

class UserData {
  final String uid;
  final String name;
  final String phone;
  final String address;
  final String dob;
  final String regdate;
  final String gender;
  final String profileurl;

  UserData(
      {required this.uid,
      required this.name,
      required this.phone,
      required this.address,
      required this.dob,
      required this.regdate,
      required this.gender,
      required this.profileurl});
}
