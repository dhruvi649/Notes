class UserModel{
  String? uid;
  String? email;
  String? name;
  String? password;
  String? photoUrl;

  UserModel({this.uid, this.email, this.name, this.password, this.photoUrl});


  // Receive data from server
  factory UserModel.fromMap(map){
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      password: map['password'],
      photoUrl: map['photoUrl'],
    );
  }

  //Send data to server
  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'password': password,
      'photoUrl': photoUrl,
    };
  }

}