import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/child.dart';
import '../../domain/repositories/children_repository.dart';
import '../../data/repositories/children_repository_impl.dart';
import '../../data/datasources/remote_children_data_source.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// 1. Provider for the Repository (Dependency Injection)
final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  final dataSource = RemoteChildrenDataSourceImpl(client: http.Client());
  return ChildrenRepositoryImpl(dataSource);
});

// 2. Provider for the Data (State Management)
final childrenProvider = FutureProvider<List<Child>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.read(childrenRepositoryProvider);
  return repository.getChildren();
});
