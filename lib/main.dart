import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'settings_page.dart';
import 'task_page.dart';
import 'locked_page.dart'; // 引入 LockedPage 文件
import 'fish_tank_page.dart'; // 引入 FishTankPage 文件

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Map<String, Color> _groupColors = {
    'Work': Colors.blue,
    'Personal': Colors.green,
    'School': Colors.red,
    'Others': Colors.purple,
  };  // 初始化带有颜色的 group

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _updateGroupColor(String groupName, Color color) {
    setState(() {
      _groupColors[groupName] = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calendar & Task App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: _themeMode,
      home: HomePage(
        toggleTheme: _toggleTheme,
        groupColors: _groupColors,
        onColorChanged: _updateGroupColor,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Map<String, Color> groupColors; // 添加 group 颜色 map
  final Function(String, Color) onColorChanged; // 颜色更新函数

  HomePage({
    required this.toggleTheme,
    required this.groupColors,
    required this.onColorChanged,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadEvents() async {
    Map<DateTime, List<Event>> loadedEvents = await loadEventsFromFile();
    setState(() {
      _events = loadedEvents;
    });
  }

  Future<void> _saveEvents() async {
    await saveEventsToFile(_events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Calendar'
              : _selectedIndex == 1
              ? 'Task'
              : _selectedIndex == 2
              ? 'Locked Page'
              : 'Fish Tank', // Fish Tank 作为第四项
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
          // IconButton(
          //   icon: Icon(Icons.today),
          //   onPressed: _selectedIndex == 0
          //       ? () {
          //     CalendarPageState? calendarState = context.findAncestorStateOfType<CalendarPageState>();
          //     if (calendarState != null) {
          //       calendarState._goToToday();
          //     }
          //   }
          //       : null,
          // ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    groupColors: widget.groupColors,
                    onColorChanged: widget.onColorChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? CalendarPage(
        events: _events,
        onEventsUpdated: (newEvents) {
          setState(() {
            _events = newEvents;
            _saveEvents();
          });
        },
        groupColors: widget.groupColors,
      ) // 传递 group 颜色给 CalendarPage
          : _selectedIndex == 1
          ? TaskPage(events: _events, groupColors: widget.groupColors)
          : _selectedIndex == 2
          ? LockedPage() // LockedPage 第三项
          : FishTankPage(), // FishTankPage 第四项
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Locked',  // LockedPage 项
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Fish Tank', // Fish Tank 项
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final Map<DateTime, List<Event>> events;
  final Function(Map<DateTime, List<Event>>) onEventsUpdated;
  final Map<String, Color> groupColors;  // 添加 group 颜色 map

  CalendarPage({
    required this.events,
    required this.onEventsUpdated,
    required this.groupColors,
  });

  @override
  CalendarPageState createState() => CalendarPageState();

}

//
class CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
              CalendarFormat.week: 'Week',
            },
            eventLoader: (day) {
              return widget.events[day] ?? [];
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: _selectedDay != null && widget.events[_selectedDay] != null
                ? _buildEventList(widget.events[_selectedDay]!)
                : Center(child: Text('No Event for Today')),
          ),
        ],
      ),
      floatingActionButton: _selectedDay != null
          ? FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _showAddEventDialog(_selectedDay!);
          }
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }

  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = _focusedDay;
    });
  }

  Widget _buildEventList(List<Event> events) {
    events.sort((a, b) => a.time.hour.compareTo(b.time.hour));
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        Color groupColor = widget.groupColors[event.group] ?? Colors.blueGrey;

        return Card(
          color: groupColor.withOpacity(0.3),  // 设置事件颜色
          child: ListTile(
            title: Text("${event.time.format(context)} - ${event.title}"),
            subtitle: Text('${event.subtitle} (Group: ${event.group})'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditEventDialog(event, index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmation(event, index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEventDialog(DateTime selectedDay) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _subtitleController = TextEditingController();
    TextEditingController _groupController =
    TextEditingController(text: 'ungrouped');
    TimeOfDay selectedTime = TimeOfDay.now();

    bool groupTouched = false; // 用于判断是否用户触摸了输入框

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(hintText: 'Main Title'),
                  ),
                  TextField(
                    controller: _subtitleController,
                    decoration:
                    InputDecoration(hintText: 'Subtitle (Optional)'),
                  ),
                  TextField(
                    controller: _groupController,
                    decoration: InputDecoration(hintText: 'Group Name'),
                    onTap: () {
                      // 用户点击输入框时清空
                      if (!groupTouched) {
                        setState(() {
                          _groupController.clear();
                          groupTouched = true;
                        });
                      }
                    },
                    onChanged: (value) {
                      // 如果用户清空了输入框，恢复默认值
                      if (value.isEmpty) {
                        setState(() {
                          _groupController.text = 'ungrouped';
                          _groupController.selection =
                              TextSelection.fromPosition(
                                TextPosition(
                                    offset: _groupController.text.length),
                              );
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Text('Pick Time'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Selected Time: ${selectedTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      setState(() {
                        if (widget.events[selectedDay] == null) {
                          widget.events[selectedDay] = [];
                        }
                        widget.events[selectedDay]!.add(Event(
                          title: _titleController.text,
                          subtitle: _subtitleController.text,
                          time: selectedTime,
                          group: _groupController.text.isEmpty
                              ? 'ungrouped'
                              : _groupController.text,
                        ));
                      });
                      widget.onEventsUpdated(widget.events); // 更新事件
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditEventDialog(Event event, int index) {
    TextEditingController _titleController =
    TextEditingController(text: event.title);
    TextEditingController _subtitleController =
    TextEditingController(text: event.subtitle);
    TextEditingController _groupController =
    TextEditingController(text: event.group);
    TimeOfDay selectedTime = event.time;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'Main Title'),
              ),
              TextField(
                controller: _subtitleController,
                decoration: InputDecoration(hintText: 'Subtitle (Optional)'),
              ),
              TextField(
                controller: _groupController,
                decoration: InputDecoration(hintText: 'Group Name'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
                child: Text('Pick Time'),
              ),
              SizedBox(height: 8),
              Text(
                'Selected Time: ${selectedTime.format(context)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  event.title = _titleController.text;
                  event.subtitle = _subtitleController.text;
                  event.group = _groupController.text.isEmpty
                      ? 'ungrouped'
                      : _groupController.text;
                  event.time = selectedTime;
                });
                widget.onEventsUpdated(widget.events);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Event event, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.events[_selectedDay]!.removeAt(index);
                });
                widget.onEventsUpdated(widget.events);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class Event {
  String title;
  String subtitle;
  TimeOfDay time;
  String group;

  Event({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.group,
  });
}

// Dummy functions for loading and saving events
Future<Map<DateTime, List<Event>>> loadEventsFromFile() async {
  return {};
}

Future<void> saveEventsToFile(Map<DateTime, List<Event>> events) async {
  // Implement your file saving logic here
}
