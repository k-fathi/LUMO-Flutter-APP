import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Lumo AI'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Lumo AI'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Description.
  ///
  /// In en, this message translates to:
  /// **'Your comprehensive medical platform for child care with the best doctors'**
  String get onboarding1Description;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Connect with Doctors'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Description.
  ///
  /// In en, this message translates to:
  /// **'Connect directly with specialist doctors and get instant consultations'**
  String get onboarding2Description;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Child\'s Health'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Description.
  ///
  /// In en, this message translates to:
  /// **'Monitor your child\'s health status and get continuous updates from your doctor'**
  String get onboarding3Description;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectRole;

  /// No description provided for @iAmParent.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Parent'**
  String get iAmParent;

  /// No description provided for @iAmDoctor.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Doctor'**
  String get iAmDoctor;

  /// No description provided for @parentDescription.
  ///
  /// In en, this message translates to:
  /// **'To monitor your child\'s health with the best doctors'**
  String get parentDescription;

  /// No description provided for @doctorDescription.
  ///
  /// In en, this message translates to:
  /// **'To provide medical care for children'**
  String get doctorDescription;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signupNow.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Now'**
  String get signupNow;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @childName.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Name'**
  String get childName;

  /// No description provided for @childAge.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Age'**
  String get childAge;

  /// No description provided for @childGender.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Gender'**
  String get childGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperience;

  /// No description provided for @clinicAddress.
  ///
  /// In en, this message translates to:
  /// **'Clinic Address'**
  String get clinicAddress;

  /// No description provided for @clinicPhone.
  ///
  /// In en, this message translates to:
  /// **'Clinic Phone'**
  String get clinicPhone;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @aiHelper.
  ///
  /// In en, this message translates to:
  /// **'AI Helper'**
  String get aiHelper;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPosts;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChats;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @askAI.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Assistant'**
  String get askAI;

  /// No description provided for @aiChatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type your question here...'**
  String get aiChatPlaceholder;

  /// No description provided for @aiWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Lumo AI assistant. How can I help you today?'**
  String get aiWelcome;

  /// No description provided for @myAnalyses.
  ///
  /// In en, this message translates to:
  /// **'My Analyses'**
  String get myAnalyses;

  /// No description provided for @myPatients.
  ///
  /// In en, this message translates to:
  /// **'My Patients'**
  String get myPatients;

  /// No description provided for @noAnalyses.
  ///
  /// In en, this message translates to:
  /// **'No analyses yet'**
  String get noAnalyses;

  /// No description provided for @noPatients.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get noPatients;

  /// No description provided for @createAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Create Analysis'**
  String get createAnalysis;

  /// No description provided for @analysisDate.
  ///
  /// In en, this message translates to:
  /// **'Analysis Date'**
  String get analysisDate;

  /// No description provided for @analysisNotes.
  ///
  /// In en, this message translates to:
  /// **'Analysis Notes'**
  String get analysisNotes;

  /// No description provided for @currentState.
  ///
  /// In en, this message translates to:
  /// **'Current State'**
  String get currentState;

  /// No description provided for @stateCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get stateCritical;

  /// No description provided for @stateBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get stateBad;

  /// No description provided for @stateModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get stateModerate;

  /// No description provided for @stateGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get stateGood;

  /// No description provided for @stateExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get stateExcellent;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @doctorRequest.
  ///
  /// In en, this message translates to:
  /// **'Request Doctor Connection'**
  String get doctorRequest;

  /// No description provided for @enterDoctorCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Doctor Code'**
  String get enterDoctorCode;

  /// No description provided for @doctorCode.
  ///
  /// In en, this message translates to:
  /// **'Doctor Code'**
  String get doctorCode;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @generateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate New Code'**
  String get generateCode;

  /// No description provided for @myCode.
  ///
  /// In en, this message translates to:
  /// **'My Code'**
  String get myCode;

  /// No description provided for @codeExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get codeExpires;

  /// No description provided for @codeUsage.
  ///
  /// In en, this message translates to:
  /// **'Times Used'**
  String get codeUsage;

  /// No description provided for @connectionRequests.
  ///
  /// In en, this message translates to:
  /// **'Connection Requests'**
  String get connectionRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirm;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get about;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'User privacy is our top priority.\\n\\n• We do not share your personal data with third parties.\\n• Health data is stored securely and encrypted.\\n• You can delete your account and all data at any time.\\n• We use data only to improve the user experience.\\n• Communication with doctors is confidential and secure.\\n\\nFor more information, contact us via email.'**
  String get privacyPolicyContent;

  /// No description provided for @aboutAppContent.
  ///
  /// In en, this message translates to:
  /// **'Graduation project by Beni Suef Communications Engineering students, 2nd batch, 2026.\\nThis application does not hold medical licenses.'**
  String get aboutAppContent;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password'**
  String get invalidPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsNotMatch;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created'**
  String get postCreated;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get postDeleted;

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added'**
  String get commentAdded;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @requestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted for {name}'**
  String requestAccepted(Object name);

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected for {name}'**
  String requestRejected(Object name);

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsers;

  /// No description provided for @searchPosts.
  ///
  /// In en, this message translates to:
  /// **'Search posts'**
  String get searchPosts;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get roleDoctor;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @deletePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePostTitle;

  /// No description provided for @yesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get yesDelete;

  /// No description provided for @viewPatients.
  ///
  /// In en, this message translates to:
  /// **'View Patients'**
  String get viewPatients;

  /// No description provided for @viewPatientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View list of followed patients'**
  String get viewPatientsSubtitle;

  /// No description provided for @generateNewCode.
  ///
  /// In en, this message translates to:
  /// **'Generate New Code'**
  String get generateNewCode;

  /// No description provided for @generateCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a code to share with a parent'**
  String get generateCodeSubtitle;

  /// No description provided for @clinicInfo.
  ///
  /// In en, this message translates to:
  /// **'Clinic Info'**
  String get clinicInfo;

  /// No description provided for @editClinicInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Clinic Info'**
  String get editClinicInfo;

  /// No description provided for @clinicNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic Name'**
  String get clinicNameLabel;

  /// No description provided for @dataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Data updated'**
  String get dataUpdated;

  /// No description provided for @joinDoctor.
  ///
  /// In en, this message translates to:
  /// **'Join Doctor'**
  String get joinDoctor;

  /// No description provided for @joinDoctorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter doctor code to link account'**
  String get joinDoctorSubtitle;

  /// No description provided for @analysisHistory.
  ///
  /// In en, this message translates to:
  /// **'Analysis History'**
  String get analysisHistory;

  /// No description provided for @viewChildAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View child\'s analysis history'**
  String get viewChildAnalysisSubtitle;

  /// No description provided for @childInfo.
  ///
  /// In en, this message translates to:
  /// **'Child Info'**
  String get childInfo;

  /// No description provided for @editChildInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit child info'**
  String get editChildInfo;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// No description provided for @profileLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Profile link copied'**
  String get profileLinkCopied;

  /// No description provided for @aiAlwaysOnline.
  ///
  /// In en, this message translates to:
  /// **'Always Online'**
  String get aiAlwaysOnline;

  /// No description provided for @aiWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m LUMO 👋'**
  String get aiWelcomeTitle;

  /// No description provided for @aiWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your smart assistant for child care.\\nHow can I help you today?'**
  String get aiWelcomeSubtitle;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noChatsYet;

  /// No description provided for @startNewChat.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation with doctors or the community'**
  String get startNewChat;

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get totalPatients;

  /// No description provided for @joinRequests.
  ///
  /// In en, this message translates to:
  /// **'Join Requests'**
  String get joinRequests;

  /// No description provided for @patientsList.
  ///
  /// In en, this message translates to:
  /// **'Patients List'**
  String get patientsList;

  /// No description provided for @patientSuffix.
  ///
  /// In en, this message translates to:
  /// **'patient'**
  String get patientSuffix;

  /// No description provided for @newCode.
  ///
  /// In en, this message translates to:
  /// **'New Code'**
  String get newCode;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTitle;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgo(Object count);

  /// No description provided for @overallMood.
  ///
  /// In en, this message translates to:
  /// **'Overall Mood: {mood}'**
  String overallMood(Object mood);

  /// No description provided for @childParent.
  ///
  /// In en, this message translates to:
  /// **'Parent of: {childName}'**
  String childParent(Object childName);

  /// No description provided for @emotionDistribution.
  ///
  /// In en, this message translates to:
  /// **'Emotion Distribution'**
  String get emotionDistribution;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get happy;

  /// No description provided for @calm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get calm;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get sad;

  /// No description provided for @angry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get angry;

  /// No description provided for @dailyHistory.
  ///
  /// In en, this message translates to:
  /// **'Daily History'**
  String get dailyHistory;

  /// No description provided for @childMoodSummary.
  ///
  /// In en, this message translates to:
  /// **'Your child shows positive emotions 80% this week ✨'**
  String get childMoodSummary;

  /// No description provided for @chatInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatInputPlaceholder;

  /// No description provided for @patientSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Summary'**
  String get patientSummaryTitle;

  /// No description provided for @aiProgressReport.
  ///
  /// In en, this message translates to:
  /// **'AI Progress Report'**
  String get aiProgressReport;

  /// No description provided for @aiReportContent.
  ///
  /// In en, this message translates to:
  /// **'Based on the recent sessions, your child is showing a 15% improvement in emotional regulation. Engagement during play therapy has increased, and calm intervals are longer compared to last month.'**
  String get aiReportContent;

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetrics;

  /// No description provided for @engagementRate.
  ///
  /// In en, this message translates to:
  /// **'Engagement Rate'**
  String get engagementRate;

  /// No description provided for @sessionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sessions Completed'**
  String get sessionsCompleted;

  /// No description provided for @improvementStatus.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvementStatus;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
