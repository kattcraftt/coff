/// Feature switches for things the design shows but the backend lacks.
abstract final class Features {
  /// Google / GitHub buttons exist in the design, but there are no OAuth
  /// endpoints yet: tapping them only shows "coming soon". Set to false to hide
  /// them until sign-in with Google/GitHub is implemented.
  static const socialLogin = true;
}
