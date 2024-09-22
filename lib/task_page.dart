import 'package:flutter/material.dart';
import 'main.dart'; // 引入 Event 类

class TaskPage extends StatelessWidget {
  final Map<DateTime, List<Event>> events;
  final Map<String, Color> groupColors;  // 添加 group 颜色 map

  TaskPage({required this.events, required this.groupColors});

  @override
  Widget build(BuildContext context) {
    Map<String, List<Event>> groupedEvents = _groupEventsByGroup(events);

    // 如果 groupedEvents 为空，显示 "No Task Currently"
    if (groupedEvents.isEmpty) {
      return Center(
        child: Text(
          'No Task Currently',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    // 如果有任务，显示列表
    return ListView.builder(
      itemCount: groupedEvents.keys.length,
      itemBuilder: (context, index) {
        String groupName = groupedEvents.keys.elementAt(index);
        List<Event> groupEvents = groupedEvents[groupName]!;
        Color groupColor = groupColors[groupName] ?? Colors.grey;  // 设置颜色

        return ExpansionTile(
          title: Text(groupName),
          backgroundColor: groupColor.withOpacity(0.3),  // 设置背景颜色
          children: groupEvents.map((event) {
            return ListTile(
              title: Text("${event.time.format(context)} - ${event.title}"),
              subtitle: Text(event.subtitle),
            );
          }).toList(),
        );
      },
    );
  }

  // 按 group 将 events 分组
  Map<String, List<Event>> _groupEventsByGroup(Map<DateTime, List<Event>> events) {
    Map<String, List<Event>> groupedEvents = {};
    events.forEach((date, eventList) {
      for (var event in eventList) {
        if (!groupedEvents.containsKey(event.group)) {
          groupedEvents[event.group] = [];
        }
        groupedEvents[event.group]!.add(event);
      }
    });
    return groupedEvents;
  }
}
