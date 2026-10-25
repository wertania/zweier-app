import 'package:flutter/widgets.dart';

import '../models/models.dart';
import 'app_localizations.dart';

/// Shortcut: `context.l10n.someKey`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeTag => Localizations.localeOf(this).toLanguageTag();
}

extension WeatherLabel on Weather {
  String label(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      Weather.sunny => l.weatherSunny,
      Weather.cloudy => l.weatherCloudy,
      Weather.rainy => l.weatherRainy,
      Weather.snowy => l.weatherSnowy,
      Weather.any => l.weatherAny,
    };
  }
}

extension DurationLabel on IdeaDuration {
  String label(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      IdeaDuration.short => l.durationShort,
      IdeaDuration.halfDay => l.durationHalfDay,
      IdeaDuration.fullDay => l.durationFullDay,
      IdeaDuration.multiDay => l.durationMultiDay,
    };
  }
}
