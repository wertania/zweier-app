import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zweier'**
  String get appTitle;

  /// No description provided for @weatherSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get weatherSunny;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get weatherRainy;

  /// No description provided for @weatherSnowy.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnowy;

  /// No description provided for @weatherAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get weatherAny;

  /// No description provided for @durationShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get durationShort;

  /// No description provided for @durationHalfDay.
  ///
  /// In en, this message translates to:
  /// **'Half a day'**
  String get durationHalfDay;

  /// No description provided for @durationFullDay.
  ///
  /// In en, this message translates to:
  /// **'Full day'**
  String get durationFullDay;

  /// No description provided for @durationMultiDay.
  ///
  /// In en, this message translates to:
  /// **'Several days'**
  String get durationMultiDay;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Oops: {error}'**
  String errorPrefix(String error);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your shared ideas, outings\nand travel dreams – in one place.'**
  String get appTagline;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get emailHint;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send login code'**
  String get sendCode;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to\n{email} 💌'**
  String codeSentTo(String email);

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get letsGo;

  /// No description provided for @useOtherEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get useOtherEmail;

  /// No description provided for @setServer.
  ///
  /// In en, this message translates to:
  /// **'Set server'**
  String get setServer;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @coupleSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shared place'**
  String get coupleSetupTitle;

  /// No description provided for @coupleSetupText.
  ///
  /// In en, this message translates to:
  /// **'Create your space and invite your sweetheart afterwards – or accept an invitation.'**
  String get coupleSetupText;

  /// No description provided for @invitationsForYou.
  ///
  /// In en, this message translates to:
  /// **'INVITATIONS FOR YOU'**
  String get invitationsForYou;

  /// No description provided for @sharedSpace.
  ///
  /// In en, this message translates to:
  /// **'Shared space'**
  String get sharedSpace;

  /// No description provided for @youWereInvited.
  ///
  /// In en, this message translates to:
  /// **'You have been invited'**
  String get youWereInvited;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW'**
  String get createNew;

  /// No description provided for @coupleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Anna & Ben'**
  String get coupleNameHint;

  /// No description provided for @coupleNameDefault.
  ///
  /// In en, this message translates to:
  /// **'The two of us'**
  String get coupleNameDefault;

  /// No description provided for @createCouple.
  ///
  /// In en, this message translates to:
  /// **'Create our space'**
  String get createCouple;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get navIdeas;

  /// No description provided for @navTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get navTrips;

  /// No description provided for @navUs.
  ///
  /// In en, this message translates to:
  /// **'Us'**
  String get navUs;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, you two ☕'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In en, this message translates to:
  /// **'Happy {weekday}, you two 🌼'**
  String greetingDay(String weekday);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, you two 🌙'**
  String get greetingEvening;

  /// No description provided for @whatShallWeDo.
  ///
  /// In en, this message translates to:
  /// **'What shall we do?'**
  String get whatShallWeDo;

  /// No description provided for @whenLabel.
  ///
  /// In en, this message translates to:
  /// **'WHEN?'**
  String get whenLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'HOW MUCH TIME DO YOU HAVE?'**
  String get timeLabel;

  /// No description provided for @weatherLabel.
  ///
  /// In en, this message translates to:
  /// **'WEATHER'**
  String get weatherLabel;

  /// No description provided for @forecast.
  ///
  /// In en, this message translates to:
  /// **'📍 Forecast'**
  String get forecast;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrowWeekday.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow ({weekday})'**
  String tomorrowWeekday(String weekday);

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Surprise yourselves!'**
  String get heroTitle;

  /// No description provided for @heroText.
  ///
  /// In en, this message translates to:
  /// **'We pick from your {count} ideas what fits the weather and your time.'**
  String heroText(int count);

  /// No description provided for @ourTips.
  ///
  /// In en, this message translates to:
  /// **'Our tips'**
  String get ourTips;

  /// No description provided for @weatherExpected.
  ///
  /// In en, this message translates to:
  /// **'{weather} expected · {min}–{max} °C'**
  String weatherExpected(String weather, String min, String max);

  /// No description provided for @anyWeather.
  ///
  /// In en, this message translates to:
  /// **'For any weather'**
  String get anyWeather;

  /// No description provided for @nothingFittingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing fitting yet'**
  String get nothingFittingTitle;

  /// No description provided for @nothingFittingText.
  ///
  /// In en, this message translates to:
  /// **'Add a few favourite things under “Ideas” – then there is more to choose from.'**
  String get nothingFittingText;

  /// No description provided for @rollAgain.
  ///
  /// In en, this message translates to:
  /// **'Roll again'**
  String get rollAgain;

  /// No description provided for @newIdea.
  ///
  /// In en, this message translates to:
  /// **'New idea'**
  String get newIdea;

  /// No description provided for @todoQuestion.
  ///
  /// In en, this message translates to:
  /// **'What do we want to do there?'**
  String get todoQuestion;

  /// No description provided for @editIdea.
  ///
  /// In en, this message translates to:
  /// **'Edit idea'**
  String get editIdea;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Really delete?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmText.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed.'**
  String deleteConfirmText(String title);

  /// No description provided for @ideaTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Picnic at the lake'**
  String get ideaTitleHint;

  /// No description provided for @ideaNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes, address, what to bring …'**
  String get ideaNotesHint;

  /// No description provided for @goodFor.
  ///
  /// In en, this message translates to:
  /// **'GOOD FOR'**
  String get goodFor;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get durationLabel;

  /// No description provided for @heartIdea.
  ///
  /// In en, this message translates to:
  /// **'Heart idea ❤️'**
  String get heartIdea;

  /// No description provided for @heartIdeaHint.
  ///
  /// In en, this message translates to:
  /// **'Preferred in suggestions'**
  String get heartIdeaHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @ourIdeas.
  ///
  /// In en, this message translates to:
  /// **'Our ideas'**
  String get ourIdeas;

  /// No description provided for @showDone.
  ///
  /// In en, this message translates to:
  /// **'Show done'**
  String get showDone;

  /// No description provided for @ideaFab.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get ideaFab;

  /// No description provided for @emptyIdeasTitle.
  ///
  /// In en, this message translates to:
  /// **'Your idea garden is still empty'**
  String get emptyIdeasTitle;

  /// No description provided for @emptyIdeasText.
  ///
  /// In en, this message translates to:
  /// **'Collect everything you love doing together – from movie night to a long hike.'**
  String get emptyIdeasText;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @tryOtherFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter.'**
  String get tryOtherFilter;

  /// No description provided for @wasLovely.
  ///
  /// In en, this message translates to:
  /// **'That was lovely! 💕'**
  String get wasLovely;

  /// No description provided for @tripDreams.
  ///
  /// In en, this message translates to:
  /// **'Travel dreams'**
  String get tripDreams;

  /// No description provided for @destinationFab.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationFab;

  /// No description provided for @emptyTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to next?'**
  String get emptyTripsTitle;

  /// No description provided for @emptyTripsText.
  ///
  /// In en, this message translates to:
  /// **'Collect your dream destinations and attach a list of things you want to experience there.'**
  String get emptyTripsText;

  /// No description provided for @alreadyExperienced.
  ///
  /// In en, this message translates to:
  /// **'ALREADY BEEN 💛'**
  String get alreadyExperienced;

  /// No description provided for @experiences.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} experiences'**
  String experiences(int done, int total);

  /// No description provided for @newDestination.
  ///
  /// In en, this message translates to:
  /// **'New destination'**
  String get newDestination;

  /// No description provided for @editDestination.
  ///
  /// In en, this message translates to:
  /// **'Edit destination'**
  String get editDestination;

  /// No description provided for @placeHint.
  ///
  /// In en, this message translates to:
  /// **'Place, e.g. Lisbon'**
  String get placeHint;

  /// No description provided for @countryHint.
  ///
  /// In en, this message translates to:
  /// **'Country (optional)'**
  String get countryHint;

  /// No description provided for @whyHint.
  ///
  /// In en, this message translates to:
  /// **'Why do we want to go there?'**
  String get whyHint;

  /// No description provided for @noDateYet.
  ///
  /// In en, this message translates to:
  /// **'No date yet'**
  String get noDateYet;

  /// No description provided for @setDate.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setDate;

  /// No description provided for @beenThere.
  ///
  /// In en, this message translates to:
  /// **'We\'ve been there 💛'**
  String get beenThere;

  /// No description provided for @deleteDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteDestinationTitle(String name);

  /// No description provided for @deleteDestinationText.
  ///
  /// In en, this message translates to:
  /// **'The list with all experiences will be deleted as well.'**
  String get deleteDestinationText;

  /// No description provided for @experienceFab.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experienceFab;

  /// No description provided for @emptyTodosTitle.
  ///
  /// In en, this message translates to:
  /// **'What do we want to experience there?'**
  String get emptyTodosTitle;

  /// No description provided for @emptyTodosText.
  ///
  /// In en, this message translates to:
  /// **'Write down the great things you could do there – just like your ideas at home.'**
  String get emptyTodosText;

  /// No description provided for @stillAhead.
  ///
  /// In en, this message translates to:
  /// **'STILL AHEAD'**
  String get stillAhead;

  /// No description provided for @alreadyDone.
  ///
  /// In en, this message translates to:
  /// **'ALREADY DONE 💕'**
  String get alreadyDone;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your sweetheart 💌'**
  String get inviteTitle;

  /// No description provided for @partnerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Your partner\'s email'**
  String get partnerEmailHint;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation is on its way 💌'**
  String get invitationSent;

  /// No description provided for @statIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get statIdeas;

  /// No description provided for @statDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statDone;

  /// No description provided for @statTraveled.
  ///
  /// In en, this message translates to:
  /// **'Travelled'**
  String get statTraveled;

  /// No description provided for @usTwo.
  ///
  /// In en, this message translates to:
  /// **'THE TWO OF US'**
  String get usTwo;

  /// No description provided for @thatsYou.
  ///
  /// In en, this message translates to:
  /// **'That\'s you'**
  String get thatsYou;

  /// No description provided for @yourLove.
  ///
  /// In en, this message translates to:
  /// **'Your sweetheart'**
  String get yourLove;

  /// No description provided for @invitePartner.
  ///
  /// In en, this message translates to:
  /// **'Invite your partner'**
  String get invitePartner;

  /// No description provided for @invitePartnerHint.
  ///
  /// In en, this message translates to:
  /// **'Then you plan together'**
  String get invitePartnerHint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for the two of you'**
  String get madeWithLove;

  /// No description provided for @us.
  ///
  /// In en, this message translates to:
  /// **'Us'**
  String get us;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
