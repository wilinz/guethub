import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorItem {
  final String avatar;
  final String nickname;
  final String qq;
  final String github;

  AuthorItem({
    required this.avatar,
    required this.nickname,
    required this.qq,
    required this.github,
  });
}

class AuthorsPage extends StatelessWidget {
  final List<AuthorItem> codeAuthors = [
    AuthorItem(
      avatar: 'assets/images/wilinz.jpg',
      nickname: 'wilinz',
      qq: '3397733901',
      github: 'https://github.com/wilinz',
    ),
    AuthorItem(
      avatar: 'assets/images/zhangluo.jpg',
      nickname: 'zhangluo',
      qq: '643733581',
      github: 'https://github.com/roselle-luo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('开发者'),
      ),
      body: ListView.separated(
        separatorBuilder: (_,i){
          return SizedBox(height: 16);
        },
        padding: EdgeInsets.all(16.0),
        itemCount: codeAuthors.length,
        itemBuilder: (context, index) {
          final author = codeAuthors[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(author.avatar),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            author.nickname,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: author.qq));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('QQ号码已复制到剪贴板')),
                            );
                          },
                          child: Text('QQ: ${author.qq}'),
                        ),
                        if (author.github.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              final url = author.github;
                              launchUrl(Uri.parse(url));
                            },
                            child: Text('GitHub: ${author.github}'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}