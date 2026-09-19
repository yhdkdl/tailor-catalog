// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tailor Catalog';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get amharic => 'አማርኛ (Amharic)';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInTitle => 'Tailor sign in';

  @override
  String get signInSubtitle => 'Sign in to manage your design catalog.';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get tryAgain => 'Try again';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get pendingApproval => 'Waiting for approval';

  @override
  String get pendingApprovalBody =>
      'Your account is pending approval. Please wait for the administrator to review and approve your account.';

  @override
  String get accountNotApproved => 'Account not approved';

  @override
  String get rejectedBody =>
      'Your account application was not approved. Please contact the administrator for more information.';

  @override
  String get uploadDesign => 'Upload Design';

  @override
  String get singlePhotoDesign => 'Single Photo Design';

  @override
  String get singlePhotoSubtitle => 'Upload one photo with category';

  @override
  String get bulkUpload => 'Bulk & Multi-Photo Upload';

  @override
  String get bulkUploadSubtitle =>
      'Upload multiple photos or a grouped carousel';

  @override
  String get deleteDesign => 'Delete Design';

  @override
  String get deleteConfirm =>
      'Are you sure you want to remove this design from your catalog?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get category => 'Category';

  @override
  String get tagOptional => 'Tag / Title (Optional)';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get editDesign => 'Edit Design';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get retake => 'Retake';

  @override
  String get useThisPhoto => 'Use This Photo';

  @override
  String get storeQrCode => 'Store QR Code';

  @override
  String get copyCatalogLink => 'Copy Catalog Link';

  @override
  String get shareCatalogLink => 'Share Catalog Link';

  @override
  String get pointCameraToScan => 'Point camera to scan';

  @override
  String get catalogUrlCopied => 'Catalog URL copied to clipboard!';

  @override
  String get syncNow => 'Sync now';

  @override
  String get tryAgainBtn => 'Try Again';

  @override
  String get uploadFirstDesign => 'Upload First Design';

  @override
  String get bulkUploadTitle => 'Bulk & Multi-Photo Upload';

  @override
  String get takePhotoWithCamera => 'Take Photo with Camera';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get uploading => 'Uploading...';

  @override
  String get noDesignsYet => 'No designs yet';

  @override
  String get errorLoadingDesigns => 'Could not load designs. Please try again.';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String batchDeleteConfirm(int count) {
    return 'Delete $count design(s)?';
  }

  @override
  String selected(int count) {
    return '$count selected';
  }

  @override
  String get selectPhotoRequired => 'Please select a design photo.';

  @override
  String get selectCategoryRequired => 'Please select a category';

  @override
  String get designUploadedSuccess => 'Design uploaded successfully!';

  @override
  String get optionalTagLabel => 'Optional Tag / Accent';

  @override
  String get tagHint => 'e.g. Silk Neckline, Wedding, Men Velvet';

  @override
  String get uploadingToCatalog => 'Uploading to Catalog...';

  @override
  String get publishDesign => 'Publish Design';

  @override
  String selectedPhotosCount(int count) {
    return 'Selected Photos ($count)';
  }

  @override
  String get selectPhotosFromGallery => 'Select Photos from Gallery';

  @override
  String get uploadStructure => 'Upload Structure';

  @override
  String get separateCards => 'Separate Cards';

  @override
  String get separateCardsDescription =>
      'Each photo is its own individual design';

  @override
  String get groupedCarousel => 'Grouped Carousel';

  @override
  String get groupedCarouselDescription => 'All photos in one swipeable design';

  @override
  String get bulkTagLabel => 'Optional Tag / Label';

  @override
  String get bulkTagHint => 'e.g. Habesha Silk, Men Collection 2026';

  @override
  String get publishingToCatalog => 'Publishing to Catalog...';

  @override
  String get publishMultiPhotoDesign => 'Publish Multi-Photo Design';

  @override
  String publishBulkDesigns(int count) {
    return 'Publish $count Designs';
  }

  @override
  String get selectAtLeastOnePhoto => 'Please select at least one photo.';

  @override
  String get multiPhotoSuccess => 'Multi-photo design created successfully!';

  @override
  String individualDesignsSuccess(int count) {
    return '$count individual designs created successfully!';
  }

  @override
  String get couldNotReadPhoto => 'Could not read selected photo.';

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get couldNotSelectPhotos => 'Could not select photos';

  @override
  String get cameraCaptureFailed => 'Camera capture failed';

  @override
  String get cover => 'COVER';

  @override
  String preparingPhotos(int count) {
    return 'Preparing $count photos...';
  }

  @override
  String uploadedPhotoProgress(int current, int total, int percent) {
    return 'Uploaded photo $current of $total ($percent%)';
  }

  @override
  String uploadedDesignProgress(int current, int total, int percent) {
    return 'Uploaded design $current of $total ($percent%)';
  }

  @override
  String get uploadingPhotos => 'Uploading photos...';

  @override
  String successfullySynced(int count) {
    return 'Successfully synced $count queued design(s)!';
  }

  @override
  String get designRemoved => 'Design removed';

  @override
  String get failedToDeleteDesign => 'Failed to delete design';

  @override
  String get deleteEntireCatalog => 'Delete Entire Catalog';

  @override
  String deleteCountDesigns(int count) {
    return 'Delete $count Designs';
  }

  @override
  String deleteCount(int count) {
    return 'Delete ($count)';
  }

  @override
  String allDesignsDeleted(int count) {
    return 'All $count designs deleted from catalog';
  }

  @override
  String successfullyDeletedCount(int count) {
    return 'Successfully deleted $count design(s)';
  }

  @override
  String deletedWithFailures(int successCount, int failedCount) {
    return 'Deleted $successCount design(s). Failed to delete $failedCount.';
  }

  @override
  String countSelected(int count) {
    return '$count Selected';
  }

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get selectAll => 'Select All';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get selectDesignsToDelete => 'Select Designs to Delete';

  @override
  String get approved => 'Approved';

  @override
  String get selectDesignsToDeleteBottom => 'Select designs to delete';

  @override
  String countOfTotalSelected(int count, int total) {
    return '$count of $total selected';
  }

  @override
  String uploadsPending(int count) {
    return '$count upload(s) pending in offline queue.';
  }

  @override
  String get designUpdatedSuccessfully => 'Design updated successfully';

  @override
  String get appTagline => 'Your Fashion. Your Catalog.';

  @override
  String get contactAdminReset => 'Contact admin to reset password';

  @override
  String get connectionError =>
      'Unable to connect. Please check your internet connection and try again.';

  @override
  String get invalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get serverError =>
      'Our servers are temporarily unavailable. Please try again in a few moments.';

  @override
  String get genericError => 'Something went wrong. Please try again.';
}
