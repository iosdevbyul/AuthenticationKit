# AuthenticationKit

## Email verification

Unverified accounts keep the existing signup/login/refresh session flow.
User.isEmailVerified is decoded in session and current-user responses. Older persisted
sessions without this field decode as false.

    try await authenticationService.verifyEmail(token: token)
    try await authenticationService.resendVerificationEmail(email: email)
    let user = try await authenticationService.currentUser()

Resend trims and lowercases the email. Success never indicates whether the account exists,
is already verified, or was throttled. The reusable EmailVerificationView displays a fixed
neutral message and uses AuthenticationErrorMessageMapper for errors.

The host owns an EmailVerificationViewModel and passes it to
EmailVerificationView(viewModel:theme:), following the existing observed-view-model pattern.
The view uses iOS 13 APIs. verifyEmail() on the view model verifies the link and separately
refreshes the signed-in user's state. A failed profile refresh can be retried with refreshUser()
without retrying the already-consumed token. Verification while signed out does not create a session.

currentUser() updates the matching persisted session's user while preserving access/refresh
tokens. A stale response cannot restore a logged-out session or overwrite a different session.
A verification token for another account does not mark the signed-in user as verified.

The Demo keeps Login/Sign Up/Forgot Password and Home/Settings/Account Management.
Unverified accounts see a status in Home and a verification entry in Settings.
The Demo registers waktrainer://verify-email?token=..., queues cold-launch links until
session restoration finishes, then calls verification from the existing SwiftUI flow.
EmailVerificationLink(url:) is also reusable from an application's own URL handler.
Malformed, empty, duplicate-token and unrelated links are rejected.

WakTrainerServer requires an HTTPS EMAIL_VERIFICATION_URL_BASE. A hosted verification
page must hand off to the custom app URL (preserving the token), or a real app must configure
Universal Links for its own domain. This Demo does not configure an external hosting domain
or associated-domain entitlement. No routing framework is required.

Custom AuthenticationRepository implementations can implement the two new methods;
the default implementations throw unsupportedOperation to preserve source compatibility.

### Testing email verification

Use the AuthenticationKit Xcode scheme on an available iOS Simulator to run all package
tests. Plain macOS swift test currently fails in the existing NetworkKit dependency because
its manifest does not declare the required macOS API availability.

    xcodebuild -scheme AuthenticationKit -destination 'platform=iOS Simulator,name=iPhone 17' test
    xcodebuild -scheme AuthenticationKit -destination 'generic/platform=iOS Simulator' IPHONEOS_DEPLOYMENT_TARGET=13.0 build

The Demo retains its existing iOS 17 target. The library retains iOS 13.
