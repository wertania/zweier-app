import 'package:flutter_test/flutter_test.dart';
import 'package:zweier/api/api_client.dart';
import 'package:zweier/models/models.dart';
import 'package:zweier/update_check.dart';

void main() {
  test('idea json round trip keeps api enum names', () {
    final idea = Idea.fromJson({
      'id': '1',
      'title': 'Picknick',
      'weather': 'sunny',
      'duration': 'full_day',
      'done': false,
    });
    expect(idea.weathers, {Weather.sunny}); // legacy single weather
    expect(idea.duration, IdeaDuration.fullDay);
    expect(idea.toJson()['duration'], 'full_day');
    expect(idea.toJson()['weathers'], ['sunny']);
  });

  test('unknown values fall back to defaults', () {
    final idea = Idea.fromJson({'title': 'x', 'weather': 'tornado'});
    expect(idea.weathers, {Weather.any});
    expect(idea.timeOfDay, DayTime.any);
    expect(idea.duration, IdeaDuration.halfDay);
  });

  test('destination parses counts and date', () {
    final d = Destination.fromJson(
        {'id': 'd', 'name': 'Lissabon', 'plannedFor': '2027-05-01', 'todoCount': 3, 'doneCount': 1});
    expect(d.plannedFor, DateTime(2027, 5, 1));
    expect(d.todoCount, 3);
    expect(d.toJson()['plannedFor'], '2027-05-01');
  });

  test('server url gets scheme and loses the api path', () {
    expect(ApiClient.normalizeServerUrl('zweier-app.resomo.de'), 'https://zweier-app.resomo.de');
    expect(ApiClient.normalizeServerUrl(' https://zweier-app.resomo.de/ '), 'https://zweier-app.resomo.de');
    expect(ApiClient.normalizeServerUrl('https://x.de/api/v1/'), 'https://x.de');
    expect(ApiClient.normalizeServerUrl('http://10.0.2.2:3000/api/v1'), 'http://10.0.2.2:3000');
    expect(ApiClient.normalizeServerUrl('https://x.de/zweier'), 'https://x.de/zweier');
  });

  test('several weathers, evening and a place', () {
    final idea = Idea.fromJson({
      'title': 'Rooftop bar',
      'weathers': ['cloudy', 'sunny'],
      'timeOfDay': 'evening',
      'location': 'Skyline Bar',
    });
    expect(idea.sortedWeathers, [Weather.sunny, Weather.cloudy]);
    expect(idea.timeOfDay, DayTime.evening);
    expect(idea.location, 'Skyline Bar');
    expect(idea.fitsWeather(Weather.cloudy), isTrue);
    expect(idea.fitsWeather(Weather.rainy), isFalse);
    expect(idea.toJson()['timeOfDay'], 'evening');
  });

  test('toggling weathers: "any" and specific weathers exclude each other', () {
    final idea = Idea(title: 'x');
    expect(idea.weathers, {Weather.any});
    idea.toggleWeather(Weather.rainy);
    expect(idea.weathers, {Weather.rainy});
    idea.toggleWeather(Weather.snowy);
    expect(idea.weathers, {Weather.rainy, Weather.snowy});
    idea.toggleWeather(Weather.any);
    expect(idea.weathers, {Weather.any});
    idea.toggleWeather(Weather.sunny);
    idea.toggleWeather(Weather.sunny);
    expect(idea.weathers, {Weather.any}); // nothing selected = any
  });

  test('categories round trip, unknown ones are ignored', () {
    final idea = Idea.fromJson({
      'title': 'Street food',
      'categories': ['friends', 'city', 'sports'],
    });
    expect(idea.sortedCategories, [Category.city, Category.friends]);
    expect(idea.toJson()['categories'], ['city', 'friends']);
    expect(Idea(title: 'x').categories, isEmpty);
  });

  test('version comparison', () {
    expect(compareVersions('1.2.0', '1.10.0'), lessThan(0));
    expect(compareVersions('1.3.0', '1.3.0+7'), 0);
    expect(compareVersions('2.0.0', '1.9.9'), greaterThan(0));
  });

  test('update decision', () {
    const url = 'https://example.com/latest';
    expect(UpdateInfo.fromServer('1.3.0', {'latestVersion': '1.3.0', 'downloadUrl': url}), isNull);
    expect(UpdateInfo.fromServer('1.3.0', {'latestVersion': null}), isNull);
    final optional = UpdateInfo.fromServer('1.3.0', {'latestVersion': '1.4.0', 'downloadUrl': url})!;
    expect(optional.required, isFalse);
    expect(optional.latest, '1.4.0');
    final required = UpdateInfo.fromServer('1.1.0', {'latestVersion': '1.4.0', 'minVersion': '1.2.0'})!;
    expect(required.required, isTrue);
  });
}
