class LoginRequestModel {
  LoginRequestModel({
    required this.username,
  });
  late final String? username;

  LoginRequestModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['username'] = username;
    return _data;
  }
}
