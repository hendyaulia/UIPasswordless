class RegisterRequestModel {
  RegisterRequestModel({
    required this.username,
    required this.email,
  });
  late final String? username;
  late final String? email;

  RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['username'] = username;
    _data['email'] = email;
    return _data;
  }
}
