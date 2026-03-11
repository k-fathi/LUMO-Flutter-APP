class MockChildData {
  final String id;
  final String name;
  final int age;
  final String conditionKey;
  final String? photoUrl;
  final String bloodType;
  final double weight;
  final double height;

  const MockChildData({
    required this.id,
    required this.name,
    required this.age,
    required this.conditionKey,
    this.photoUrl,
    required this.bloodType,
    required this.weight,
    required this.height,
  });
}

const MockChildData defaultMockChild = MockChildData(
  id: 'child1',
  name: 'Ahmed',
  age: 6,
  conditionKey: 'conditionAutism',
  photoUrl: null,
  bloodType: 'O+',
  weight: 22.5,
  height: 115.0,
);
