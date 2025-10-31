import 'dart:async';

abstract class MyFeatureRepository {
  Future<List<Object>> fetchItems();
}

class MyFeatureRepositoryImpl implements MyFeatureRepository {
  MyFeatureRepositoryImpl({required this.client});

  final Object client; // Replace with real client (e.g., Dio/PocketBase)

  @override
  Future<List<Object>> fetchItems() async {
    // TODO: Implement actual call via client
    return Future<List<Object>>.value(<Object>[]);
  }
}


