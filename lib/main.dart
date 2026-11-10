import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:file_picker/file_picker.dart';

// ==========================================
// EVENT CATEGORIES
// ==========================================
enum EventCategory {
  birthday,
  anniversary,
  memorial,
  work,
  graduation,
  home,
  pet,
  health,
  other,
}

extension EventCategoryExtension on EventCategory {
  String get nameKey {
    switch (this) {
      case EventCategory.birthday: return 'catBirthday';
      case EventCategory.anniversary: return 'catAnniversary';
      case EventCategory.memorial: return 'catMemorial';
      case EventCategory.work: return 'catWork';
      case EventCategory.graduation: return 'catGraduation';
      case EventCategory.home: return 'catHome';
      case EventCategory.pet: return 'catPet';
      case EventCategory.health: return 'catHealth';
      case EventCategory.other: return 'catOther';
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case EventCategory.birthday: return Icons.cake;
      case EventCategory.anniversary: return Icons.favorite;
      case EventCategory.memorial: return Icons.filter_vintage;
      case EventCategory.work: return Icons.work;
      case EventCategory.graduation: return Icons.school;
      case EventCategory.home: return Icons.home;
      case EventCategory.pet: return Icons.pets;
      case EventCategory.health: return Icons.local_hospital;
      case EventCategory.other: return Icons.event_note;
    }
  }

  Color get defaultColor {
    switch (this) {
      case EventCategory.birthday: return Colors.blue;
      case EventCategory.anniversary: return Colors.amber.shade700;
      case EventCategory.memorial: return Colors.purple;
      case EventCategory.work: return Colors.pinkAccent;
      case EventCategory.graduation: return Colors.amber;
      case EventCategory.home: return Colors.teal;
      case EventCategory.pet: return Colors.orange;
      case EventCategory.health: return Colors.green;
      case EventCategory.other: return Colors.indigo;
    }
  }
}

// ==========================================
// I18N / Localizations Helper
// ==========================================
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Fixed Event Tracker',
      'noEvents': 'No events added yet. Tap + to add one!',
      'addEvent': 'Add Event',
      'editEvent': 'Edit Event',
      'description': 'Description',
      'pickDate': 'Pick Date',
      'cancel': 'Cancel',
      'save': 'Save',
      'add': 'Add',
      'deleteTitle': 'Delete Event?',
      'deleteAction': 'Delete',
      'csvShareText': 'Here is my events CSV export.',
      'notificationTitle': 'Upcoming Event Reminder!',
      'notificationBody': 'is happening soon!',
      'settings': 'Settings',
      'language': 'Language',
      'appearance': 'Appearance',
      'themeMode': 'Theme Mode',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',
      'dataManagement': 'Data Management',
      'exportCsv': 'Export Events (CSV)',
      'importCsv': 'Import Events (CSV)',
      'importSuccess': 'Events imported successfully!',
      'importFailed': 'Failed to import CSV file.',
      'category': 'Category',
      'catBirthday': 'Birthday',
      'catAnniversary': 'Anniversary / Wedding',
      'catMemorial': 'Memorial / Passing',
      'catWork': 'Work & Career',
      'catGraduation': 'Graduation & Education',
      'catHome': 'Home & Living',
      'catPet': 'Pet Milestone',
      'catHealth': 'Health & Fitness',
      'catOther': 'Other Event',
      'remindBefore': 'Reminder Advance',
      'remind0': 'On the day of event',
      'remind1': '1 day before',
      'remind3': '3 days before',
      'remind7': '1 week before',
    },
    'pt': {
      'appTitle': 'Gestor de Eventos Fixos',
      'noEvents': 'Sem eventos adicionados. Toque em + para adicionar um!',
      'addEvent': 'Adicionar Evento',
      'editEvent': 'Editar Evento',
      'description': 'Descrição',
      'pickDate': 'Escolher Data',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'add': 'Adicionar',
      'deleteTitle': 'Eliminar Evento?',
      'deleteAction': 'Eliminar',
      'csvShareText': 'Aqui está a exportação CSV dos meus eventos.',
      'notificationTitle': 'Lembrete de Evento!',
      'notificationBody': 'ocorre brevemente!',
      'settings': 'Definições',
      'language': 'Idioma',
      'appearance': 'Aparência',
      'themeMode': 'Tema',
      'lightTheme': 'Claro',
      'darkTheme': 'Escuro',
      'systemTheme': 'Sistema',
      'dataManagement': 'Gestão de Dados',
      'exportCsv': 'Exportar Eventos (CSV)',
      'importCsv': 'Importar Eventos (CSV)',
      'importSuccess': 'Eventos importados com sucesso!',
      'importFailed': 'Falha ao importar ficheiro CSV.',
      'category': 'Categoria',
      'catBirthday': 'Aniversário de Nascimento',
      'catAnniversary': 'Aniversário de Casamento',
      'catMemorial': 'Memória / Falecimento',
      'catWork': 'Trabalho e Carreira',
      'catGraduation': 'Graduação e Educação',
      'catHome': 'Casa e Habitação',
      'catPet': 'Evento de Mascote',
      'catHealth': 'Saúde e Bem-estar',
      'catOther': 'Outro Evento',
      'remindBefore': 'Antecedência do Lembrete',
      'remind0': 'No dia do evento',
      'remind1': '1 dia antes',
      'remind3': '3 dias antes',
      'remind7': '1 semana antes',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pt'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const EventTrackerApp());
}

