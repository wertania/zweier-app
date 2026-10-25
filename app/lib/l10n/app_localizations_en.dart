// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zweier';

  @override
  String get weatherSunny => 'Sunny';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherRainy => 'Rainy';

  @override
  String get weatherSnowy => 'Snow';

  @override
  String get weatherAny => 'Any';

  @override
  String get durationShort => 'Short';

  @override
  String get durationHalfDay => 'Half a day';

  @override
  String get durationFullDay => 'Full day';

  @override
  String get durationMultiDay => 'Several days';

  @override
  String errorPrefix(String error) {
    return 'Oops: $error';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get keep => 'Keep';

  @override
  String get delete => 'Delete';

  @override
  String get appTagline =>
      'Your shared ideas, outings\nand travel dreams – in one place.';

  @override
  String get emailHint => 'Your email';

  @override
  String get sendCode => 'Send login code';

  @override
  String codeSentTo(String email) {
    return 'We sent a code to\n$email 💌';
  }

  @override
  String get letsGo => 'Let\'s go';

  @override
  String get useOtherEmail => 'Use a different email';

  @override
  String get setServer => 'Set server';

  @override
  String get server => 'Server';

  @override
  String get coupleSetupTitle => 'Your shared place';

  @override
  String get coupleSetupText =>
      'Create your space and invite your sweetheart afterwards – or accept an invitation.';

  @override
  String get invitationsForYou => 'INVITATIONS FOR YOU';

  @override
  String get sharedSpace => 'Shared space';

  @override
  String get youWereInvited => 'You have been invited';

  @override
  String get accept => 'Accept';

  @override
  String get createNew => 'CREATE NEW';

  @override
  String get coupleNameHint => 'e.g. Anna & Ben';

  @override
  String get coupleNameDefault => 'The two of us';

  @override
  String get createCouple => 'Create our space';

  @override
  String get navToday => 'Today';

  @override
  String get navIdeas => 'Ideas';

  @override
  String get navTrips => 'Trips';

  @override
  String get navUs => 'Us';

  @override
  String get greetingMorning => 'Good morning, you two ☕';

  @override
  String greetingDay(String weekday) {
    return 'Happy $weekday, you two 🌼';
  }

  @override
  String get greetingEvening => 'Good evening, you two 🌙';

  @override
  String get whatShallWeDo => 'What shall we do?';

  @override
  String get whenLabel => 'WHEN?';

  @override
  String get timeLabel => 'HOW MUCH TIME DO YOU HAVE?';

  @override
  String get weatherLabel => 'WEATHER';

  @override
  String get forecast => '📍 Forecast';

  @override
  String get today => 'Today';

  @override
  String tomorrowWeekday(String weekday) {
    return 'Tomorrow ($weekday)';
  }

  @override
  String get heroTitle => 'Surprise yourselves!';

  @override
  String heroText(int count) {
    return 'We pick from your $count ideas what fits the weather and your time.';
  }

  @override
  String get ourTips => 'Our tips';

  @override
  String weatherExpected(String weather, String min, String max) {
    return '$weather expected · $min–$max °C';
  }

  @override
  String get anyWeather => 'For any weather';

  @override
  String get nothingFittingTitle => 'Nothing fitting yet';

  @override
  String get nothingFittingText =>
      'Add a few favourite things under “Ideas” – then there is more to choose from.';

  @override
  String get rollAgain => 'Roll again';

  @override
  String get newIdea => 'New idea';

  @override
  String get todoQuestion => 'What do we want to do there?';

  @override
  String get editIdea => 'Edit idea';

  @override
  String get deleteConfirmTitle => 'Really delete?';

  @override
  String deleteConfirmText(String title) {
    return '“$title” will be removed.';
  }

  @override
  String get ideaTitleHint => 'e.g. Picnic at the lake';

  @override
  String get ideaNotesHint => 'Notes, address, what to bring …';

  @override
  String get goodFor => 'GOOD FOR';

  @override
  String get durationLabel => 'DURATION';

  @override
  String get heartIdea => 'Heart idea ❤️';

  @override
  String get heartIdeaHint => 'Preferred in suggestions';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get ourIdeas => 'Our ideas';

  @override
  String get showDone => 'Show done';

  @override
  String get ideaFab => 'Idea';

  @override
  String get emptyIdeasTitle => 'Your idea garden is still empty';

  @override
  String get emptyIdeasText =>
      'Collect everything you love doing together – from movie night to a long hike.';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get tryOtherFilter => 'Try a different filter.';

  @override
  String get wasLovely => 'That was lovely! 💕';

  @override
  String get tripDreams => 'Travel dreams';

  @override
  String get destinationFab => 'Destination';

  @override
  String get emptyTripsTitle => 'Where to next?';

  @override
  String get emptyTripsText =>
      'Collect your dream destinations and attach a list of things you want to experience there.';

  @override
  String get alreadyExperienced => 'ALREADY BEEN 💛';

  @override
  String experiences(int done, int total) {
    return '$done/$total experiences';
  }

  @override
  String get newDestination => 'New destination';

  @override
  String get editDestination => 'Edit destination';

  @override
  String get placeHint => 'Place, e.g. Lisbon';

  @override
  String get countryHint => 'Country (optional)';

  @override
  String get whyHint => 'Why do we want to go there?';

  @override
  String get noDateYet => 'No date yet';

  @override
  String get setDate => 'Set';

  @override
  String get beenThere => 'We\'ve been there 💛';

  @override
  String deleteDestinationTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteDestinationText =>
      'The list with all experiences will be deleted as well.';

  @override
  String get experienceFab => 'Experience';

  @override
  String get emptyTodosTitle => 'What do we want to experience there?';

  @override
  String get emptyTodosText =>
      'Write down the great things you could do there – just like your ideas at home.';

  @override
  String get stillAhead => 'STILL AHEAD';

  @override
  String get alreadyDone => 'ALREADY DONE 💕';

  @override
  String get inviteTitle => 'Invite your sweetheart 💌';

  @override
  String get partnerEmailHint => 'Your partner\'s email';

  @override
  String get invite => 'Invite';

  @override
  String get invitationSent => 'Invitation is on its way 💌';

  @override
  String get statIdeas => 'Ideas';

  @override
  String get statDone => 'Done';

  @override
  String get statTraveled => 'Travelled';

  @override
  String get usTwo => 'THE TWO OF US';

  @override
  String get thatsYou => 'That\'s you';

  @override
  String get yourLove => 'Your sweetheart';

  @override
  String get invitePartner => 'Invite your partner';

  @override
  String get invitePartnerHint => 'Then you plan together';

  @override
  String get settings => 'SETTINGS';

  @override
  String get logout => 'Log out';

  @override
  String get madeWithLove => 'Made with ❤️ for the two of you';

  @override
  String get us => 'Us';

  @override
  String get timeAny => 'Anytime';

  @override
  String get timeDay => 'Daytime';

  @override
  String get timeEvening => 'Evening';

  @override
  String get timeOfDayLabel => 'TIME OF DAY';

  @override
  String get locationHint => 'Place (optional), e.g. city park';

  @override
  String get weatherMultiHint => 'Pick as many as you like';

  @override
  String get openInMaps => 'Open in maps';
}
