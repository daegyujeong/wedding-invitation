import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editor_viewmodel.dart';

class NavigationEditorScreen extends StatelessWidget {
  const NavigationEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorViewModel>(
      builder: (context, viewModel, child) {
        final navigationBar = viewModel.navigationBar;
        if (navigationBar == null) {
          return const Center(child: Text('네비게이션 바 데이터가 없습니다.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation bar toggle
              SwitchListTile(
                title: const Text('네비게이션 바 활성화'),
                value: navigationBar.isEnabled,
                onChanged: (value) {
                  viewModel.toggleNavigationBar(value);
                },
              ),

              const Divider(),
              
              // D-Day settings section
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'D-Day 설정',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('D-Day 표시'),
                        value: navigationBar.showDDay,
                        onChanged: (value) {
                          viewModel.updateNavigationBarDDay(
                            showDDay: value,
                            eventDate: navigationBar.eventDate,
                            ddayFormat: navigationBar.ddayFormat,
                          );
                        },
                      ),
                      if (navigationBar.showDDay) ...[
                        const SizedBox(height: 16),
                        const Text('목표 날짜:'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () async {
                              final currentDate = navigationBar.eventDate ?? 
                                  DateTime.now().add(const Duration(days: 30));
                              
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: currentDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                              );

                              if (pickedDate != null) {
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(currentDate),
                                );

                                if (pickedTime != null) {
                                  final newDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                  viewModel.updateNavigationBarDDay(
                                    showDDay: navigationBar.showDDay,
                                    eventDate: newDateTime,
                                    ddayFormat: navigationBar.ddayFormat,
                                  );
                                }
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 12),
                                Text(
                                  navigationBar.eventDate != null
                                      ? '${navigationBar.eventDate!.year}년 ${navigationBar.eventDate!.month}월 ${navigationBar.eventDate!.day}일'
                                      : '날짜를 선택하세요',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('표시 형식:'),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: navigationBar.ddayFormat,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'D-{days}', child: Text('D-{days}')),
                            DropdownMenuItem(value: '{days}일 남음', child: Text('{days}일 남음')),
                            DropdownMenuItem(value: '결혼식까지 {days}일', child: Text('결혼식까지 {days}일')),
                            DropdownMenuItem(value: '{days} days to go', child: Text('{days} days to go')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.updateNavigationBarDDay(
                                showDDay: navigationBar.showDDay,
                                eventDate: navigationBar.eventDate,
                                ddayFormat: value,
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Divider(),
              const Text('네비게이션 아이템', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Navigation items
              ...navigationBar.items.map((item) => _buildNavigationItemEditor(context, viewModel, item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationItemEditor(BuildContext context, EditorViewModel viewModel, dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconFromString(item.icon)),
                const SizedBox(width: 8),
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Switch(
                  value: item.isEnabled,
                  onChanged: (value) {
                    viewModel.toggleNavigationItem(item.id, value);
                  },
                ),
              ],
            ),
            const Divider(),
            // Navigation type selection (bookmark or redirect)
            Row(
              children: [
                const Text('네비게이션 유형:'),
                const Spacer(),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('리다이렉트'),
                      icon: Icon(Icons.open_in_new),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('북마크'),
                      icon: Icon(Icons.bookmark),
                    ),
                  ],
                  selected: {item.isBookmark},
                  onSelectionChanged: (value) {
                    viewModel.setNavigationItemType(item.id, value.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Target page selection
            Row(
              children: [
                const Text('타겟 페이지:'),
                const Spacer(),
                DropdownButton<String>(
                  value: item.targetPage,
                  items: viewModel.pages.map<DropdownMenuItem<String>>((page) {
                    return DropdownMenuItem<String>(
                      value: page.id,
                      child: Text(page.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setNavigationItemTarget(item.id, value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'photo_library':
        return Icons.photo_library;
      case 'location_on':
        return Icons.location_on;
      case 'message':
        return Icons.message;
      case 'home':
        return Icons.home;
      case 'info':
        return Icons.info;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.circle;
    }
  }
}