class EventTrackerApp extends StatefulWidget {
  const EventTrackerApp({super.key});

  static EventTrackerAppState of(BuildContext context) =>
      context.findAncestorStateOfType<EventTrackerAppState>()!;

  @override
  State<EventTrackerApp> createState() => EventTrackerAppState();
}

class EventTrackerAppState extends State<EventTrackerApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? langCode = prefs.getString('saved_language_code');
    final String? themeStr = prefs.getString('saved_theme_mode');
    ThemeMode loadedTheme = ThemeMode.system;
    if (themeStr == 'light') loadedTheme = ThemeMode.light;
    if (themeStr == 'dark') loadedTheme = ThemeMode.dark;

    setState(() {
      if (langCode != null) _locale = Locale(langCode);
      _themeMode = loadedTheme;
    });
  }

  void setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('saved_language_code');
    } else {
      await prefs.setString('saved_language_code', locale.languageCode);
    }
    setState(() {
      _locale = locale;
    });
  }

  void setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeStr = 'system';
    if (mode == ThemeMode.light) themeStr = 'light';
    if (mode == ThemeMode.dark) themeStr = 'dark';

    await prefs.setString('saved_theme_mode', themeStr);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixed Event Tracker',
      locale: _locale,
      themeMode: _themeMode,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt', ''),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const EventListScreen(),
    );
  }
}

class EventItem {
  String id;
  String description;
  DateTime date;
  int iconCodePoint;
  int colorValue;
  EventCategory category;
  int remindDaysBefore;

  EventItem({
    required this.id,
    required this.description,
    required this.date,
    int? iconCodePoint,
    int? colorValue,
    EventCategory? category,
    int? remindDaysBefore,
  })  : category = category ?? EventCategory.other,
        remindDaysBefore = remindDaysBefore ?? 0,
        iconCodePoint = iconCodePoint ?? (category?.defaultIcon.codePoint ?? 0xe123),
        colorValue = colorValue ?? (category?.defaultColor.toARGB32() ?? 0xFF2196F3);

