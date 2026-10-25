import 'package:flutter_test/flutter_test.dart';
import 'package:zweier/models/models.dart';

void main() {
  test('idea json round trip keeps api enum names', () {
    final idea = Idea.fromJson({
      'id': '1',
      'title': 'Picknick',
      'weather': 'sunny',
      'duration': 'full_day',
      'done': false,
    });
    expect(idea.weather, Weather.sunny);
    expect(idea.duration, IdeaDuration.fullDay);
    expect(idea.toJson()['duration'], 'full_day');
  });

  test('unknown values fall back to defaults', () {
    final idea = Idea.fromJson({'title': 'x', 'weather': 'tornado'});
    expect(idea.weather, Weather.any);
    expect(idea.duration, IdeaDuration.halfDay);
  });

  test('destination parses counts and date', () {
    final d = Destination.fromJson(
        {'id': 'd', 'name': 'Lissabon', 'plannedFor': '2027-05-01', 'todoCount': 3, 'doneCount': 1});
    expect(d.plannedFor, DateTime(2027, 5, 1));
    expect(d.todoCount, 3);
    expect(d.toJson()['plannedFor'], '2027-05-01');
  });
}
