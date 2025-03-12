import 'package:dio/dio.dart';
import 'package:guethub/data/model/app/app_version/app_version.dart';
import 'package:guethub/data/model/app/forum/forum_categories_response/forum_categories_response.dart';
import 'package:guethub/data/model/app/forum/forum_posts_response/forum_posts_response.dart';
import 'package:guethub/data/model/common/common_response.dart';
import 'package:guethub/data/network.dart';

class ForumRepository {
  Dio get dio => AppNetwork.get().appDio;

  Future<ForumCategoriesResponse> getCategories() async {
    final response = await dio.get("forum/categories");
    return ForumCategoriesResponse.fromJson(response.data);
  }

  Future<ForumPostsResponse> getPosts({
    int page = 1,
    int pageSize = 30,
    String sortBy = 'created_at',
    String order = 'desc',
    String? userId,
    String? categoryId,
    String? parentId,
  }) async {
    final queryParameters = {
      'page': page,
      'page_size': pageSize,
      'sort_by': sortBy,
      'order': order,
      if (userId != null) 'user_id': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (parentId != null) "parent_id": parentId
    };

    final response = await dio.get(
      'forum/posts',
      queryParameters: queryParameters,
    );

    final postsResp = ForumPostsResponse.fromJson(response.data);
    return postsResp
      ..data = postsResp.data
          .map((e) => e
            ..images =
                e.images.map((e) => AppNetwork.appOSSBaseUrl + e).toList())
          .toList();
  }

  Future<CommonResponse> like(String postId) async {
    final response = await dio.put("forum/post/${postId}/like");
    return CommonResponse.fromJson(response.data);
  }

  Future<CommonResponse> unlike(String postId) async {
    final response = await dio.delete("forum/post/${postId}/unlike");
    return CommonResponse.fromJson(response.data);
  }

  Future<CommonResponse> view(String postId) async {
    final response = await dio.put("forum/post/${postId}/view");
    return CommonResponse.fromJson(response.data);
  }

  ForumRepository._create();

  static ForumRepository? _instance;

  factory ForumRepository.get() => _instance ??= ForumRepository._create();
}
