import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routes/app_router.dart';

class InvitationViewScreen extends ConsumerWidget {
  final String invitationId;

  const InvitationViewScreen({
    super.key,
    required this.invitationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://via.placeholder.com/400x600',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: const [
                        Text(
                          '홍길동 ♥ 김영희',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '2024년 12월 25일 수요일 오후 2시',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '더 플라자 호텔 그랜드볼룸',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildGreetingSection(),
                  const SizedBox(height: 48),
                  _buildFamilySection(),
                  const SizedBox(height: 48),
                  _buildQuickLinks(context),
                  const SizedBox(height: 48),
                  _buildContactSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: Colors.pink,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            '초대합니다',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '소중한 분들을 모시고\n새로운 시작을 하려 합니다\n\n바쁘신 중에도 저희의 첫걸음을\n축복해 주시면 감사하겠습니다',
            style: TextStyle(
              fontSize: 16,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySection() {
    return Column(
      children: [
        const Text(
          '혼주',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[100],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '홍판서 · 춘섬의 장남',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '홍길동',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '♥',
              style: TextStyle(
                fontSize: 32,
                color: Colors.pink,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink[100],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '김철수 · 박영자의 장녀',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '김영희',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      children: [
        const Text(
          '바로가기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickLinkButton(
                context,
                icon: Icons.photo_library,
                label: '사진 보기',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.gallery,
                    arguments: invitationId,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickLinkButton(
                context,
                icon: Icons.location_on,
                label: '오시는 길',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.location,
                    arguments: invitationId,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickLinkButton(
                context,
                icon: Icons.message,
                label: '축하 메시지',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.messages,
                    arguments: invitationId,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickLinkButton(
                context,
                icon: Icons.share,
                label: '공유하기',
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.share,
                    arguments: invitationId,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        const Text(
          '연락처',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                title: '신랑측',
                contacts: [
                  {'name': '신랑 홍길동', 'phone': '010-1234-5678'},
                  {'name': '아버지 홍판서', 'phone': '010-2345-6789'},
                  {'name': '어머니 춘섬', 'phone': '010-3456-7890'},
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildContactCard(
                title: '신부측',
                contacts: [
                  {'name': '신부 김영희', 'phone': '010-9876-5432'},
                  {'name': '아버지 김철수', 'phone': '010-8765-4321'},
                  {'name': '어머니 박영자', 'phone': '010-7654-3210'},
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required String title,
    required List<Map<String, String>> contacts,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...contacts.map((contact) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contact['name']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // TODO: Make phone call
                          },
                          child: const Icon(
                            Icons.phone,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            // TODO: Send SMS
                          },
                          child: const Icon(
                            Icons.message,
                            size: 20,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
