
/// LIST OF Enums
/// They cannot be created inside a class.
library;

enum TextSizes { small, medium, large }

/// QR Code scan result status
enum QRScanStatus {
  success,
  invalid,
  expired,
  error;

  String get displayName {
    switch (this) {
      case QRScanStatus.success:
        return 'Success';
      case QRScanStatus.invalid:
        return 'Invalid QR Code';
      case QRScanStatus.expired:
        return 'QR Code Expired';
      case QRScanStatus.error:
        return 'Scan Error';
    }
  }
}

/// User search method
enum UserSearchMethod {
  username,
  qrCode;

  String get displayName {
    switch (this) {
      case UserSearchMethod.username:
        return 'Username';
      case UserSearchMethod.qrCode:
        return 'QR Code';
    }
  }
}

/// Recycling activity status
enum ActivityStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ActivityStatus.pending:
        return 'Pending Review';
      case ActivityStatus.approved:
        return 'Approved';
      case ActivityStatus.rejected:
        return 'Rejected';
    }
  }

  String get colorKey {
    switch (this) {
      case ActivityStatus.pending:
        return 'warning';
      case ActivityStatus.approved:
        return 'success';
      case ActivityStatus.rejected:
        return 'error';
    }
  }
}