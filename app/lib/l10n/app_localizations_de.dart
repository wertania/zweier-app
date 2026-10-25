// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Zweier';

  @override
  String get weatherSunny => 'Sonne';

  @override
  String get weatherCloudy => 'Wolken';

  @override
  String get weatherRainy => 'Regen';

  @override
  String get weatherSnowy => 'Schnee';

  @override
  String get weatherAny => 'Egal';

  @override
  String get durationShort => 'Kurz';

  @override
  String get durationHalfDay => 'Halber Tag';

  @override
  String get durationFullDay => 'Ganzer Tag';

  @override
  String get durationMultiDay => 'Mehrere Tage';

  @override
  String errorPrefix(String error) {
    return 'Hoppla: $error';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get keep => 'Behalten';

  @override
  String get delete => 'Löschen';

  @override
  String get appTagline =>
      'Eure gemeinsamen Ideen, Ausflüge\nund Reiseträume – an einem Ort.';

  @override
  String get emailHint => 'Deine E-Mail';

  @override
  String get sendCode => 'Anmelde-Code schicken';

  @override
  String codeSentTo(String email) {
    return 'Wir haben dir einen Code an\n$email geschickt 💌';
  }

  @override
  String get letsGo => 'Los geht’s';

  @override
  String get useOtherEmail => 'Andere E-Mail verwenden';

  @override
  String get setServer => 'Server einstellen';

  @override
  String get server => 'Server';

  @override
  String get coupleSetupTitle => 'Euer gemeinsamer Ort';

  @override
  String get coupleSetupText =>
      'Leg euren Bereich an und lade danach deinen Schatz ein – oder nimm eine Einladung an.';

  @override
  String get invitationsForYou => 'EINLADUNGEN FÜR DICH';

  @override
  String get sharedSpace => 'Gemeinsamer Bereich';

  @override
  String get youWereInvited => 'Du wurdest eingeladen';

  @override
  String get accept => 'Annehmen';

  @override
  String get createNew => 'NEU ANLEGEN';

  @override
  String get coupleNameHint => 'z. B. Anna & Ben';

  @override
  String get coupleNameDefault => 'Wir zwei';

  @override
  String get createCouple => 'Unseren Bereich anlegen';

  @override
  String get navToday => 'Heute';

  @override
  String get navIdeas => 'Ideen';

  @override
  String get navTrips => 'Reisen';

  @override
  String get navUs => 'Wir';

  @override
  String get greetingMorning => 'Guten Morgen, ihr zwei ☕';

  @override
  String greetingDay(String weekday) {
    return 'Schöner $weekday, ihr zwei 🌼';
  }

  @override
  String get greetingEvening => 'Guten Abend, ihr zwei 🌙';

  @override
  String get whatShallWeDo => 'Was machen wir?';

  @override
  String get whenLabel => 'WANN?';

  @override
  String get timeLabel => 'WIE VIEL ZEIT HABT IHR?';

  @override
  String get weatherLabel => 'WETTER';

  @override
  String get forecast => '📍 Vorhersage';

  @override
  String get today => 'Heute';

  @override
  String tomorrowWeekday(String weekday) {
    return 'Morgen ($weekday)';
  }

  @override
  String get heroTitle => 'Überrascht euch!';

  @override
  String heroText(int count) {
    return 'Wir suchen aus euren $count Ideen das Passende fürs Wetter und eure Zeit.';
  }

  @override
  String get ourTips => 'Unsere Tipps';

  @override
  String weatherExpected(String weather, String min, String max) {
    return '$weather erwartet · $min–$max °C';
  }

  @override
  String get anyWeather => 'Für jedes Wetter';

  @override
  String get nothingFittingTitle => 'Noch nichts Passendes';

  @override
  String get nothingFittingText =>
      'Legt unter „Ideen“ ein paar Lieblingsdinge an – dann haben wir mehr zur Auswahl.';

  @override
  String get rollAgain => 'Nochmal würfeln';

  @override
  String get newIdea => 'Neue Idee';

  @override
  String get todoQuestion => 'Was wollen wir dort machen?';

  @override
  String get editIdea => 'Idee bearbeiten';

  @override
  String get deleteConfirmTitle => 'Wirklich löschen?';

  @override
  String deleteConfirmText(String title) {
    return '„$title“ wird entfernt.';
  }

  @override
  String get ideaTitleHint => 'z. B. Picknick am See';

  @override
  String get ideaNotesHint => 'Notizen, Adresse, was mitnehmen …';

  @override
  String get goodFor => 'PASST BEI';

  @override
  String get durationLabel => 'DAUER';

  @override
  String get heartIdea => 'Herzensidee ❤️';

  @override
  String get heartIdeaHint => 'Wird bei Vorschlägen bevorzugt';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get ourIdeas => 'Unsere Ideen';

  @override
  String get showDone => 'Erledigte zeigen';

  @override
  String get ideaFab => 'Idee';

  @override
  String get emptyIdeasTitle => 'Euer Ideen-Garten ist noch leer';

  @override
  String get emptyIdeasText =>
      'Sammelt hier alles, was ihr gern zusammen machen wollt – vom Kinoabend bis zur Wanderung.';

  @override
  String get nothingFound => 'Nichts gefunden';

  @override
  String get tryOtherFilter => 'Probiert einen anderen Filter.';

  @override
  String get wasLovely => 'Schön war’s! 💕';

  @override
  String get tripDreams => 'Reiseträume';

  @override
  String get destinationFab => 'Ziel';

  @override
  String get emptyTripsTitle => 'Wohin soll’s gehen?';

  @override
  String get emptyTripsText =>
      'Sammelt eure Traumziele und hängt an jedes eine Liste mit Dingen, die ihr dort erleben wollt.';

  @override
  String get alreadyExperienced => 'SCHON ERLEBT 💛';

  @override
  String experiences(int done, int total) {
    return '$done/$total Erlebnisse';
  }

  @override
  String get newDestination => 'Neues Reiseziel';

  @override
  String get editDestination => 'Reiseziel bearbeiten';

  @override
  String get placeHint => 'Ort, z. B. Lissabon';

  @override
  String get countryHint => 'Land (optional)';

  @override
  String get whyHint => 'Warum wollen wir dahin?';

  @override
  String get noDateYet => 'Noch kein Termin';

  @override
  String get setDate => 'Festlegen';

  @override
  String get beenThere => 'Waren wir schon 💛';

  @override
  String deleteDestinationTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteDestinationText =>
      'Die Liste mit allen Erlebnissen wird ebenfalls gelöscht.';

  @override
  String get experienceFab => 'Erlebnis';

  @override
  String get emptyTodosTitle => 'Was wollen wir dort erleben?';

  @override
  String get emptyTodosText =>
      'Schreibt auf, was ihr dort Tolles machen könntet – genau wie eure Ideen für zu Hause.';

  @override
  String get stillAhead => 'NOCH VOR UNS';

  @override
  String get alreadyDone => 'SCHON GEMACHT 💕';

  @override
  String get inviteTitle => 'Schatz einladen 💌';

  @override
  String get partnerEmailHint => 'E-Mail deines Partners';

  @override
  String get invite => 'Einladen';

  @override
  String get invitationSent => 'Einladung ist unterwegs 💌';

  @override
  String get statIdeas => 'Ideen';

  @override
  String get statDone => 'Erlebt';

  @override
  String get statTraveled => 'Gereist';

  @override
  String get usTwo => 'WIR ZWEI';

  @override
  String get thatsYou => 'Das bist du';

  @override
  String get yourLove => 'Dein Schatz';

  @override
  String get invitePartner => 'Partner:in einladen';

  @override
  String get invitePartnerHint => 'Dann plant ihr gemeinsam';

  @override
  String get settings => 'EINSTELLUNGEN';

  @override
  String get logout => 'Abmelden';

  @override
  String get madeWithLove => 'Mit ❤️ für euch zwei gemacht';

  @override
  String get us => 'Wir';
}
