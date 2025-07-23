class UserModel {
  String? userId;
  String? name;
  String? email;
  double? height;
  int? weight;
  int? age;
  String? gender;
  String? activityLevel;
  String? fitnessGoal;
  String? dietType;
  List<String>? allergies;
  List<String>? dislikedFoods;
  double? bmi;
  bool profileCompleted = false;

  UserModel({
    this.userId,
    this.name,
    this.email,
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.activityLevel,
    this.fitnessGoal,
    this.dietType,
    this.allergies,
    this.dislikedFoods,
    this.bmi,
    this.profileCompleted = false,
  });

  // Add methods to convert to/from JSON if needed
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'fitnessGoal': fitnessGoal,
      'dietType': dietType,
      'allergies': allergies,
      'dislikedFoods': dislikedFoods,
      'bmi': bmi,
      'isProfileSetup': profileCompleted,
    };
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    height = json['height'];
    weight = json['weight'];
    age = json['age'];
    gender = json['gender'];
    activityLevel = json['activityLevel'];
    fitnessGoal = json['fitnessGoal'];
    dietType = json['dietType'];
    allergies = List<String>.from(json['allergies'] ?? []);
    dislikedFoods = List<String>.from(json['dislikedFoods'] ?? json['disLikedFoods'] ?? []);
    bmi = json['bmi'];
    profileCompleted = json['isProfileSetup'] ?? false;
  }

  void updateUID(String newUserId) {
    userId = newUserId;
  }
}