  // Safe getter that maps stored code points to compile-time constant Icons,
  // allowing Flutter's icon tree-shaker to recognize and bundle them.
  IconData get icon {
    const knownIcons = [
      Icons.event_note,
      Icons.cake,
      Icons.favorite,
      Icons.filter_vintage,
      Icons.local_hospital,
      Icons.receipt_long,
      Icons.directions_car,
      Icons.work,
      Icons.flight,
      Icons.fitness_center,
      Icons.school,
      Icons.pets,
      Icons.home,
      Icons.star,
    ];

    for (final ic in knownIcons) {
      if (ic.codePoint == iconCodePoint) {
        return ic;
      }
    }
    return Icons.event_note; // Fallback default constant icon
  }

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'date': date.toIso8601String(),
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'category': category.name,
        'remindDaysBefore': remindDaysBefore,
      };

  factory EventItem.fromJson(Map<String, dynamic> json) => EventItem(
        id: json['id'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        iconCodePoint: json['iconCodePoint'],
        colorValue: json['colorValue'],
        category: EventCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => EventCategory.other,
        ),
        remindDaysBefore: json['remindDaysBefore'] ?? 0,
      );

  int get yearsDifference {
    final now = DateTime.now();
    int years = now.year - date.year;
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime nextOccurrence = DateTime(today.year, date.month, date.day);

    if (nextOccurrence.isBefore(today)) {
      nextOccurrence = DateTime(today.year + 1, date.month, date.day);
    }
    return nextOccurrence.difference(today).inDays;
  }

  DateTime get nextOccurrenceDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime nextOccurrence = DateTime(today.year, date.month, date.day, 9, 0);

    if (nextOccurrence.isBefore(now)) {
      nextOccurrence = DateTime(today.year + 1, date.month, date.day, 9, 0);
    }
    return nextOccurrence.subtract(Duration(days: remindDaysBefore));
  }
}

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<EventItem> _events = [];

  final List<IconData> availableIcons = [
    Icons.event_note,
    Icons.cake,
    Icons.favorite,
    Icons.filter_vintage,
    Icons.local_hospital,
    Icons.receipt_long,
    Icons.directions_car,
    Icons.work,
    Icons.flight,
    Icons.fitness_center,
    Icons.school,
    Icons.pets,
    Icons.home,
    Icons.star,
  ];

  final List<Color> availableColors = [
    Colors.pinkAccent,
    Colors.amber.shade700,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadEvents();
  }

  Future<void> _requestPermissions() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('saved_events');
    if (eventsString != null) {
      final List decoded = jsonDecode(eventsString);
      setState(() {
        _events = decoded.map((e) => EventItem.fromJson(e)).toList();
        _sortEvents();
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_events.map((e) => e.toJson()).toList());
    await prefs.setString('saved_events', encoded);
  }

  void _sortEvents() {
    _events.sort((a, b) => a.daysUntilNext.compareTo(b.daysUntilNext));
  }

  Future<void> _scheduleNotification(EventItem event, BuildContext context) async {
    final int notificationId = event.id.hashCode.abs();
    final l10n = AppLocalizations.of(context);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_channel_id',
      'Event Reminders',
      channelDescription: 'Notifications for upcoming saved events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(event.nextOccurrenceDate, tz.local);

    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        l10n.get('notificationTitle'),
        '${event.description} ${l10n.get('notificationBody')}',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  Future<void> _cancelNotification(String id) async {
    final int notificationId = id.hashCode.abs();
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  void _showEventDialog({EventItem? event}) {
    final isEditing = event != null;
    final descController = TextEditingController(text: event?.description ?? '');
    DateTime selectedDate = event?.date ?? DateTime.now();
    
    EventCategory selectedCategory = event?.category ?? EventCategory.birthday;
    int selectedIconCode = event?.iconCodePoint ?? selectedCategory.defaultIcon.codePoint;
    int selectedColorValue = event?.colorValue ?? selectedCategory.defaultColor.toARGB32();
    int selectedRemindDays = event?.remindDaysBefore ?? 0;

    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? l10n.get('editEvent') : l10n.get('addEvent')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<EventCategory>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(labelText: l10n.get('category')),
                      items: EventCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.defaultIcon, color: cat.defaultColor, size: 20),
                              const SizedBox(width: 10),
                              Text(l10n.get(cat.nameKey)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newCat) {
                        if (newCat != null) {
                          setDialogState(() {
                            selectedCategory = newCat;
                            selectedIconCode = newCat.defaultIcon.codePoint;
                            selectedColorValue = newCat.defaultColor.toARGB32();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(labelText: l10n.get('description')),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedRemindDays,
                      decoration: InputDecoration(labelText: l10n.get('remindBefore')),
                      items: [
                        DropdownMenuItem(value: 0, child: Text(l10n.get('remind0'))),
                        DropdownMenuItem(value: 1, child: Text(l10n.get('remind1'))),
                        DropdownMenuItem(value: 3, child: Text(l10n.get('remind3'))),
                        DropdownMenuItem(value: 7, child: Text(l10n.get('remind7'))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRemindDays = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}'),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(l10n.get('pickDate')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Choose Icon:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = availableIcons[index];
                          final isSelected = selectedIconCode == icon.codePoint;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedIconCode = icon.codePoint;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                              ),
                              child: Icon(icon, size: 24, color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Choose Color:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableColors.length,
                        itemBuilder: (context, index) {
                          final color = availableColors[index];
                          final isSelected = selectedColorValue == color.toARGB32();
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColorValue = color.toARGB32();
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2.5)
                                    : null,
                              ),
                              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (descController.text.trim().isEmpty) return;
                    setState(() {
                      if (isEditing) {
                        _cancelNotification(event.id);
                        event.description = descController.text.trim();
                        event.date = selectedDate;
                        event.iconCodePoint = selectedIconCode;
                        event.colorValue = selectedColorValue;
                        event.category = selectedCategory;
                        event.remindDaysBefore = selectedRemindDays;
                        _scheduleNotification(event, context);
                      } else {
                        final newEvent = EventItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          description: descController.text.trim(),
                          date: selectedDate,
                          iconCodePoint: selectedIconCode,
                          colorValue: selectedColorValue,
                          category: selectedCategory,
                          remindDaysBefore: selectedRemindDays,
                        );
                        _events.add(newEvent);
                        _scheduleNotification(newEvent, context);
                      }
                      _sortEvents();
                      _saveEvents();
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: Text(isEditing ? l10n.get('save') : l10n.get('add')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(EventItem event, int index) async {
    final l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.get('deleteTitle')),
          content: Text('Are you sure you want to remove "${event.description}"? This is a fixed event.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.get('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.get('deleteAction')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _cancelNotification(event.id);
        _events.removeAt(index);
        _saveEvents();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${event.description} deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('appTitle')),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.get('settings'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    events: _events,
                    onEventsUpdated: () {
                      _loadEvents();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _events.isEmpty
          ? Center(child: Text(l10n.get('noEvents')))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90), // 👈 Added padding so the FAB never covers the last card!
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: event.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                event.icon,
                                size: 26,
                                color: event.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    event.description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.get(event.category.nameKey),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: event.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade400),
                                  tooltip: l10n.get('editEvent'),
                                  onPressed: () => _showEventDialog(event: event),
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade400),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _confirmDelete(event, index);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.get('deleteAction'),
                                            style: const TextStyle(color: Colors.red, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd-MM-yyyy').format(event.date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: event.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${event.yearsDifference} yrs',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: event.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white60
                                      : Colors.grey,
                                  fontFamily: 'Roboto',
                                ),
                                children: [
                                  const TextSpan(text: 'Next in: '),
                                  TextSpan(
                                    text: '${event.daysUntilNext} days',
                                    style: TextStyle(
                                      color: event.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// SETTINGS SCREEN
// ==========================================
class SettingsScreen extends StatelessWidget {
  final List<EventItem> events;
  final VoidCallback onEventsUpdated;

  const SettingsScreen({
    super.key,
    required this.events,
    required this.onEventsUpdated,
  });

  Future<void> _exportCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    List<List<dynamic>> rows = [];
    rows.add(['ID', 'Description', 'Date', 'IconCodePoint', 'ColorValue', 'Category', 'RemindDaysBefore']);
    for (var event in events) {
      rows.add([
        event.id,
        event.description,
        event.date.toIso8601String(),
        event.iconCodePoint,
        event.colorValue,
        event.category.name,
        event.remindDaysBefore,
      ]);
    }
    String csvData = const ListToCsvConverter().convert(rows);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/events_export.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)], text: l10n.get('csvShareText'));
  }

  Future<void> _importCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        final PlatformFile platformFile = result.files.single;
        
        String csvContent = '';
        if (platformFile.bytes != null) {
          csvContent = utf8.decode(platformFile.bytes!);
        } else if (platformFile.path != null) {
          final file = File(platformFile.path!);
          csvContent = await file.readAsString();
        } else {
          csvContent = await platformFile.xFile.readAsString();
        }

        final fields = const CsvToListConverter().convert(csvContent);

        if (fields.length <= 1) return;

        List<EventItem> importedEvents = [];
        for (int i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length >= 3) {
            EventCategory parsedCategory = EventCategory.other;
            if (row.length >= 6) {
              parsedCategory = EventCategory.values.firstWhere(
                (e) => e.name == row[5].toString(),
                orElse: () => EventCategory.other,
              );
            }

            int parsedRemindDays = 0;
            if (row.length >= 7) {
              parsedRemindDays = int.tryParse(row[6].toString()) ?? 0;
            }

            importedEvents.add(
              EventItem(
                id: row[0].toString(),
                description: row[1].toString(),
                date: DateTime.parse(row[2].toString()),
                iconCodePoint: row.length >= 4 ? int.tryParse(row[3].toString()) ?? parsedCategory.defaultIcon.codePoint : parsedCategory.defaultIcon.codePoint,
                colorValue: row.length >= 5 ? int.tryParse(row[4].toString()) ?? parsedCategory.defaultColor.toARGB32() : parsedCategory.defaultColor.toARGB32(),
                category: parsedCategory,
                remindDaysBefore: parsedRemindDays,
              ),
            );
          }
        }

        final prefs = await SharedPreferences.getInstance();
        final String encoded = jsonEncode(importedEvents.map((e) => e.toJson()).toList());
        await prefs.setString('saved_events', encoded);

        onEventsUpdated();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.get('importSuccess'))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.get('importFailed')} ($e)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);
    final currentThemeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('settings')),
      ),
      body: ListView(
        children: [
          // Language Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.get('language'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.get('language')),
            trailing: DropdownButton<String>(
              value: ['en', 'pt'].contains(currentLocale.languageCode)
                  ? currentLocale.languageCode
                  : 'en',
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English 🇺🇸'),
                ),
                DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português 🇵🇹'),
                ),
              ],
              onChanged: (String? newLanguageCode) {
                if (newLanguageCode != null) {
                  EventTrackerApp.of(context).setLocale(Locale(newLanguageCode));
                }
              },
            ),
          ),
          const Divider(),

          // Appearance Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.get('appearance'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.get('themeMode')),
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.get('lightTheme')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.get('darkTheme')),
                ),
              ],
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  EventTrackerApp.of(context).setThemeMode(newMode);
                }
              },
            ),
          ),
          const Divider(),

          // Data Management Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.get('dataManagement'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l10n.get('exportCsv')),
            onTap: events.isEmpty ? null : () => _exportCsv(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline),
            title: Text(l10n.get('importCsv')),
            onTap: () => _importCsv(context),
          ),
        ],
      ),
    );
  }
}