import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppStrings.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          await prefs.remove('auth_user');
        }
        return handler.next(error);
      },
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return response.data;
  }

  Future<Map<String, dynamic>> register(String email, String password, String fullName, {String? country}) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      if (country != null) 'country': country,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }

  // News
  Future<Map<String, dynamic>> getNews({int page = 1, int limit = 20, String? category, bool? featured}) async {
    final response = await _dio.get('/news', queryParameters: {
      'page': page,
      'limit': limit,
      if (category != null) 'category': category,
      if (featured != null) 'featured': featured,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getNewsById(int id) async {
    final response = await _dio.get('/news/$id');
    return response.data;
  }

  Future<List<dynamic>> getNewsCategories() async {
    final response = await _dio.get('/news/categories');
    return response.data;
  }

  // Embassies
  Future<Map<String, dynamic>> getEmbassies({
    int page = 1,
    int limit = 50,
    String? search,
    String? continent,
  }) async {
    final response = await _dio.get('/embassies', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (continent != null) 'continent': continent,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getEmbassyById(int id) async {
    final response = await _dio.get('/embassies/$id');
    return response.data;
  }

  // Tourism
  Future<Map<String, dynamic>> getTourism({int page = 1, int limit = 20, String? category}) async {
    final response = await _dio.get('/tourism', queryParameters: {
      'page': page,
      'limit': limit,
      if (category != null) 'category': category,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getTourismById(int id) async {
    final response = await _dio.get('/tourism/$id');
    return response.data;
  }

  // Webinars
  Future<Map<String, dynamic>> getWebinars({int page = 1, bool? upcoming}) async {
    final response = await _dio.get('/webinars', queryParameters: {
      'page': page,
      if (upcoming != null) 'upcoming': upcoming,
    });
    return response.data;
  }

  // Events
  Future<Map<String, dynamic>> getEvents({int page = 1, bool? upcoming}) async {
    final response = await _dio.get('/events', queryParameters: {
      'page': page,
      if (upcoming != null) 'upcoming': upcoming,
    });
    return response.data;
  }

  // Posts
  Future<Map<String, dynamic>> getPosts({int page = 1, String? search}) async {
    final response = await _dio.get('/posts', queryParameters: {
      'page': page,
      if (search != null) 'search': search,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> createPost(String content, {String? imageUrl}) async {
    final response = await _dio.post('/posts', data: {
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    return response.data;
  }

  Future<void> likePost(int id) async {
    await _dio.post('/posts/$id/like');
  }

  Future<List<dynamic>> getComments(int postId) async {
    final response = await _dio.get('/posts/$postId/comments');
    return response.data;
  }

  Future<Map<String, dynamic>> createComment(int postId, String content) async {
    final response = await _dio.post('/posts/$postId/comments', data: {'content': content});
    return response.data;
  }

  // MDAs
  Future<List<dynamic>> getMdas() async {
    final response = await _dio.get('/mdas');
    return response.data;
  }

  // Opportunities
  Future<Map<String, dynamic>> getOpportunities({int page = 1, String? type}) async {
    final response = await _dio.get('/opportunities', queryParameters: {
      'page': page,
      if (type != null) 'type': type,
    });
    return response.data;
  }

  // Notifications
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final response = await _dio.get('/notifications', queryParameters: {'page': page});
    return response.data;
  }
}
