import 'package:flutter/material.dart';
import '../../../data/models/editor_widget_model.dart';
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
              },
            );
            break;
          case WidgetType.Text:
            widget = TextWidget(
              id: uuid.v4(),
              data: {
                'text': {
                  'translations': {'en': 'New Text'},
                  'default_language': 'en',
                },
                'fontFamily': 'Roboto',
                'fontSize': 16.0,
                'color': '#000000',
              },
            );
            break;
          // 다른 위젯 유형도 처리
          default:
            // 기본값
            widget = TextWidget(
              id: uuid.v4(),
              data: {
                'text': {
                  'translations': {'en': 'New Widget'},
                  'default_language': 'en',
                },
                'fontFamily': 'Roboto',
                'fontSize': 16.0,
                'color': '#000000',
              },
            );
        }

        onWidgetSelected(widget);
        Navigator.pop(context);
      },
    );
  }
}
