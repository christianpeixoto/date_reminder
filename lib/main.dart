import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
// EVENT CATEGORIES & RECURRENCE
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
  medication,
  finance,
  routine,
  other,
}

enum RecurrenceType {
  yearly,
  monthly,
  biweekly,
  weekly,
}

const List<IconData> kAppIcons = [
  Icons.event_note,
  Icons.cake,
  Icons.favorite,
  Icons.filter_vintage,
  Icons.local_hospital,
  Icons.medication,
  Icons.payments,
  Icons.repeat,
  Icons.alarm,
  Icons.shopping_cart,
  Icons.cleaning_services,
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

extension EventCategoryExtension on EventCategory {
  String get nameKey {
    switch (this) {
      case EventCategory.birthday:
        return 'catBirthday';
      case EventCategory.anniversary:
        return 'catAnniversary';
      case EventCategory.memorial:
        return 'catMemorial';
      case EventCategory.work:
        return 'catWork';
      case EventCategory.graduation:
        return 'catGraduation';
      case EventCategory.home:
        return 'catHome';
      case EventCategory.pet:
        return 'catPet';
      case EventCategory.health:
        return 'catHealth';
      case EventCategory.medication:
        return 'catMedication';
      case EventCategory.finance:
        return 'catFinance';
      case EventCategory.routine:
        return 'catRoutine';
      case EventCategory.other:
        return 'catOther';
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case EventCategory.birthday:
        return Icons.cake;
      case EventCategory.anniversary:
        return Icons.favorite;
      case EventCategory.memorial:
        return Icons.filter_vintage;
      case EventCategory.work:
        return Icons.work;
      case EventCategory.graduation:
        return Icons.school;
      case EventCategory.home:
        return Icons.home;
      case EventCategory.pet:
        return Icons.pets;
      case EventCategory.health:
        return Icons.local_hospital;
      case EventCategory.medication:
        return Icons.medication;
      case EventCategory.finance:
        return Icons.payments;
      case EventCategory.routine:
        return Icons.repeat;
      case EventCategory.other:
        return Icons.event_note;
    }
  }

  Color get defaultColor {
    switch (this) {
      case EventCategory.birthday:
        return Colors.blue;
      case EventCategory.anniversary:
        return Colors.amber.shade700;
      case EventCategory.memorial:
        return Colors.purple;
      case EventCategory.work:
        return Colors.pinkAccent;
      case EventCategory.graduation:
        return Colors.amber;
      case EventCategory.home:
        return Colors.teal;
      case EventCategory.pet:
        return Colors.orange;
      case EventCategory.health:
        return Colors.green;
      case EventCategory.medication:
        return Colors.redAccent;
      case EventCategory.finance:
        return Colors.green.shade700;
      case EventCategory.routine:
        return Colors.deepPurple;
      case EventCategory.other:
        return Colors.indigo;
    }
  }

  static List<EventCategory> categoriesFor(RecurrenceType recurrence) {
    if (recurrence == RecurrenceType.yearly) {
      return const [
        EventCategory.birthday,
        EventCategory.anniversary,
        EventCategory.memorial,
        EventCategory.graduation,
        EventCategory.pet,
        EventCategory.other,
      ];
    }
    return const [
      EventCategory.medication,
      EventCategory.finance,
      EventCategory.routine,
      EventCategory.health,
      EventCategory.work,
      EventCategory.home,
      EventCategory.pet,
      EventCategory.other,
    ];
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
        AppLocalizations(const Locale('pt'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Date Reminder: Fixed Events',
      'tabMilestones': 'Milestones',
      'tabRecurring': 'Recurring',
      'noEvents': 'No events added yet. Tap + to add one!',
      'noRecurring': 'No weekly or monthly reminders yet. Tap + to add one!',
      'addEvent': 'Add Event',
      'editEvent': 'Edit Event',
      'description': 'Description',
      'pickDate': 'Pick Date',
      'startsOn': 'Starts on',
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
      'catMedication': 'Medication',
      'catFinance': 'Salary & Bills',
      'catRoutine': 'Routine & Chores',
      'catOther': 'Other Event',
      'remindBefore': 'Reminder Advance',
      'remind0': 'On the day of event',
      'remind1': '1 day before',
      'remind3': '3 days before',
      'remind7': '1 week before',
      'repeat': 'Repeat',
      'recYearly': 'Yearly (Fixed Date)',
      'recMonthly': 'Monthly (Day of Month)',
      'recBiweekly': 'Every 2 Weeks',
      'recWeekly': 'Weekly (Day of Week)',
      'dayOfWeek': 'Day of Week',
      'dayOfMonth': 'Day of Month',
      'everyBiweekly': 'Every 2 weeks',
      'everyDayOfMonth': 'Day',
      'weekday1': 'Monday',
      'weekday2': 'Tuesday',
      'weekday3': 'Wednesday',
      'weekday4': 'Thursday',
      'weekday5': 'Friday',
      'weekday6': 'Saturday',
      'weekday7': 'Sunday',
      'privacyPolicy': 'Privacy Policy',
      'privacyDialogTitle': 'Privacy Policy & Data Notice',
      'privacyDialogBody':
          'Date Reminder: Fixed Events stores all your events locally on your device and does not collect, store, or share any personally identifiable information on external servers. Local notifications are used only for the reminders you schedule.\n\nPlease read and agree to our Privacy Policy before continuing.',
      'viewPrivacyPolicy': 'Read Full Privacy Policy',
      'agreeAndContinue': 'Agree & Continue',
      'declineAndExit': 'Decline',
      'privacyFullText':
          'Privacy Policy & Child Safety Standards for Date Reminder: Fixed Events\n\n'
          'Effective Date: November 15, 2026\n\n'
          'Christian Peixoto built the Date Reminder: Fixed Events app as a Free app. This service is provided by Christian Peixoto and is intended for use as is.\n\n'
          'Information Collection and Use\n'
          'Date Reminder: Fixed Events does not collect, store, or share any personally identifiable information (such as your name, email address, phone number, or precise location) on external servers.\n\n'
          'Children\'s Privacy\n'
          'This app does not knowingly collect personally identifiable information from children under the age of 13.\n\n'
          'Changes to This Privacy Policy\n'
          'We may update our Privacy Policy from time to time. You are advised to review this page periodically for any changes.\n\n'
          'Contact Us\n'
          'If you have any questions or suggestions about this Privacy Policy, contact us at: christianpeixotobrasil@gmail.com.\n\n'
          '---\n\n'
          'Addendum: Child Safety Standards and CSAE Policy\n\n'
          'Effective Date: November 15, 2026\n\n'
          'Date Reminder: Fixed Events and Christian Peixoto maintain a strict zero-tolerance policy toward Child Sexual Abuse and Exploitation (CSAE). Our app does not allow, facilitate, or distribute any content related to child sexual abuse material (CSAM) or the endangerment of minors.\n\n'
          'If you encounter any inappropriate or illegal content related to child safety within our ecosystem, you can report it immediately by contacting us at christianpeixotobrasil@gmail.com, and appropriate action will be taken.',
    },
    'pt': {
      'appTitle': 'Date Reminder: Fixed Events',
      'tabMilestones': 'Marcos Anuais',
      'tabRecurring': 'Recorrentes',
      'noEvents': 'Sem eventos adicionados. Toque em + para adicionar um!',
      'noRecurring':
          'Sem lembretes semanais ou mensais. Toque em + para adicionar!',
      'addEvent': 'Adicionar Evento',
      'editEvent': 'Editar Evento',
      'description': 'Descrição',
      'pickDate': 'Escolher Data',
      'startsOn': 'Início em',
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
      'catMedication': 'Medicação',
      'catFinance': 'Salário e Contas',
      'catRoutine': 'Rotina e Tarefas',
      'catOther': 'Outro Evento',
      'remindBefore': 'Antecedência do Lembrete',
      'remind0': 'No dia do evento',
      'remind1': '1 dia antes',
      'remind3': '3 dias antes',
      'remind7': '1 semana antes',
      'repeat': 'Repetir',
      'recYearly': 'Anual (Data Fixa)',
      'recMonthly': 'Mensal (Dia do Mês)',
      'recBiweekly': 'A cada 2 Semanas',
      'recWeekly': 'Semanal (Dia da Semana)',
      'dayOfWeek': 'Dia da Semana',
      'dayOfMonth': 'Dia do Mês',
      'everyBiweekly': 'A cada 2 semanas',
      'everyDayOfMonth': 'Dia',
      'weekday1': 'Segunda-feira',
      'weekday2': 'Terça-feira',
      'weekday3': 'Quarta-feira',
      'weekday4': 'Quinta-feira',
      'weekday5': 'Sexta-feira',
      'weekday6': 'Sábado',
      'weekday7': 'Domingo',
      'privacyPolicy': 'Política de Privacidade',
      'privacyDialogTitle': 'Política de Privacidade e Aviso de Dados',
      'privacyDialogBody':
          'O Date Reminder: Fixed Events guarda todos os seus eventos localmente no seu dispositivo e não recolhe, armazena nem partilha informações pessoalmente identificáveis em servidores externos. As notificações locais são usadas apenas para os lembretes que agendar.\n\nPor favor, leia e aceite a nossa Política de Privacidade antes de continuar.',
      'viewPrivacyPolicy': 'Ler Política de Privacidade Completa',
      'agreeAndContinue': 'Concordar e Continuar',
      'declineAndExit': 'Recusar',
      'privacyFullText':
          'Política de Privacidade e Padrões de Segurança Infantil para Date Reminder: Fixed Events\n\n'
          'Data de Entrada em Vigor: 15 de novembro de 2026\n\n'
          'Christian Peixoto criou a aplicação Date Reminder: Fixed Events como uma aplicação Gratuita. Este serviço é fornecido por Christian Peixoto e destina-se a ser utilizado tal como está.\n\n'
          'Recolha e Utilização de Informações\n'
          'O Date Reminder: Fixed Events não recolhe, armazena nem partilha quaisquer informações pessoalmente identificáveis (tais como o seu nome, endereço de e-mail, número de telefone ou localização precisa) em servidores externos.\n\n'
          'Privacidade das Crianças\n'
          'Esta aplicação não recolhe intencionalmente informações pessoalmente identificáveis de crianças com menos de 13 anos.\n\n'
          'Alterações a Esta Política de Privacidade\n'
          'Podemos atualizar a nossa Política de Privacidade periodicamente. Aconselha-se que reveja esta página regularmente para verificar eventuais alterações.\n\n'
          'Contacte-nos\n'
          'Se tiver alguma dúvida ou sugestão sobre esta Política de Privacidade, contacte-nos através de: christianpeixotobrasil@gmail.com.\n\n'
          '---\n\n'
          'Adenda: Padrões de Segurança Infantil e Política CSAE\n\n'
          'Data de Entrada em Vigor: 15 de novembro de 2026\n\n'
          'O Date Reminder: Fixed Events e Christian Peixoto mantêm uma política estrita de tolerância zero relativamente ao Abuso e Exploração Sexual Infantil (CSAE). A nossa aplicação não permite, facilita nem distribui qualquer conteúdo relacionado com material de abuso sexual infantil (CSAM) ou que coloque menores em perigo.\n\n'
          'Se encontrar qualquer conteúdo inadequado ou ilegal relacionado com a segurança infantil no nosso ecossistema, pode denunciá-lo imediatamente contactando-nos através de christianpeixotobrasil@gmail.com, e serão tomadas as medidas adequadas.',
    },
    'es': {
      'appTitle': 'Date Reminder: Eventos Fijos',
      'tabMilestones': 'Hitos Anuales',
      'tabRecurring': 'Recurrentes',
      'noEvents': '¡No hay eventos añadidos. Toca + para añadir uno!',
      'noRecurring':
          'Sin recordatorios semanales o mensuales. ¡Toca + para añadir!',
      'addEvent': 'Añadir Evento',
      'editEvent': 'Editar Evento',
      'description': 'Descripción',
      'pickDate': 'Elegir Fecha',
      'startsOn': 'Empieza el',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'add': 'Añadir',
      'deleteTitle': '¿Eliminar Evento?',
      'deleteAction': 'Eliminar',
      'csvShareText': 'Aquí está la exportación CSV de mis eventos.',
      'notificationTitle': '¡Recordatorio de Evento!',
      'notificationBody': 'ocurre pronto!',
      'settings': 'Ajustes',
      'language': 'Idioma',
      'appearance': 'Apariencia',
      'themeMode': 'Modo de Tema',
      'lightTheme': 'Claro',
      'darkTheme': 'Oscuro',
      'systemTheme': 'Sistema',
      'dataManagement': 'Gestión de Datos',
      'exportCsv': 'Exportar Eventos (CSV)',
      'importCsv': 'Importar Eventos (CSV)',
      'importSuccess': '¡Eventos importados con éxito!',
      'importFailed': 'Fallo al importar el archivo CSV.',
      'category': 'Categoría',
      'catBirthday': 'Cumpleaños',
      'catAnniversary': 'Aniversario / Boda',
      'catMemorial': 'Memorial / Fallecimiento',
      'catWork': 'Trabajo y Carrera',
      'catGraduation': 'Graduación y Educación',
      'catHome': 'Hogar y Vivienda',
      'catPet': 'Hito de Mascota',
      'catHealth': 'Salud y Bienestar',
      'catMedication': 'Medicación',
      'catFinance': 'Salario y Facturas',
      'catRoutine': 'Rutina y Tareas',
      'catOther': 'Otro Evento',
      'remindBefore': 'Anticipación del Recordatorio',
      'remind0': 'El día del evento',
      'remind1': '1 día antes',
      'remind3': '3 días antes',
      'remind7': '1 semana antes',
      'repeat': 'Repetir',
      'recYearly': 'Anual (Fecha Fija)',
      'recMonthly': 'Mensual (Día del Mes)',
      'recBiweekly': 'Cada 2 Semanas',
      'recWeekly': 'Semanal (Día de la Semana)',
      'dayOfWeek': 'Día de la Semana',
      'dayOfMonth': 'Día del Mes',
      'everyBiweekly': 'Cada 2 semanas',
      'everyDayOfMonth': 'Día',
      'weekday1': 'Lunes',
      'weekday2': 'Martes',
      'weekday3': 'Miércoles',
      'weekday4': 'Jueves',
      'weekday5': 'Viernes',
      'weekday6': 'Sábado',
      'weekday7': 'Domingo',
      'privacyPolicy': 'Política de Privacidad',
      'privacyDialogTitle': 'Política de Privacidad y Aviso de Datos',
      'privacyDialogBody':
          'Date Reminder: Fixed Events guarda todos tus eventos localmente en tu dispositivo y no recopila, almacena ni comparte información personal identificable en servidores externos. Las notificaciones locales se usan solo para los recordatorios que programes.\n\nPor favor, lee y acepta nuestra Política de Privacidad antes de continuar.',
      'viewPrivacyPolicy': 'Leer Política de Privacidad Completa',
      'agreeAndContinue': 'Aceptar y Continuar',
      'declineAndExit': 'Rechazar',
      'privacyFullText':
          'Política de Privacidad y Estándares de Seguridad Infantil para Date Reminder: Fixed Events\n\n'
          'Fecha de entrada en vigor: 15 de noviembre de 2026\n\n'
          'Christian Peixoto creó la aplicación Date Reminder: Fixed Events como una aplicación Gratuita. Este servicio es proporcionado por Christian Peixoto y está destinado a utilizarse tal cual.\n\n'
          'Recopilación y uso de la información\n'
          'Date Reminder: Fixed Events no recopila, almacena ni comparte ninguna información personal identificable (como tu nombre, dirección de correo electrónico, número de teléfono o ubicación precisa) en servidores externos.\n\n'
          'Privacidad de los menores\n'
          'Esta aplicación no recopila intencionadamente información personal identificable de menores de 13 años.\n\n'
          'Cambios en esta Política de Privacidad\n'
          'Podemos actualizar nuestra Política de Privacidad periódicamente. Se te recomienda revisar esta página de forma periódica para comprobar si hay cambios.\n\n'
          'Contáctanos\n'
          'Si tienes alguna pregunta o sugerencia sobre esta Política de Privacidad, contáctanos en: christianpeixotobrasil@gmail.com.\n\n'
          '---\n\n'
          'Anexo: Estándares de Seguridad Infantil y Política CSAE\n\n'
          'Fecha de entrada en vigor: 15 de noviembre de 2026\n\n'
          'Date Reminder: Fixed Events y Christian Peixoto mantienen una estricta política de tolerancia cero hacia el Abuso y la Explotación Sexual Infantil (CSAE). Nuestra aplicación no permite, facilita ni distribuye ningún contenido relacionado con material de abuso sexual infantil (CSAM) ni la puesta en peligro de menores.\n\n'
          'Si encuentras algún contenido inapropiado o ilegal relacionado con la seguridad infantil dentro de nuestro ecosistema, puedes denunciarlo de inmediato poniéndote en contacto con nosotros en christianpeixotobrasil@gmail.com, y se tomarán las medidas oportunas.',
    },
  };

  String get(String key) {
    final lang = locale.languageCode;
    final country = locale.countryCode;
    final fullKey = country != null ? '${lang}_$country' : lang;

    return _localizedValues[fullKey]?[key] ??
        _localizedValues[lang]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String weekdayName(int weekday) {
    return get('weekday$weekday');
  }

  String recurrenceLabel(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.yearly:
        return get('recYearly');
      case RecurrenceType.monthly:
        return get('recMonthly');
      case RecurrenceType.biweekly:
        return get('recBiweekly');
      case RecurrenceType.weekly:
        return get('recWeekly');
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'pt', 'es'].contains(locale.languageCode);

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
    final String? countryCode = prefs.getString('saved_country_code');
    final String? themeStr = prefs.getString('saved_theme_mode');

    ThemeMode loadedTheme = ThemeMode.system;
    if (themeStr == 'light') loadedTheme = ThemeMode.light;
    if (themeStr == 'dark') loadedTheme = ThemeMode.dark;

    setState(() {
      if (langCode != null) {
        _locale = Locale(langCode, countryCode);
      }
      _themeMode = loadedTheme;
    });
  }

  void setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('saved_language_code');
      await prefs.remove('saved_country_code');
    } else {
      await prefs.setString('saved_language_code', locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString('saved_country_code', locale.countryCode!);
      } else {
        await prefs.remove('saved_country_code');
      }
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
        Locale('pt', 'BR'),
        Locale('es', ''),
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
  RecurrenceType recurrence;
  int weekday; // 1 (Mon) .. 7 (Sun)
  int dayOfMonth; // 1 .. 31
  int iconCodePoint;
  int colorValue;
  EventCategory category;
  int remindDaysBefore;

  EventItem({
    required this.id,
    required this.description,
    required this.date,
    RecurrenceType? recurrence,
    int? weekday,
    int? dayOfMonth,
    int? iconCodePoint,
    int? colorValue,
    EventCategory? category,
    int? remindDaysBefore,
  })  : recurrence = recurrence ?? RecurrenceType.yearly,
        weekday = (weekday ?? date.weekday).clamp(1, 7),
        dayOfMonth = (dayOfMonth ?? date.day).clamp(1, 31),
        category = category ?? EventCategory.other,
        remindDaysBefore = remindDaysBefore ?? 0,
        iconCodePoint =
            iconCodePoint ?? (category?.defaultIcon.codePoint ?? 0xe123),
        colorValue =
            colorValue ?? (category?.defaultColor.toARGB32() ?? 0xFF2196F3);

  bool get isMilestone => recurrence == RecurrenceType.yearly;

  IconData get icon {
    for (final ic in kAppIcons) {
      if (ic.codePoint == iconCodePoint) {
        return ic;
      }
    }
    return Icons.event_note;
  }

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'date': date.toIso8601String(),
        'recurrence': recurrence.name,
        'weekday': weekday,
        'dayOfMonth': dayOfMonth,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'category': category.name,
        'remindDaysBefore': remindDaysBefore,
      };

  factory EventItem.fromJson(Map<String, dynamic> json) {
    final parsedDate = DateTime.parse(json['date']);
    return EventItem(
      id: json['id'],
      description: json['description'],
      date: parsedDate,
      recurrence: RecurrenceType.values.firstWhere(
        (r) => r.name == json['recurrence'],
        orElse: () => RecurrenceType.yearly,
      ),
      weekday: json['weekday'] ?? parsedDate.weekday,
      dayOfMonth: json['dayOfMonth'] ?? parsedDate.day,
      iconCodePoint: json['iconCodePoint'],
      colorValue: json['colorValue'],
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.other,
      ),
      remindDaysBefore: json['remindDaysBefore'] ?? 0,
    );
  }

  static DateTime _safeMonthDate(int year, int month, int day) {
    final normalizedYear = year + ((month - 1) ~/ 12);
    final normalizedMonth = ((month - 1) % 12) + 1;
    final lastDay = DateTime(normalizedYear, normalizedMonth + 1, 0).day;
    return DateTime(normalizedYear, normalizedMonth, min(day, lastDay));
  }

  DateTime nextOccurrenceOnDate([DateTime? fromDate]) {
    final now = fromDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (recurrence) {
      case RecurrenceType.yearly:
        var next = _safeMonthDate(today.year, date.month, date.day);
        if (next.isBefore(today)) {
          next = _safeMonthDate(today.year + 1, date.month, date.day);
        }
        return next;

      case RecurrenceType.monthly:
        var next = _safeMonthDate(today.year, today.month, dayOfMonth);
        if (next.isBefore(today)) {
          next = _safeMonthDate(today.year, today.month + 1, dayOfMonth);
        }
        return next;

      case RecurrenceType.weekly:
        final diff = (weekday - today.weekday + 7) % 7;
        return today.add(Duration(days: diff));

      case RecurrenceType.biweekly:
        final start = DateTime(date.year, date.month, date.day);
        if (!start.isBefore(today)) return start;
        final daysSinceStart = today.difference(start).inDays;
        final remainder = daysSinceStart % 14;
        final daysToAdd = remainder == 0 ? 0 : 14 - remainder;
        return today.add(Duration(days: daysToAdd));
    }
  }

  int get yearsDifference {
    final now = DateTime.now();
    int years = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextOccurrenceOnDate(today).difference(today).inDays;
  }

  DateTime? nextReminderTriggerTime([DateTime? referenceNow]) {
    final now = referenceNow ?? DateTime.now();
    DateTime searchFrom = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 400; i++) {
      final occurrence = nextOccurrenceOnDate(searchFrom);
      final trigger = DateTime(
        occurrence.year,
        occurrence.month,
        occurrence.day,
        9,
        0,
      ).subtract(Duration(days: remindDaysBefore));

      if (trigger.isAfter(now)) {
        return trigger;
      }

      searchFrom = occurrence.add(const Duration(days: 1));
    }
    return null;
  }

  String scheduleBadgeLabel(AppLocalizations l10n) {
    switch (recurrence) {
      case RecurrenceType.yearly:
        return '$yearsDifference yrs';
      case RecurrenceType.weekly:
        return l10n.weekdayName(weekday);
      case RecurrenceType.biweekly:
        return '${l10n.get('everyBiweekly')} (${l10n.weekdayName(date.weekday)})';
      case RecurrenceType.monthly:
        return '${l10n.get('everyDayOfMonth')} $dayOfMonth';
    }
  }
}

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<EventItem> _events = [];
  late TabController _tabController;
  bool _isFabMenuOpen = false;
  bool _privacyDialogShown = false;

  final List<IconData> availableIcons = kAppIcons;

  final List<Color> availableColors = [
    Colors.pinkAccent,
    Colors.amber.shade700,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.redAccent,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPrivacyConsent();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _rescheduleAllNotifications(context);
    }
  }

  Future<void> _requestPermissions() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _checkPrivacyConsent() async {
    if (_privacyDialogShown) return;

    final prefs = await SharedPreferences.getInstance();
    final bool accepted = prefs.getBool('privacy_policy_accepted') ?? false;

    if (accepted) {
      await _requestPermissions();
      return;
    }

    if (!mounted) return;
    _privacyDialogShown = true;
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(l10n.get('privacyDialogTitle')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.get('privacyDialogBody')),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showFullPrivacyDialog(dialogContext),
                    icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                    label: Text(l10n.get('viewPrivacyPolicy')),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(l10n.get('declineAndExit')),
              ),
              ElevatedButton(
                onPressed: () async {
                  await prefs.setBool('privacy_policy_accepted', true);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  await _requestPermissions();
                },
                child: Text(l10n.get('agreeAndContinue')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullPrivacyDialog(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx);
    showDialog<void>(
      context: ctx,
      builder: (innerContext) => AlertDialog(
        title: Text(l10n.get('privacyPolicy')),
        content: SingleChildScrollView(
          child: Text(l10n.get('privacyFullText')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(innerContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
    if (mounted) {
      await _rescheduleAllNotifications(context);
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

  Future<void> _scheduleNotification(
      EventItem event, BuildContext context) async {
    final int notificationId = event.id.hashCode.abs();
    final l10n = AppLocalizations.of(context);
    final DateTime? triggerTime = event.nextReminderTriggerTime();

    await flutterLocalNotificationsPlugin.cancel(notificationId);

    if (triggerTime == null) return;

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
        tz.TZDateTime.from(triggerTime, tz.local);

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
      );
    }
  }

  Future<void> _rescheduleAllNotifications(BuildContext context) async {
    for (final event in _events) {
      await _scheduleNotification(event, context);
    }
  }

  Future<void> _cancelNotification(String id) async {
    final int notificationId = id.hashCode.abs();
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  void _selectRecurrenceFromFab(RecurrenceType type) {
    setState(() => _isFabMenuOpen = false);
    _showEventDialog(initialRecurrence: type);
  }

  Widget _buildSpeedDialOption({
    required String label,
    required IconData icon,
    required Color color,
    required RecurrenceType recurrence,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(8),
            color: isDark ? Colors.grey.shade800 : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _selectRecurrenceFromFab(recurrence),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: 'fab_${recurrence.name}',
            backgroundColor: color,
            foregroundColor: Colors.white,
            onPressed: () => _selectRecurrenceFromFab(recurrence),
            child: Icon(icon),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFab() {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabMenuOpen) ...[
          _buildSpeedDialOption(
            label: l10n.get('recYearly'),
            icon: Icons.cake_outlined,
            color: Colors.blue,
            recurrence: RecurrenceType.yearly,
          ),
          _buildSpeedDialOption(
            label: l10n.get('recMonthly'),
            icon: Icons.calendar_month,
            color: Colors.green,
            recurrence: RecurrenceType.monthly,
          ),
          _buildSpeedDialOption(
            label: l10n.get('recBiweekly'),
            icon: Icons.date_range,
            color: Colors.orange,
            recurrence: RecurrenceType.biweekly,
          ),
          _buildSpeedDialOption(
            label: l10n.get('recWeekly'),
            icon: Icons.view_week,
            color: Colors.purple,
            recurrence: RecurrenceType.weekly,
          ),
        ],
        FloatingActionButton(
          heroTag: 'fab_main',
          onPressed: () {
            setState(() => _isFabMenuOpen = !_isFabMenuOpen);
          },
          child: AnimatedRotation(
            turns: _isFabMenuOpen ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showEventDialog({
    EventItem? event,
    RecurrenceType? initialRecurrence,
  }) {
    final isEditing = event != null;
    final descController = TextEditingController(text: event?.description ?? '');
    DateTime selectedDate = event?.date ?? DateTime.now();

    RecurrenceType selectedRecurrence =
        event?.recurrence ?? initialRecurrence ?? RecurrenceType.yearly;
    int selectedWeekday = event?.weekday ?? DateTime.friday;
    int selectedDayOfMonth = event?.dayOfMonth ?? 26;

    final List<EventCategory> allowedCategories =
        EventCategoryExtension.categoriesFor(selectedRecurrence);
    EventCategory selectedCategory =
        event?.category != null && allowedCategories.contains(event!.category)
            ? event.category
            : allowedCategories.first;

    int selectedIconCode =
        event?.iconCodePoint ?? selectedCategory.defaultIcon.codePoint;
    int selectedColorValue =
        event?.colorValue ?? selectedCategory.defaultColor.toARGB32();
    int selectedRemindDays = event?.remindDaysBefore ?? 0;

    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentCategories =
                EventCategoryExtension.categoriesFor(selectedRecurrence);

            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isEditing ? l10n.get('editEvent') : l10n.get('addEvent')),
                  if (!isEditing) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.recurrenceLabel(selectedRecurrence),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEditing) ...[
                      DropdownButtonFormField<RecurrenceType>(
                        initialValue: selectedRecurrence,
                        isExpanded: true,
                        decoration:
                            InputDecoration(labelText: l10n.get('repeat')),
                        items: [
                          DropdownMenuItem(
                            value: RecurrenceType.yearly,
                            child: Text(l10n.get('recYearly')),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceType.monthly,
                            child: Text(l10n.get('recMonthly')),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceType.biweekly,
                            child: Text(l10n.get('recBiweekly')),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceType.weekly,
                            child: Text(l10n.get('recWeekly')),
                          ),
                        ],
                        onChanged: (newRec) {
                          if (newRec != null) {
                            setDialogState(() {
                              selectedRecurrence = newRec;
                              final validCats =
                                  EventCategoryExtension.categoriesFor(newRec);
                              if (!validCats.contains(selectedCategory)) {
                                selectedCategory = validCats.first;
                                selectedIconCode =
                                    selectedCategory.defaultIcon.codePoint;
                                selectedColorValue =
                                    selectedCategory.defaultColor.toARGB32();
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    DropdownButtonFormField<EventCategory>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration:
                          InputDecoration(labelText: l10n.get('category')),
                      items: currentCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.defaultIcon,
                                  color: cat.defaultColor, size: 20),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  l10n.get(cat.nameKey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
                      decoration:
                          InputDecoration(labelText: l10n.get('description')),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedRemindDays,
                      isExpanded: true,
                      decoration:
                          InputDecoration(labelText: l10n.get('remindBefore')),
                      items: [
                        DropdownMenuItem(
                            value: 0, child: Text(l10n.get('remind0'))),
                        DropdownMenuItem(
                            value: 1, child: Text(l10n.get('remind1'))),
                        DropdownMenuItem(
                            value: 3, child: Text(l10n.get('remind3'))),
                        DropdownMenuItem(
                            value: 7, child: Text(l10n.get('remind7'))),
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
                    if (selectedRecurrence == RecurrenceType.yearly ||
                        selectedRecurrence == RecurrenceType.biweekly)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${selectedRecurrence == RecurrenceType.biweekly ? l10n.get('startsOn') : 'Date'}: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                            ),
                          ),
                          const SizedBox(width: 8),
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
                    if (selectedRecurrence == RecurrenceType.weekly)
                      DropdownButtonFormField<int>(
                        initialValue: selectedWeekday,
                        isExpanded: true,
                        decoration:
                            InputDecoration(labelText: l10n.get('dayOfWeek')),
                        items: List.generate(7, (index) {
                          final dayNum = index + 1;
                          return DropdownMenuItem(
                            value: dayNum,
                            child: Text(l10n.weekdayName(dayNum)),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedWeekday = val;
                            });
                          }
                        },
                      ),
                    if (selectedRecurrence == RecurrenceType.monthly)
                      DropdownButtonFormField<int>(
                        initialValue: selectedDayOfMonth,
                        isExpanded: true,
                        decoration:
                            InputDecoration(labelText: l10n.get('dayOfMonth')),
                        items: List.generate(31, (index) {
                          final dayNum = index + 1;
                          return DropdownMenuItem(
                            value: dayNum,
                            child: Text('${l10n.get('everyDayOfMonth')} $dayNum'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDayOfMonth = val;
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 20),
                    const Text('Choose Icon:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableIcons.map((icon) {
                        final isSelected = selectedIconCode == icon.codePoint;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIconCode = icon.codePoint;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                            ),
                            child: Icon(icon,
                                size: 24,
                                color: isSelected
                                    ? Colors.blue.shade800
                                    : Colors.grey.shade700),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Choose Color:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableColors.map((color) {
                        final isSelected =
                            selectedColorValue == color.toARGB32();
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColorValue = color.toARGB32();
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2.5)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
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
                    late final EventItem targetEvent;
                    setState(() {
                      if (isEditing) {
                        event.description = descController.text.trim();
                        event.date = selectedDate;
                        event.recurrence = selectedRecurrence;
                        event.weekday = selectedWeekday;
                        event.dayOfMonth = selectedDayOfMonth;
                        event.iconCodePoint = selectedIconCode;
                        event.colorValue = selectedColorValue;
                        event.category = selectedCategory;
                        event.remindDaysBefore = selectedRemindDays;
                        targetEvent = event;
                      } else {
                        targetEvent = EventItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          description: descController.text.trim(),
                          date: selectedDate,
                          recurrence: selectedRecurrence,
                          weekday: selectedWeekday,
                          dayOfMonth: selectedDayOfMonth,
                          iconCodePoint: selectedIconCode,
                          colorValue: selectedColorValue,
                          category: selectedCategory,
                          remindDaysBefore: selectedRemindDays,
                        );
                        _events.add(targetEvent);
                      }
                      _sortEvents();
                      _saveEvents();
                    });

                    final targetTabIndex = targetEvent.isMilestone ? 0 : 1;
                    if (_tabController.index != targetTabIndex) {
                      _tabController.animateTo(targetTabIndex);
                    }

                    if (mounted) {
                      await _scheduleNotification(targetEvent, context);
                    }
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
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

  Future<void> _confirmDelete(EventItem event) async {
    final l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.get('deleteTitle')),
          content: Text(
              'Are you sure you want to remove "${event.description}"?'),
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
      await _cancelNotification(event.id);
      setState(() {
        _events.removeWhere((e) => e.id == event.id);
        _saveEvents();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${event.description} deleted')),
        );
      }
    }
  }

  Widget _buildEventList(List<EventItem> items, String emptyText) {
    if (items.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 90),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final event = items[index];
        final nextDate = event.nextOccurrenceOnDate();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  color: event.color,
                ),
                Expanded(
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
                                  icon: Icon(Icons.edit_outlined,
                                      size: 18, color: Colors.grey.shade400),
                                  tooltip: l10n.get('editEvent'),
                                  onPressed: () =>
                                      _showEventDialog(event: event),
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.more_vert,
                                      size: 18, color: Colors.grey.shade400),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _confirmDelete(event);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete_outline,
                                              size: 18, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.get('deleteAction'),
                                            style: const TextStyle(
                                                color: Colors.red, fontSize: 14),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd-MM-yyyy').format(
                                          event.isMilestone
                                              ? event.date
                                              : nextDate,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: event.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    event.scheduleBadgeLabel(l10n),
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
                                  color: isDark ? Colors.white60 : Colors.grey,
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final milestones = _events.where((e) => e.isMilestone).toList();
    final recurring = _events.where((e) => !e.isMilestone).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('appTitle')),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.get('settings'),
            onPressed: () async {
              if (_isFabMenuOpen) {
                setState(() => _isFabMenuOpen = false);
              }
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.cake_outlined),
              text: l10n.get('tabMilestones'),
            ),
            Tab(
              icon: const Icon(Icons.repeat),
              text: l10n.get('tabRecurring'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(milestones, l10n.get('noEvents')),
              _buildEventList(recurring, l10n.get('noRecurring')),
            ],
          ),
          if (_isFabMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isFabMenuOpen = false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildExpandableFab(),
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
    rows.add([
      'ID',
      'Description',
      'Date',
      'IconCodePoint',
      'ColorValue',
      'Category',
      'RemindDaysBefore',
      'Recurrence',
      'Weekday',
      'DayOfMonth',
    ]);
    for (var event in events) {
      rows.add([
        event.id,
        event.description,
        event.date.toIso8601String(),
        event.iconCodePoint,
        event.colorValue,
        event.category.name,
        event.remindDaysBefore,
        event.recurrence.name,
        event.weekday,
        event.dayOfMonth,
      ]);
    }
    String csvData = const ListToCsvConverter().convert(rows);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/events_export.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)],
        text: l10n.get('csvShareText'));
  }

  Future<void> _importCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.get('importFailed')} ($e)')),
        );
      }
      return;
    }

    if (result == null || result.files.single.name.isEmpty) return;
    if (!context.mounted) return;

    bool overwrite = false;

    final bool? shouldImport = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        bool localOverwrite = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.get('importCsv')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose how you want to import your events:'),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Overwrite existing events'),
                    value: localOverwrite,
                    onChanged: (val) {
                      setDialogState(() {
                        localOverwrite = val ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    overwrite = localOverwrite;
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(l10n.get('save')),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldImport != true) return;
    if (!context.mounted) return;

    try {
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
          final parsedDate = DateTime.parse(row[2].toString());

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

          RecurrenceType parsedRecurrence = RecurrenceType.yearly;
          if (row.length >= 8) {
            parsedRecurrence = RecurrenceType.values.firstWhere(
              (r) => r.name == row[7].toString(),
              orElse: () => RecurrenceType.yearly,
            );
          }

          final int parsedWeekday = row.length >= 9
              ? (int.tryParse(row[8].toString()) ?? parsedDate.weekday)
              : parsedDate.weekday;

          final int parsedDayOfMonth = row.length >= 10
              ? (int.tryParse(row[9].toString()) ?? parsedDate.day)
              : parsedDate.day;

          importedEvents.add(
            EventItem(
              id: row[0].toString(),
              description: row[1].toString(),
              date: parsedDate,
              recurrence: parsedRecurrence,
              weekday: parsedWeekday,
              dayOfMonth: parsedDayOfMonth,
              iconCodePoint: row.length >= 4
                  ? int.tryParse(row[3].toString()) ??
                      parsedCategory.defaultIcon.codePoint
                  : parsedCategory.defaultIcon.codePoint,
              colorValue: row.length >= 5
                  ? int.tryParse(row[4].toString()) ??
                      parsedCategory.defaultColor.toARGB32()
                  : parsedCategory.defaultColor.toARGB32(),
              category: parsedCategory,
              remindDaysBefore: parsedRemindDays,
            ),
          );
        }
      }

      List<EventItem> finalEvents = [];

      if (overwrite) {
        finalEvents = importedEvents;
      } else {
        finalEvents = List.from(events);
        for (var imported in importedEvents) {
          int existingIndex = finalEvents.indexWhere(
            (e) =>
                e.description.trim().toLowerCase() ==
                imported.description.trim().toLowerCase(),
          );

          if (existingIndex != -1) {
            finalEvents[existingIndex].date = imported.date;
            finalEvents[existingIndex].recurrence = imported.recurrence;
            finalEvents[existingIndex].weekday = imported.weekday;
            finalEvents[existingIndex].dayOfMonth = imported.dayOfMonth;
            finalEvents[existingIndex].iconCodePoint = imported.iconCodePoint;
            finalEvents[existingIndex].colorValue = imported.colorValue;
            finalEvents[existingIndex].category = imported.category;
            finalEvents[existingIndex].remindDaysBefore =
                imported.remindDaysBefore;
          } else {
            finalEvents.add(imported);
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(finalEvents.map((e) => e.toJson()).toList());
      await prefs.setString('saved_events', encoded);

      onEventsUpdated();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.get('importSuccess'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.get('importFailed')} ($e)')),
        );
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.get('privacyPolicy')),
        content: SingleChildScrollView(
          child: Text(l10n.get('privacyFullText')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);
    final currentThemeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    String selectedLangValue = 'en';
    if (currentLocale.languageCode == 'pt') {
      selectedLangValue = currentLocale.countryCode == 'BR' ? 'pt_BR' : 'pt';
    } else if (currentLocale.languageCode == 'es') {
      selectedLangValue = 'es';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('settings')),
      ),
      body: ListView(
        children: [
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
              value: selectedLangValue,
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English 🇺🇸'),
                ),
                DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português 🇵🇹'),
                ),
                DropdownMenuItem(
                  value: 'pt_BR',
                  child: Text('Português (BR) 🇧🇷'),
                ),
                DropdownMenuItem(
                  value: 'es',
                  child: Text('Español 🇪🇸'),
                ),
              ],
              onChanged: (String? val) {
                if (val != null) {
                  if (val == 'pt_BR') {
                    EventTrackerApp.of(context)
                        .setLocale(const Locale('pt', 'BR'));
                  } else {
                    EventTrackerApp.of(context).setLocale(Locale(val));
                  }
                }
              },
            ),
          ),
          const Divider(),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.get('privacyPolicy')),
            onTap: () => _showPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }
}
