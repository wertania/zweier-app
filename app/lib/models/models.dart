/// Weather categories an idea fits. Mirrors the backend enum.
enum Weather {
  sunny('☀️'),
  cloudy('⛅'),
  rainy('🌧️'),
  snowy('❄️'),
  any('🌈');

  const Weather(this.emoji);
  final String emoji;

  static Weather fromName(String? name) =>
      Weather.values.firstWhere((w) => w.name == name, orElse: () => Weather.any);
}

/// Rough duration of an idea, from short to long. Mirrors the backend enum.
enum IdeaDuration {
  short('short', '⏱️'),
  halfDay('half_day', '🕐'),
  fullDay('full_day', '🌞'),
  multiDay('multi_day', '🧳');

  const IdeaDuration(this.apiName, this.emoji);
  final String apiName;
  final String emoji;

  static IdeaDuration fromName(String? name) => IdeaDuration.values
      .firstWhere((d) => d.apiName == name, orElse: () => IdeaDuration.halfDay);
}

class Idea {
  Idea({
    this.id,
    required this.title,
    this.description,
    this.emoji = '💡',
    this.weather = Weather.any,
    this.duration = IdeaDuration.halfDay,
    this.favorite = false,
    this.done = false,
    this.destinationId,
  });

  final String? id;
  String title;
  String? description;
  String emoji;
  Weather weather;
  IdeaDuration duration;
  bool favorite;
  bool done;
  String? destinationId;

  factory Idea.fromJson(Map<String, dynamic> j) => Idea(
        id: j['id'] as String?,
        title: j['title'] as String? ?? '',
        description: j['description'] as String?,
        emoji: j['emoji'] as String? ?? '💡',
        weather: Weather.fromName(j['weather'] as String?),
        duration: IdeaDuration.fromName(j['duration'] as String?),
        favorite: j['favorite'] as bool? ?? false,
        done: j['done'] as bool? ?? false,
        destinationId: j['destinationId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'emoji': emoji,
        'weather': weather.name,
        'duration': duration.apiName,
        'favorite': favorite,
        'done': done,
        'destinationId': destinationId,
      };
}

class Destination {
  Destination({
    this.id,
    required this.name,
    this.country,
    this.description,
    this.emoji = '🗺️',
    this.plannedFor,
    this.visited = false,
    this.todoCount = 0,
    this.doneCount = 0,
  });

  final String? id;
  String name;
  String? country;
  String? description;
  String emoji;
  DateTime? plannedFor;
  bool visited;
  int todoCount;
  int doneCount;

  factory Destination.fromJson(Map<String, dynamic> j) => Destination(
        id: j['id'] as String?,
        name: j['name'] as String? ?? '',
        country: j['country'] as String?,
        description: j['description'] as String?,
        emoji: j['emoji'] as String? ?? '🗺️',
        plannedFor: j['plannedFor'] == null
            ? null
            : DateTime.tryParse(j['plannedFor'] as String),
        visited: j['visited'] as bool? ?? false,
        todoCount: (j['todoCount'] as num?)?.toInt() ?? 0,
        doneCount: (j['doneCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'description': description,
        'emoji': emoji,
        'plannedFor': plannedFor?.toIso8601String().substring(0, 10),
        'visited': visited,
      };
}

class Forecast {
  Forecast({required this.weather, this.temperatureMax, this.temperatureMin, this.precipitationProbability});
  final Weather weather;
  final double? temperatureMax;
  final double? temperatureMin;
  final num? precipitationProbability;

  factory Forecast.fromJson(Map<String, dynamic> j) => Forecast(
        weather: Weather.fromName(j['weather'] as String?),
        temperatureMax: (j['temperatureMax'] as num?)?.toDouble(),
        temperatureMin: (j['temperatureMin'] as num?)?.toDouble(),
        precipitationProbability: j['precipitationProbability'] as num?,
      );
}

class SuggestionResult {
  SuggestionResult({required this.weather, this.forecast, required this.suggestions});
  final Weather weather;
  final Forecast? forecast;
  final List<Idea> suggestions;

  factory SuggestionResult.fromJson(Map<String, dynamic> j) => SuggestionResult(
        weather: Weather.fromName(j['weather'] as String?),
        forecast: j['forecast'] == null
            ? null
            : Forecast.fromJson(j['forecast'] as Map<String, dynamic>),
        suggestions: (j['suggestions'] as List)
            .map((e) => Idea.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Invitation {
  Invitation({required this.id, required this.tenantId, this.tenantName});
  final String id;
  final String tenantId;
  final String? tenantName;
}
