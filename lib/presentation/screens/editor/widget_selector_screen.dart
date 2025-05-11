import 'package:flutter/material.dart';
import '../../../data/models/editor_widget_model.dart';
import '../../../data/models/invitation_model.dart';
import 'package:uuid/uuid.dart';

class WidgetSelectorScreen extends StatelessWidget {
  final Function(EditorWidget) onWidgetSelected;

  const WidgetSelectorScreen({super.key, required this.onWidgetSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위젯 추가'),
      ),
      body: ListView(
        children: [
          _buildWidgetItem(
            context,
            'D-day 카운터',
            Icons.calendar_today,
            WidgetType.DDay,
          ),
          _buildWidgetItem(
            context,
            '카운트다운 타이머',
            Icons.timer,
            WidgetType.CountdownTimer,
          ),
          _buildWidgetItem(
            context,
            '지도',
            Icons.map,
            WidgetType.Map,
          ),
          _buildWidgetItem(
            context,
            '텍스트',
            Icons.text_fields,
            WidgetType.Text,
          ),
          _buildWidgetItem(
            context,
            '이미지',
            Icons.image,
            WidgetType.Image,
          ),
          _buildWidgetItem(
            context,
            '이미지 갤러리',
            Icons.photo_library,
            WidgetType.Gallery,
          ),
          _buildWidgetItem(
            context,
            '일정',
            Icons.schedule,
            WidgetType.Schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetItem(
    BuildContext context,
    String title,
    IconData icon,
    WidgetType type,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // 선택된 위젯 유형에 따라 데이터 생성
        const uuid = Uuid();
        EditorWidget widget;

        switch (type) {
          case WidgetType.DDay:
            widget = DDayWidget(
              id: uuid.v4(),
              data: {
                'eventId': '',
                'format': 'D-{days}',
                'style': 'default',
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
            break;
          case WidgetType.CountdownTimer:
            widget = CountdownWidget(
              id: uuid.v4(),
              data: {
                'targetDate': DateTime(2025, 5, 31).toIso8601String(),
                'format': '{days}:{hours}:{minutes}:{seconds}',
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
            break;
          case WidgetType.Map:
            widget = MapWidget(
              id: uuid.v4(),
              data: {
                'venueId': '',
                'mapType': 'google',
                'showDirections': true,
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
            break;
          case WidgetType.Text:
            widget = TextWidget(
              id: uuid.v4(),
              data: {
                'text': {
                  'translations': {'ko': '새 텍스트'},
                  'default_language': 'ko',
                },
                'fontFamily': 'Roboto',
                'fontSize': 16.0,
                'color': '#000000',
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
            break;
          case WidgetType.Image:
            widget = ImageWidget(
              id: uuid.v4(),
              data: {
                'imageUrl': 'https://via.placeholder.com/150',
                'width': 150.0,
                'height': 150.0,
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
            break;
          case WidgetType.Gallery:
            widget = GalleryWidget(
              id: uuid.v4(),
              data: {
                'imageUrls': [
                  'https://via.placeholder.com/150',
                  'https://via.placeholder.com/150',
                  'https://via.placeholder.com/150',
                ],
                'layoutType': 'grid',
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
            break;
          case WidgetType.Schedule:
            widget = ScheduleWidget(
              id: uuid.v4(),
              data: {
                'events': [
                  {
                    'time': '13:00',
                    'description': '식전 행사',
                  },
                  {
                    'time': '14:00',
                    'description': '결혼식',
                  },
                  {
                    'time': '15:30',
                    'description': '피로연',
                  },
                ],
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
            break;
          default:
            // 기본값 (텍스트 위젯)
            widget = TextWidget(
              id: uuid.v4(),
              data: {
                'text': {
                  'translations': {'ko': '새 위젯'},
                  'default_language': 'ko',
                },
                'fontFamily': 'Roboto',
                'fontSize': 16.0,
                'color': '#000000',
                'position': {
                  'dx': 100.0,
                  'dy': 100.0,
                },
              },
            );
        }

        onWidgetSelected(widget);
        Navigator.pop(context);
      },
    );
  }
}
