// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nectar';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get logout => 'Log out';

  @override
  String get logoutFromAccount => 'Log out of account';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get back => 'Back';

  @override
  String get add => 'Add';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get saveFailed => 'Could not save. Please try again.';

  @override
  String get loadFailedCheckConnection =>
      'Could not load data. Check your connection.';

  @override
  String get loadFailedTryLater => 'Could not load data. Please try later.';

  @override
  String get notEnoughStock => 'No more items in stock';

  @override
  String get language => 'Language';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageEnglish => 'English';

  @override
  String get selectLanguage => 'Choose language';

  @override
  String get navShop => 'Shop';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Profile';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleCourier => 'Courier';

  @override
  String get roleBuyer => 'Customer';

  @override
  String get roleGuest => 'Guest';

  @override
  String get valLoginRequired => 'Enter your login';

  @override
  String get valLoginLength => 'Login must be 3 to 50 characters long';

  @override
  String get valLoginChars => 'Latin letters, digits and ._- only';

  @override
  String get valFieldRequired => 'This field cannot be empty';

  @override
  String get valNameLength => 'Must be 2 to 50 characters long';

  @override
  String get valNameChars => 'Letters, spaces and hyphens only';

  @override
  String get valEmailRequired => 'Enter your email';

  @override
  String get valEmailLength => 'Email must not exceed 100 characters';

  @override
  String get valEmailFormat => 'Invalid email format';

  @override
  String get valPhoneRequired => 'Enter your phone number';

  @override
  String get valPhoneFormat => 'Invalid phone number format';

  @override
  String get valPasswordRequired => 'Enter your password';

  @override
  String get valPasswordNoSpaces => 'Password must not contain spaces';

  @override
  String get valPasswordMaxLength => 'At most 128 characters';

  @override
  String get valPasswordMinLength => 'At least 6 characters';

  @override
  String get valPasswordDigit => 'Password must contain at least one digit';

  @override
  String get valPasswordConfirmRequired => 'Confirm your password';

  @override
  String get valPasswordMismatch => 'Passwords do not match';

  @override
  String valNamedFieldRequired(String fieldName) {
    return 'The “$fieldName” field is required';
  }

  @override
  String valNamedFieldMaxLength(String fieldName, int maxLength) {
    return 'The “$fieldName” field must not exceed $maxLength characters';
  }

  @override
  String get valPriceRequired => 'Enter the price';

  @override
  String get valPricePositive => 'The price must be greater than 0';

  @override
  String valNamedValueRequired(String fieldName) {
    return 'Enter a value for “$fieldName”';
  }

  @override
  String valNamedRange(String fieldName, int minValue, int maxValue) {
    return 'The “$fieldName” field must be between $minValue and $maxValue';
  }

  @override
  String get valPromoRequired => 'Enter a promo code';

  @override
  String get valPromoChars => 'Latin letters and digits only';

  @override
  String get valTaxIdRequired => 'Enter the tax ID';

  @override
  String get valTaxIdFormat => 'Tax ID must contain 10 or 12 digits';

  @override
  String get valCardRequired => 'Enter the card number';

  @override
  String get valCardLength => 'The card number must contain 16 digits';

  @override
  String get sortDefault => 'Default';

  @override
  String get sortFreshFirst => 'Freshest first';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get filtersTitle => 'Filters';

  @override
  String filterPrice(int from, int to) {
    return 'Price: $from – $to ₽';
  }

  @override
  String get filterBrand => 'Brand';

  @override
  String get filterSort => 'Sort by';

  @override
  String get noProductsForFilters => 'No products match the selected filters';

  @override
  String get slotAsap => 'As soon as possible (within 60 minutes)';

  @override
  String get noDescription => 'No detailed description available.';

  @override
  String get currencyRub => '₽';

  @override
  String get unitKg => 'kg';

  @override
  String get unitG => 'g';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitPcs => 'pcs';

  @override
  String get authInvalidEmail => 'Invalid email address.';

  @override
  String get authUserDisabled => 'This account has been disabled.';

  @override
  String get authWrongCredentials => 'Wrong email or password.';

  @override
  String get authEmailInUse => 'This email is already in use.';

  @override
  String get authWeakPassword => 'The password is too weak.';

  @override
  String get authNetworkError => 'Could not connect to the network.';

  @override
  String get authTooManyRequests => 'Too many attempts. Please try later.';

  @override
  String get authAccountDeleted => 'This account has been deleted.';

  @override
  String get authNotSignedIn => 'You are not signed in.';

  @override
  String get authWrongCurrentPassword => 'The current password is incorrect.';

  @override
  String get errLoginTaken => 'A user with this login already exists.';

  @override
  String get errLoginNotFound => 'No user with this login was found.';

  @override
  String get errAddressEmpty => 'The address cannot be empty.';

  @override
  String get errAddressTooLong => 'The address must not exceed 300 characters.';

  @override
  String get errCardLength => 'The card number must contain 16 digits.';

  @override
  String get errPromoInvalid => 'Invalid or expired promo code.';

  @override
  String get errCartEmpty => 'The cart is empty.';

  @override
  String get errDeliveryAddressRequired => 'Specify a delivery address.';

  @override
  String get errPaymentMethodRequired => 'Choose a payment method.';

  @override
  String get errUserNotFound => 'User not found.';

  @override
  String get errQuantityPositive => 'The quantity must be greater than zero.';

  @override
  String errProductUnavailable(String name) {
    return 'The product “$name” is unavailable.';
  }

  @override
  String errNotEnoughStock(String name) {
    return 'Not enough “$name” in stock.';
  }

  @override
  String get errOrderNotFound => 'Order not found.';

  @override
  String get errUserHasActiveOrders =>
      'You cannot delete a user who has unfinished orders.';

  @override
  String get errCategoryNameRequired => 'The category name is required.';

  @override
  String get errCategoryNameTooLong =>
      'The category name must not exceed 100 characters.';

  @override
  String get errCategoryDescriptionTooLong =>
      'The category description must not exceed 500 characters.';

  @override
  String get errCategoryExists => 'A category with this name already exists.';

  @override
  String get errCategoryNotFound => 'Category not found.';

  @override
  String get errCategoryHasProducts =>
      'You cannot delete a category that has products.';

  @override
  String get errManufacturerNameRequired =>
      'The manufacturer name is required.';

  @override
  String get errManufacturerNameTooLong =>
      'The manufacturer name must not exceed 100 characters.';

  @override
  String get errManufacturerExists =>
      'A manufacturer with this name already exists.';

  @override
  String get errManufacturerNotFound => 'Manufacturer not found.';

  @override
  String get errManufacturerHasProducts =>
      'You cannot delete a manufacturer that has products.';

  @override
  String get errSupplierNameRequired => 'The supplier name is required.';

  @override
  String get errSupplierExists => 'A supplier with this name already exists.';

  @override
  String get errSupplierNotFound => 'Supplier not found.';

  @override
  String get errSupplierHasSupplies =>
      'You cannot delete a supplier with active product supplies.';

  @override
  String get errRoleNameRequired => 'The role name is required.';

  @override
  String get errRoleNameTooLong =>
      'The role name must not exceed 50 characters.';

  @override
  String get errRoleExists => 'A role with this name already exists.';

  @override
  String get errRoleHasUsers => 'You cannot delete a role that has users.';

  @override
  String get errStatusNameRequired => 'The status name is required.';

  @override
  String get errStatusNameTooLong =>
      'The status name must not exceed 50 characters.';

  @override
  String get errStatusExists => 'A status with this name already exists.';

  @override
  String get errStatusInUse => 'You cannot delete a status used by orders.';

  @override
  String get errPromoCodeRequired => 'The promo code is required.';

  @override
  String get errPromoCodeChars =>
      'The promo code must contain only Latin letters and digits.';

  @override
  String get errPromoDiscountRange => 'The discount must be between 1 and 99%.';

  @override
  String get errPromoExpiryPast =>
      'The promo code expiry date cannot be in the past.';

  @override
  String get errPromoCodeExists =>
      'A promo code with this code already exists.';

  @override
  String get errPromoInActiveOrders =>
      'You cannot delete a promo code used in unfinished orders.';

  @override
  String get errProductNameRequired => 'The product name is required.';

  @override
  String get errProductNameTooLong =>
      'The product name must not exceed 255 characters.';

  @override
  String get errProductDescriptionTooLong =>
      'The product description must not exceed 2000 characters.';

  @override
  String get errProductPricePositive =>
      'The product price must be greater than 0.';

  @override
  String get errProductStockRange =>
      'The stock quantity must be between 0 and 9999.';

  @override
  String get errProductNeedsCategory =>
      'Choose a category and a manufacturer for the product.';

  @override
  String get errOrderAlreadyTaken =>
      'This order has already been taken by another courier.';

  @override
  String get errOrderCannotRelease =>
      'The order cannot be returned: it is on the way or assigned to someone else.';

  @override
  String get aboutVersion => 'Version 1.0.0';

  @override
  String get aboutTerms => 'Terms of use';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutLicenses => 'Licenses';

  @override
  String get avatarFormatError => 'Only JPEG and PNG images are allowed.';

  @override
  String get avatarTooBig =>
      'The image is too large: at most 150 KB after compression.';

  @override
  String get avatarUpdated => 'Avatar updated.';

  @override
  String get avatarUploadFailed => 'Could not upload the image.';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountBody =>
      'Your account will be deleted if you have no unfinished orders. This cannot be undone.';

  @override
  String get deleteAccountRecentLogin =>
      'Please sign in again to delete your account.';

  @override
  String get deleteAccountFailed => 'Could not delete the account.';

  @override
  String get noEmail => 'No email';

  @override
  String get menuOrders => 'Orders';

  @override
  String get menuMyDetails => 'My details';

  @override
  String get menuDeliveryAddress => 'Delivery address';

  @override
  String get menuPaymentMethods => 'Payment methods';

  @override
  String get menuPromoCodes => 'Promo codes';

  @override
  String get menuChangePassword => 'Change password';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuAbout => 'About the app';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get addAddressTitle => 'Add address';

  @override
  String get addAddressHint => 'Enter your address (street, house, apt.)';

  @override
  String get addressRemoveFailed => 'Could not remove the address.';

  @override
  String get addressesSignIn => 'Sign in to view your addresses';

  @override
  String get addressesEmptyTitle => 'No saved addresses';

  @override
  String get addressesEmptyBody =>
      'Add an address to have your purchases delivered.';

  @override
  String get resetSentTitle => 'Email sent!';

  @override
  String resetSentBody(String email) {
    return 'We sent password reset instructions to\n$email\n\nIf you do not see the email, check your spam folder.';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordInfo =>
      'Enter the email you used to register. We will send you a link to create a new password.';

  @override
  String get resetEmailLabel => 'Your email';

  @override
  String get resetSendButton => 'Send email';

  @override
  String get loginPanelAppBar => 'Panel sign-in';

  @override
  String get loginPanelTitle => 'Web panel sign-in';

  @override
  String get loginTitle => 'Sign in to Nectar';

  @override
  String get loginPanelSubtitle => 'Sign in as an administrator or manager.';

  @override
  String get loginSubtitle =>
      'Sign in with your login or email to manage orders and shopping.';

  @override
  String get loginIdentifierLabel => 'Login or email';

  @override
  String get loginIdentifierRequired => 'Enter your login or email';

  @override
  String get loginIdentifierInvalid => 'The login or email is invalid';

  @override
  String get loginIdentifierHint => 'For example, ivan_01 or user@mail.com';

  @override
  String get labelPassword => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get signInToPanel => 'Sign in to the panel';

  @override
  String get signIn => 'Sign in';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerAction => 'Sign up';

  @override
  String get panelInfoNote =>
      'Customers and couriers use the mobile app. The web panel is only for the “Administrator” and “Manager” roles.';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerHeading => 'New customer account';

  @override
  String get registerRoleNote =>
      'After signing up you will automatically get the “Customer” role.';

  @override
  String get labelLogin => 'Login';

  @override
  String get registerLoginHint => 'For example, ivan_venikov';

  @override
  String get labelName => 'Name';

  @override
  String get registerNameHint => 'Your name';

  @override
  String get labelPhone => 'Phone';

  @override
  String get labelEmail => 'Email';

  @override
  String get registerPasswordHint => 'At least 6 characters and one digit';

  @override
  String get labelPasswordConfirm => 'Confirm password';

  @override
  String get registerPasswordRepeatHint => 'Repeat the password';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get profileLoadFailed =>
      'Could not load your profile. Check your connection.';

  @override
  String roleBlockedTitle(String roleName) {
    return 'The “$roleName” role cannot use the mobile app.';
  }

  @override
  String get roleBlockedBody =>
      'Please use the web version (website) for administration.';

  @override
  String get checkoutSignInRequired => 'You need to sign in.';

  @override
  String get checkoutSelectAddress => 'Select a delivery address.';

  @override
  String get checkoutSelectCard => 'Choose a saved card for online payment.';

  @override
  String get checkoutFailed => 'Could not place the order.';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get addAddressInProfile => 'Add an address in your profile';

  @override
  String get paymentMethodTitle => 'Payment method';

  @override
  String get cardLabel => 'Card';

  @override
  String get addCardInProfile => 'Add a card in your profile';

  @override
  String get promoCodeLabel => 'Promo code';

  @override
  String get promoNotSelected => 'Not selected';

  @override
  String get choose => 'Choose';

  @override
  String get summaryItemsTotal => 'Items total';

  @override
  String get placeOrder => 'Place order';

  @override
  String get orderSuccessTitle => 'Order placed successfully!';

  @override
  String orderSuccessBody(String number) {
    return 'Order number: $number\nThe order history and further notifications will be available in your profile.';
  }

  @override
  String get backToShop => 'Back to the shop';

  @override
  String get courierUpdateFailed =>
      'Could not update the order. Please try again.';

  @override
  String get courierNotSignedIn => 'The courier is not signed in.';

  @override
  String get courierTitle => 'Delivery';

  @override
  String get courierNoOrders => 'You have no assigned orders yet.';

  @override
  String get courierOrderDefault => 'Order';

  @override
  String get courierAddressMissing => 'Address not specified';

  @override
  String courierSlot(String slot) {
    return 'Time: $slot';
  }

  @override
  String courierCustomer(String name, String phone) {
    return 'Customer: $name$phone';
  }

  @override
  String courierCashDue(String amount) {
    return 'Cash to collect: $amount';
  }

  @override
  String courierStatus(String status) {
    return 'Status: $status';
  }

  @override
  String get courierStart => 'Start delivery';

  @override
  String get courierComplete => 'Confirm delivery';

  @override
  String get courierActiveTitle => 'Active orders';

  @override
  String get courierHistoryTitle => 'Delivery history';

  @override
  String get courierNoActive =>
      'No active orders. New assignments will appear here.';

  @override
  String get courierConfirmTitle => 'Confirm the delivery?';

  @override
  String courierConfirmBody(String number) {
    return 'Order $number will be marked as delivered. This cannot be undone.';
  }

  @override
  String get courierCancelledNote =>
      'The order was cancelled: no delivery needed.';

  @override
  String courierPayment(String method) {
    return 'Payment: $method';
  }

  @override
  String courierTotal(String amount) {
    return 'Order total: $amount';
  }

  @override
  String get courierPhoneCopied => 'Phone number copied';

  @override
  String get courierItemsTitle => 'Items';

  @override
  String get courierTabMine => 'My orders';

  @override
  String get courierTabAvailable => 'Available';

  @override
  String get courierNoAvailable =>
      'No free orders. New orders will appear here automatically.';

  @override
  String get courierClaim => 'Take order';

  @override
  String get courierClaimed => 'Order taken';

  @override
  String get courierRelease => 'Return to pool';

  @override
  String get courierReleaseTitle => 'Return the order?';

  @override
  String courierReleaseBody(String number) {
    return 'Order $number will become available to other couriers again.';
  }

  @override
  String get courierReleased => 'Order returned to the pool';

  @override
  String get detailsSaved => 'Your details have been saved';

  @override
  String get detailsSaveFailed =>
      'Could not save your details. Please try again.';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get emailReadOnly => 'Email (cannot be changed)';

  @override
  String get faqTitle => 'Frequently asked questions';

  @override
  String get faqTrackQ => 'How do I track my order?';

  @override
  String get faqTrackA =>
      'You can track your order in the “Orders” section of your profile.';

  @override
  String get faqReturnQ => 'How do I return an item?';

  @override
  String get faqReturnA =>
      'You can request a return within 7 days after delivery by contacting our support.';

  @override
  String get faqPaymentQ => 'Which payment methods are accepted?';

  @override
  String get faqPaymentA =>
      'We accept bank cards, Apple Pay and cash payment to the courier.';

  @override
  String get faqPromoQ => 'How do I use promo codes?';

  @override
  String get faqPromoA =>
      'Enter the promo code on the checkout screen or in the “Promo codes” section.';

  @override
  String get categoryOther => 'Other';

  @override
  String shareMessage(String name, String price, String link) {
    return '🍏 Look what I found in Nectar!\n\n✨ $name for just $price ₽.\n\nOrder right now:\n🔗 $link';
  }

  @override
  String get paymentOnline => 'Online';

  @override
  String get paymentCash => 'Cash';

  @override
  String get userDefaultName => 'User';

  @override
  String get notificationsSignIn => 'Sign in to view notifications';

  @override
  String get notificationsCleared => 'All notifications cleared.';

  @override
  String get notificationsClearFailed => 'Could not clear notifications.';

  @override
  String get clearAll => 'Clear all';

  @override
  String get notifPushTitle => 'Push notifications';

  @override
  String get notifPushSubtitle => 'Receive in-app order notifications';

  @override
  String get notifSmsTitle => 'SMS notifications';

  @override
  String get notifSmsSubtitle => 'Receive delivery messages';

  @override
  String get notifEmailTitle => 'Email notifications';

  @override
  String get notifEmailSubtitle => 'Receive offers and reminders by email';

  @override
  String get notifHistoryTitle => 'Notification history';

  @override
  String get notifEmpty =>
      'No notifications yet. They will appear automatically when an order status changes.';

  @override
  String get notifDefaultText => 'Notification';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboarding1Title => 'Freshness guaranteed';

  @override
  String get onboarding1Body =>
      'We carefully select vegetables, fruit, meat and dairy for your table.';

  @override
  String get onboarding2Title => 'Delivery in an hour';

  @override
  String get onboarding2Body =>
      'A courier brings your order at a time that suits you, and you can track its status in the app.';

  @override
  String get onboarding3Title => 'Great savings';

  @override
  String get onboarding3Body =>
      'Save your favorites, apply promo codes and check out in a few taps.';

  @override
  String get myOrders => 'My orders';

  @override
  String get ordersSignInRequired => 'Sign in to view your orders';

  @override
  String get ordersLoadFailed =>
      'Could not load your orders. Please try later.';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyBody => 'Once you place an order, it will appear here.';

  @override
  String get startShopping => 'Start shopping';

  @override
  String orderNumberFallback(String id) {
    return 'Order #$id';
  }

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get stepCreated => 'Created';

  @override
  String get stepWithCourier => 'With courier';

  @override
  String get stepDelivered => 'Delivered';

  @override
  String get labelAddress => 'Address';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get deliveryTime => 'Delivery time';

  @override
  String get orderInfoPayment => 'Payment';

  @override
  String get notSpecifiedFem => 'Not specified';

  @override
  String get orderInfoCourier => 'Courier';

  @override
  String get orderInfoCourierPhone => 'Courier phone';

  @override
  String get total => 'Total';

  @override
  String get itemDefaultName => 'Item';

  @override
  String quantityLabel(String quantity) {
    return 'Quantity: $quantity';
  }

  @override
  String get hideOrderFailed => 'Could not hide the order.';

  @override
  String get hideOrder => 'Hide from list';

  @override
  String get orderConfirmedWaiting =>
      'You confirmed receipt. Waiting for the manager.';

  @override
  String get orderConfirmedToast => 'You confirmed that everything is fine!';

  @override
  String get orderConfirmFailed => 'Could not confirm receipt.';

  @override
  String get orderConfirmButton => 'Confirm everything is fine';

  @override
  String get passwordChanged => 'Password changed successfully.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get currentPasswordRequired => 'Enter your current password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordSame =>
      'The new password is the same as the current one';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get newPasswordRepeatLabel => 'Repeat the new password';

  @override
  String get addCardTitle => 'Add card';

  @override
  String get addCardHint => 'Card number (16 digits)';

  @override
  String get cardRemoveFailed => 'Could not remove the card.';

  @override
  String get cardsSignIn => 'Sign in to view your cards';

  @override
  String get cardsEmptyTitle => 'No linked cards';

  @override
  String get cardsEmptyBody => 'Add a bank card to pay for your orders.';

  @override
  String promoApplied(String code, String percent) {
    return 'Promo code $code applied. Discount $percent%.';
  }

  @override
  String get promoCheckFailed =>
      'Could not check the promo code. Please try later.';

  @override
  String get promoRemoved => 'Promo code removed.';

  @override
  String promoCurrentlyApplied(String code, String percent) {
    return 'Promo code $code is applied: $percent% off.';
  }

  @override
  String get promoAvailableTitle => 'Available promo codes';

  @override
  String get promoNoneActive => 'There are no active promo codes yet.';

  @override
  String promoDiscountUntil(String percent, String date) {
    return '$percent% off until $date';
  }

  @override
  String get cartTitle => 'My cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String cartPromoApplied(String code, String percent, String savings) {
    return 'Promo code $code applied: $percent% off. You save $savings';
  }

  @override
  String get summarySubtotal => 'Subtotal';

  @override
  String get summaryDiscount => 'Discount';

  @override
  String get summaryDelivery => 'Delivery';

  @override
  String get free => 'Free';

  @override
  String deliveryFeeWithThreshold(String fee, String threshold) {
    return '$fee (free over $threshold ₽)';
  }

  @override
  String get checkout => 'Checkout';

  @override
  String get productsLoadFailedLater =>
      'Could not load products. Please try later.';

  @override
  String get categoryEmpty => 'There are no products in this category yet';

  @override
  String addedPartial(int count) {
    return 'Added $count — that is all the available stock';
  }

  @override
  String addedQuantityToCart(String name, int count) {
    return '“$name” × $count added to the cart';
  }

  @override
  String stockLeft(int count) {
    return '$count left in stock';
  }

  @override
  String get productDescriptionTitle => 'Product description';

  @override
  String get soldOut => 'Sold out';

  @override
  String addToCartWithPrice(String price) {
    return 'Add to cart · $price ₽';
  }

  @override
  String get factManufacturer => 'Manufacturer';

  @override
  String get factCountry => 'Country of origin';

  @override
  String get factBestBefore => 'Best before';

  @override
  String get factComposition => 'Ingredients';

  @override
  String get productFactsTitle => 'Details';

  @override
  String get nutritionTitle => 'Nutrition per 100 g';

  @override
  String get nutritionCalories => 'Kcal';

  @override
  String get nutritionProteins => 'Protein';

  @override
  String get nutritionFats => 'Fat';

  @override
  String get nutritionCarbs => 'Carbs';

  @override
  String get categoriesLoadFailed => 'Could not load categories.';

  @override
  String get categoriesEmpty => 'No categories have been added yet.';

  @override
  String get searchFailed => 'Search failed. Check your connection.';

  @override
  String get favoritesNothingToAdd => 'No in-stock items to add';

  @override
  String favoritesAdded(int count) {
    return 'Items added to the cart ($count)';
  }

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesLoadFailed => 'Could not load your favorites.';

  @override
  String get favoritesEmpty => 'You have no favorite products yet ❤️';

  @override
  String get addAllToCart => 'Add all to cart';

  @override
  String get shopLocation => 'Moscow, Russia';

  @override
  String get searchHint => 'Search the store';

  @override
  String get productsLoadFailedConnection =>
      'Could not load products. Check your connection.';

  @override
  String get noProductsInDatabase => 'There are no products in the database.';

  @override
  String get nothingFound => 'Nothing found for your search';

  @override
  String get promoBannerTitle => '20% off your first order';

  @override
  String get promoBannerCode => 'Promo code NECTAR20';

  @override
  String get popular => 'Popular';

  @override
  String get seeAll => 'See all';

  @override
  String get splashBrand => 'nectar';

  @override
  String get splashTagline => 'online grocery';

  @override
  String get statusNew => 'New';

  @override
  String get statusProcessing => 'Being packed';

  @override
  String get statusAssigned => 'Handed to courier';

  @override
  String get statusDelivering => 'On the way';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String addedToCart(String name) {
    return '“$name” added to the cart';
  }

  @override
  String noMoreStockNamed(String name) {
    return 'No more in stock: $name';
  }

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get reseedTitle => 'Reload the product database?';

  @override
  String get reseedBody =>
      'All current products will be deleted and replaced with the starter catalog (69 products, 9 categories). This cannot be undone.';

  @override
  String get reseedConfirm => 'Reload';

  @override
  String get reseedLoading => 'Loading products...';

  @override
  String get reseedDone => 'The product database was updated!';

  @override
  String get reseedFailed => 'Could not update the product database.';

  @override
  String get adminHome => 'Home';

  @override
  String get sectionInDevelopment => 'This section is under development';

  @override
  String get adminDashboardTitle => 'Control panel';

  @override
  String get adminNewOrders => 'New orders';

  @override
  String get adminActive => 'Active';

  @override
  String get adminProducts => 'Products';

  @override
  String get adminInCatalog => 'In the catalog';

  @override
  String get adminQuickActions => 'Quick actions';

  @override
  String get adminReseedButton => 'Reload product database (reset)';

  @override
  String get adminReseedHint =>
      'Loads the starter catalog with photos, descriptions, ingredients and nutrition facts.';

  @override
  String get adminOrdersTitle => 'Order management';

  @override
  String get adminNoOrders => 'No orders';

  @override
  String get adminNoName => 'No name';

  @override
  String get adminCourierRequired =>
      'Error: an order cannot be set to “On the way” or “Delivered” until a courier is assigned!';

  @override
  String get adminOrderUpdated => 'Order updated successfully!';

  @override
  String get adminOrderUpdateFailed => 'Could not update the order.';

  @override
  String adminCustomer(String name) {
    return 'Customer: $name';
  }

  @override
  String adminAddress(String address) {
    return 'Address: $address';
  }

  @override
  String adminPhone(String phone) {
    return 'Phone: $phone';
  }

  @override
  String adminDeliverySlot(String slot) {
    return 'Delivery time: $slot';
  }

  @override
  String adminAmount(String amount) {
    return 'Amount: ₽$amount';
  }

  @override
  String get adminCourierLabel => 'Courier:';

  @override
  String get notAssigned => 'Not assigned';

  @override
  String get adminStatusLabel => 'Status:';

  @override
  String get webBlockedTitle => 'Download our app to place orders';

  @override
  String webBlockedBody(String roleName) {
    return 'You are signed in as “$roleName”. This website is only for store administration (administrators).\n\nPlease install Nectar on your phone to shop.';
  }

  @override
  String get landingForCustomers => 'For customers';

  @override
  String get landingAbout => 'About us';

  @override
  String get landingStaffLogin => 'Staff sign-in';

  @override
  String get landingBadge => '🚀 Delivery in 60 minutes';

  @override
  String get landingHeadline => 'Fresh groceries\ndelivered to your door';

  @override
  String get landingBody =>
      'Order your favorite vegetables, fruit, meat and dairy. We carefully select the products and deliver them right to your door.';

  @override
  String get landingDownload => 'Download our app:';

  @override
  String get landingFreshOnly => 'Only\nfresh';

  @override
  String get landingDownloadIn => 'Download on';
}
