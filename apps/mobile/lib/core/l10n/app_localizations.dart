import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
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
    Locale('am'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Tailor Catalog'**
  String get appTitle;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ (Amharic)'**
  String get amharic;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Tailor sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your design catalog.'**
  String get signInSubtitle;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get pendingApproval;

  /// No description provided for @pendingApprovalBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending approval. Please wait for the administrator to review and approve your account.'**
  String get pendingApprovalBody;

  /// No description provided for @accountNotApproved.
  ///
  /// In en, this message translates to:
  /// **'Account not approved'**
  String get accountNotApproved;

  /// No description provided for @rejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account application was not approved. Please contact the administrator for more information.'**
  String get rejectedBody;

  /// No description provided for @uploadDesign.
  ///
  /// In en, this message translates to:
  /// **'Upload Design'**
  String get uploadDesign;

  /// No description provided for @singlePhotoDesign.
  ///
  /// In en, this message translates to:
  /// **'Single Photo Design'**
  String get singlePhotoDesign;

  /// No description provided for @singlePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload one photo with category'**
  String get singlePhotoSubtitle;

  /// No description provided for @bulkUpload.
  ///
  /// In en, this message translates to:
  /// **'Bulk & Multi-Photo Upload'**
  String get bulkUpload;

  /// No description provided for @bulkUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload multiple photos or a grouped carousel'**
  String get bulkUploadSubtitle;

  /// No description provided for @deleteDesign.
  ///
  /// In en, this message translates to:
  /// **'Delete Design'**
  String get deleteDesign;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this design from your catalog?'**
  String get deleteConfirm;

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

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @tagOptional.
  ///
  /// In en, this message translates to:
  /// **'Tag / Title (Optional)'**
  String get tagOptional;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @editDesign.
  ///
  /// In en, this message translates to:
  /// **'Edit Design'**
  String get editDesign;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @useThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use This Photo'**
  String get useThisPhoto;

  /// No description provided for @storeQrCode.
  ///
  /// In en, this message translates to:
  /// **'Store QR Code'**
  String get storeQrCode;

  /// No description provided for @copyCatalogLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Catalog Link'**
  String get copyCatalogLink;

  /// No description provided for @shareCatalogLink.
  ///
  /// In en, this message translates to:
  /// **'Share Catalog Link'**
  String get shareCatalogLink;

  /// No description provided for @pointCameraToScan.
  ///
  /// In en, this message translates to:
  /// **'Point camera to scan'**
  String get pointCameraToScan;

  /// No description provided for @catalogUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'Catalog URL copied to clipboard!'**
  String get catalogUrlCopied;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @tryAgainBtn.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainBtn;

  /// No description provided for @uploadFirstDesign.
  ///
  /// In en, this message translates to:
  /// **'Upload First Design'**
  String get uploadFirstDesign;

  /// No description provided for @bulkUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk & Multi-Photo Upload'**
  String get bulkUploadTitle;

  /// No description provided for @takePhotoWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get takePhotoWithCamera;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @noDesignsYet.
  ///
  /// In en, this message translates to:
  /// **'No designs yet'**
  String get noDesignsYet;

  /// No description provided for @errorLoadingDesigns.
  ///
  /// In en, this message translates to:
  /// **'Could not load designs. Please try again.'**
  String get errorLoadingDesigns;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// No description provided for @batchDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} design(s)?'**
  String batchDeleteConfirm(int count);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected(int count);

  /// No description provided for @selectPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a design photo.'**
  String get selectPhotoRequired;

  /// No description provided for @selectCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategoryRequired;

  /// No description provided for @designUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Design uploaded successfully!'**
  String get designUploadedSuccess;

  /// No description provided for @optionalTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional Tag / Accent'**
  String get optionalTagLabel;

  /// No description provided for @tagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Silk Neckline, Wedding, Men Velvet'**
  String get tagHint;

  /// No description provided for @uploadingToCatalog.
  ///
  /// In en, this message translates to:
  /// **'Uploading to Catalog...'**
  String get uploadingToCatalog;

  /// No description provided for @publishDesign.
  ///
  /// In en, this message translates to:
  /// **'Publish Design'**
  String get publishDesign;

  /// No description provided for @selectedPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'Selected Photos ({count})'**
  String selectedPhotosCount(int count);

  /// No description provided for @selectPhotosFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select Photos from Gallery'**
  String get selectPhotosFromGallery;

  /// No description provided for @uploadStructure.
  ///
  /// In en, this message translates to:
  /// **'Upload Structure'**
  String get uploadStructure;

  /// No description provided for @separateCards.
  ///
  /// In en, this message translates to:
  /// **'Separate Cards'**
  String get separateCards;

  /// No description provided for @separateCardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Each photo is its own individual design'**
  String get separateCardsDescription;

  /// No description provided for @groupedCarousel.
  ///
  /// In en, this message translates to:
  /// **'Grouped Carousel'**
  String get groupedCarousel;

  /// No description provided for @groupedCarouselDescription.
  ///
  /// In en, this message translates to:
  /// **'All photos in one swipeable design'**
  String get groupedCarouselDescription;

  /// No description provided for @bulkTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional Tag / Label'**
  String get bulkTagLabel;

  /// No description provided for @bulkTagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Habesha Silk, Men Collection 2026'**
  String get bulkTagHint;

  /// No description provided for @publishingToCatalog.
  ///
  /// In en, this message translates to:
  /// **'Publishing to Catalog...'**
  String get publishingToCatalog;

  /// No description provided for @publishMultiPhotoDesign.
  ///
  /// In en, this message translates to:
  /// **'Publish Multi-Photo Design'**
  String get publishMultiPhotoDesign;

  /// No description provided for @publishBulkDesigns.
  ///
  /// In en, this message translates to:
  /// **'Publish {count} Designs'**
  String publishBulkDesigns(int count);

  /// No description provided for @selectAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one photo.'**
  String get selectAtLeastOnePhoto;

  /// No description provided for @multiPhotoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Multi-photo design created successfully!'**
  String get multiPhotoSuccess;

  /// No description provided for @individualDesignsSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} individual designs created successfully!'**
  String individualDesignsSuccess(int count);

  /// No description provided for @couldNotReadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Could not read selected photo.'**
  String get couldNotReadPhoto;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get failedToLoadCategories;

  /// No description provided for @couldNotSelectPhotos.
  ///
  /// In en, this message translates to:
  /// **'Could not select photos'**
  String get couldNotSelectPhotos;

  /// No description provided for @cameraCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera capture failed'**
  String get cameraCaptureFailed;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'COVER'**
  String get cover;

  /// No description provided for @preparingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Preparing {count} photos...'**
  String preparingPhotos(int count);

  /// No description provided for @uploadedPhotoProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploaded photo {current} of {total} ({percent}%)'**
  String uploadedPhotoProgress(int current, int total, int percent);

  /// No description provided for @uploadedDesignProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploaded design {current} of {total} ({percent}%)'**
  String uploadedDesignProgress(int current, int total, int percent);

  /// No description provided for @uploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos...'**
  String get uploadingPhotos;

  /// No description provided for @successfullySynced.
  ///
  /// In en, this message translates to:
  /// **'Successfully synced {count} queued design(s)!'**
  String successfullySynced(int count);

  /// No description provided for @designRemoved.
  ///
  /// In en, this message translates to:
  /// **'Design removed'**
  String get designRemoved;

  /// No description provided for @failedToDeleteDesign.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete design'**
  String get failedToDeleteDesign;

  /// No description provided for @deleteEntireCatalog.
  ///
  /// In en, this message translates to:
  /// **'Delete Entire Catalog'**
  String get deleteEntireCatalog;

  /// No description provided for @deleteCountDesigns.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} Designs'**
  String deleteCountDesigns(int count);

  /// No description provided for @deleteCount.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String deleteCount(int count);

  /// No description provided for @allDesignsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All {count} designs deleted from catalog'**
  String allDesignsDeleted(int count);

  /// No description provided for @successfullyDeletedCount.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted {count} design(s)'**
  String successfullyDeletedCount(int count);

  /// No description provided for @deletedWithFailures.
  ///
  /// In en, this message translates to:
  /// **'Deleted {successCount} design(s). Failed to delete {failedCount}.'**
  String deletedWithFailures(int successCount, int failedCount);

  /// No description provided for @countSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String countSelected(int count);

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @selectDesignsToDelete.
  ///
  /// In en, this message translates to:
  /// **'Select Designs to Delete'**
  String get selectDesignsToDelete;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @selectDesignsToDeleteBottom.
  ///
  /// In en, this message translates to:
  /// **'Select designs to delete'**
  String get selectDesignsToDeleteBottom;

  /// No description provided for @countOfTotalSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} selected'**
  String countOfTotalSelected(int count, int total);

  /// No description provided for @uploadsPending.
  ///
  /// In en, this message translates to:
  /// **'{count} upload(s) pending in offline queue.'**
  String uploadsPending(int count);

  /// No description provided for @designUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Design updated successfully'**
  String get designUpdatedSuccessfully;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Fashion. Your Catalog.'**
  String get appTagline;

  /// No description provided for @contactAdminReset.
  ///
  /// In en, this message translates to:
  /// **'Contact admin to reset password'**
  String get contactAdminReset;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Please check your internet connection and try again.'**
  String get connectionError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Our servers are temporarily unavailable. Please try again in a few moments.'**
  String get serverError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;
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
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
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
