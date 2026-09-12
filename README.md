# AuthenticationKit

`AuthenticationKit` is a reusable Swift Package for implementing authentication flows in iOS applications.

It provides network-based authentication, session storage and restoration, email verification and email changes, password management, multi-session management, and SwiftUI screens. You can also use `AuthenticationService` directly without adopting the provided UI.

## Features

- Email/password login
- Sign up
- Fetch current user
- Access Token-based authenticated requests
- Refresh Token-based session refresh
- Local session storage and restoration
- Logout
- Account withdrawal
- Forgot password
- Reset password
- Change password while signed in
- Email verification
- Resend verification email
- Request and confirm email changes
- Fetch active sessions
- Revoke a specific session
- Log out all other sessions
- Log out all sessions
- SwiftUI authentication screens
- Authentication UI theme customization
- Custom `AuthenticationRepository` / `TokenStorage` injection

## Requirements

- Swift Package Manager
- An environment that supports Swift Concurrency
- SwiftUI
- `NetworkKit`

The package is generally structured with backward iOS compatibility in mind, but the current `ResetPasswordView` source is declared with `@available(iOS 17.0, *)`. Apps supporting earlier versions can call `AuthenticationService.resetPassword(...)` directly and provide their own reset-password UI.

## Installation

Add the following repository as a Swift Package in Xcode:

```text
https://github.com/iosdevbyul/AuthenticationKit
```

Link the `AuthenticationKit` product to your app target, then import it:

```swift
import AuthenticationKit
```

## Quick Start

### 1. Configure the Base URL

Configure the authentication server base URL before accessing `AuthenticationService.shared`.

```swift
import AuthenticationKit

let baseURL = URL(string: "https://api.example.com")!

AuthenticationConfiguration.shared.configure(
    baseURL: baseURL
)
```

`AuthenticationService.shared` expects the base URL to be configured first, so this should be done during app startup.

### 2. Log In

```swift
let session = try await AuthenticationService.shared.login(
    email: "test@example.com",
    password: "password"
)

print(session.user.email)
print(session.accessToken)
```

After a successful login, the returned `Session` is stored through the internal `SessionManager` and token storage.

### 3. Restore a Session on App Launch

```swift
do {
    try AuthenticationService.shared.restoreSession()

    _ = try await AuthenticationService.shared.currentUser()

    if let session = AuthenticationService.shared.currentSession {
        print("restored:", session.user.email)
    }
} catch {
    // Navigate to the login flow.
}
```

`restoreSession()` restores a locally saved session. To verify that the server-side session is still valid, call an authenticated API such as `currentUser()` after restoration.

## AuthenticationService

`AuthenticationService` is the main public API exposed by AuthenticationKit.

### Session State

```swift
let service = AuthenticationService.shared

service.currentSession
service.isAuthenticated
```

### Login / Sign Up

```swift
let session = try await service.login(
    email: "test@example.com",
    password: "password"
)

let newSession = try await service.signUp(
    email: "new@example.com",
    password: "password"
)
```

### Current User

```swift
let user = try await service.currentUser()
```

`currentUser()` updates the current session with the latest user returned by the server. The service also protects against stale async responses overwriting a newer or replaced session.

### Refresh Session

```swift
let refreshedSession = try await service.refreshSession()
```

Refreshing fails if the current session does not contain a Refresh Token. On success, the refreshed `Session` replaces the stored session.

### Logout

```swift
try await service.logout()
```

The local session is cleared after the server logout succeeds.

### Withdraw

```swift
try await service.withdraw()
```

The local session is cleared after account withdrawal succeeds.

## Password Management

### Forgot Password

```swift
try await service.forgotPassword(
    email: "test@example.com"
)
```

### Reset Password

```swift
try await service.resetPassword(
    token: resetToken,
    newPassword: "new-password"
)
```

A successful password reset clears the local session.

### Change Password

```swift
try await service.changePassword(
    currentPassword: "old-password",
    newPassword: "new-password"
)
```

A successful password change clears the local session, so the user must authenticate again.

## Email Verification

### Verify Email

```swift
try await service.verifyEmail(
    token: verificationToken
)
```

To immediately synchronize `isEmailVerified` for the signed-in user, fetch the current user afterward:

```swift
let user = try await service.currentUser()
```

### Resend Verification Email

```swift
try await service.resendVerificationEmail(
    email: "test@example.com"
)
```

The resend flow trims and lowercases the email address before sending it to the server.

## Email Change

Email changes are handled in two steps.

### 1. Request an Email Change

```swift
try await service.requestEmailChange(
    currentPassword: "password",
    newEmail: "NewEmail@example.com"
)
```

`newEmail` is forwarded without being lowercased by AuthenticationKit.

### 2. Confirm the Email Change

```swift
try await service.confirmEmailChange(
    token: emailChangeToken
)
```

If a signed-in session exists, AuthenticationKit fetches the current user again after confirmation and updates `Session.user`. The existing Access Token and Refresh Token remain unchanged.

## Session Management

AuthenticationKit can list and manage server-side login sessions.

### Session Model

```swift
public struct ManagedSession: Identifiable, Equatable, Sendable {
    public let id: String
    public let createdAt: Date?
    public let startedAt: Date?
    public let expiresAt: Date
    public let lastRefreshedAt: Date?
    public let isCurrent: Bool
    public let deviceName: String?
}
```

### Get Sessions

```swift
let sessions = try await service.sessions()

let current = sessions.first {
    $0.isCurrent
}
```

### Revoke One Session

```swift
let sessions = try await service.sessions()

if let target = sessions.first {
    try await service.revokeSession(target)
}
```

If `target.isCurrent == true`, AuthenticationKit clears the local session after the server successfully revokes that session.

### Logout Other Sessions

```swift
try await service.logoutOtherSessions()
```

The current session remains active while all other sessions are revoked.

### Logout All Sessions

```swift
try await service.logoutAllSessions()
```

All server-side sessions, including the current one, are revoked, and the local session is cleared.

## SwiftUI Views

AuthenticationKit provides SwiftUI Views and ViewModels for the main authentication flows.

| Feature | View | ViewModel |
| --- | --- | --- |
| Login | `LoginView` | `LoginViewModel` |
| Sign Up | `SignUpView` | `SignUpViewModel` |
| Forgot Password | `ForgotPasswordView` | `ForgotPasswordViewModel` |
| Reset Password | `ResetPasswordView` | `ResetPasswordViewModel` |
| Change Password | `ChangePasswordView` | `ChangePasswordViewModel` |
| Email Verification | `EmailVerificationView` | `EmailVerificationViewModel` |
| Email Change | `EmailChangeView` | `EmailChangeViewModel` |
| Session Management | `SessionManagementView` | `SessionManagementViewModel` |

### LoginView

```swift
LoginView(
    onLoginSuccess: { session in
        // Authentication completed.
    },
    onSignUp: {
        // Navigate to sign up.
    },
    onForgotPassword: {
        // Navigate to forgot password.
    }
)
```

### SignUpView

```swift
SignUpView { session in
    // Handle the authenticated session.
}
```

### ForgotPasswordView

```swift
ForgotPasswordView {
    // Handle completion.
}
```

### ChangePasswordView

```swift
ChangePasswordView {
    // AuthenticationKit has already cleared the local session.
    // Navigate back to the login flow.
}
```

### EmailVerificationView

Create and inject the ViewModel from the host app:

```swift
@StateObject private var viewModel = EmailVerificationViewModel(
    email: "test@example.com"
)

var body: some View {
    EmailVerificationView(
        viewModel: viewModel
    )
}
```

To open the verification screen with a token:

```swift
let viewModel = EmailVerificationViewModel(
    token: verificationToken
)

EmailVerificationView(
    viewModel: viewModel
)
```

### EmailChangeView

```swift
@StateObject private var viewModel = EmailChangeViewModel()

var body: some View {
    EmailChangeView(
        viewModel: viewModel
    )
}
```

To open the screen with a confirmation token:

```swift
let viewModel = EmailChangeViewModel(
    token: emailChangeToken
)
```

### SessionManagementView

```swift
SessionManagementView(
    onCurrentSessionRevoked: {
        // Navigate to the login flow.
    },
    onAllSessionsLoggedOut: {
        // Navigate to the login flow.
    }
)
```

Revoking another session or calling `logoutOtherSessions()` keeps the current app session active.

## Deep Links

AuthenticationKit provides parsers for email verification and email-change links.

### Email Verification

Default scheme:

```text
waktrainer://verify-email?token=TOKEN
```

```swift
.onOpenURL { url in
    guard let link = EmailVerificationLink(url: url) else {
        return
    }

    let token = link.token
}
```

A custom scheme can also be supplied:

```swift
let link = EmailVerificationLink(
    url: url,
    scheme: "myapp"
)
```

### Email Change

Default scheme:

```text
waktrainer://change-email?token=TOKEN
```

```swift
.onOpenURL { url in
    guard let link = EmailChangeLink(url: url) else {
        return
    }

    let token = link.token
}
```

Custom scheme:

```swift
let link = EmailChangeLink(
    url: url,
    scheme: "myapp"
)
```

`EmailVerificationLink` and `EmailChangeLink` reject unexpected hosts, paths, user info, ports, and missing or duplicate token parameters.

## Theme Customization

The main authentication screens accept an `AuthenticationTheme`.

```swift
let theme = AuthenticationTheme(
    background: .black,
    primary: .green,
    text: .white,
    secondaryText: .gray,
    placeholder: .gray,
    border: .gray,
    error: .red,
    link: .green,
    button: .init(
        background: .green,
        foreground: .black,
        disabled: .gray
    ),
    textField: .init(
        background: .white.opacity(0.1),
        text: .white,
        placeholder: .gray,
        border: .gray,
        focusedBorder: .green
    )
)

LoginView(
    theme: theme,
    onLoginSuccess: { session in
        // ...
    }
)
```

The default theme is available as:

```swift
AuthenticationTheme.default
```

## Token Storage

### Shared Service

`AuthenticationService.shared` uses the package's default storage internally.

```swift
AuthenticationConfiguration.shared.configure(
    baseURL: baseURL
)

let service = AuthenticationService.shared
```

### Explicit Service

You can inject a storage implementation through the public initializer.

```swift
let storage = UserDefaultsTokenStorage()

let service = AuthenticationService(
    baseURL: baseURL,
    tokenStorage: storage
)
```

For in-memory storage:

```swift
let service = AuthenticationService(
    baseURL: baseURL,
    tokenStorage: InMemoryTokenStorage()
)
```

You can also provide your own storage implementation:

```swift
final class CustomTokenStorage: TokenStorage, @unchecked Sendable {
    func save(session: Session) throws {
        // Store in Keychain or another secure storage.
    }

    func loadSession() throws -> Session? {
        // Return the stored Session.
        nil
    }

    func clear() throws {
        // Remove stored authentication data.
    }
}
```

For production apps with stricter security requirements, inject a storage implementation that matches your token-storage policy.

## Custom Repository / Dependency Injection

If your authentication server has a different API or you want to replace the networking layer, implement `AuthenticationRepository` directly.

```swift
final class CustomAuthenticationRepository: AuthenticationRepository {
    // Implement the AuthenticationRepository APIs required by your app.
}
```

Then inject it into the service:

```swift
let service = AuthenticationService(
    repository: repository,
    tokenStorage: storage
)
```

Some newer repository APIs provide default `unsupportedOperation` implementations through the `AuthenticationRepository` extension to preserve source compatibility with existing custom repositories.

## Server API Contract

The default `NetworkAuthenticationRepository` uses the following endpoints.

| Method | Path | Description |
| --- | --- | --- |
| POST | `/auth/login` | Log in |
| POST | `/auth/signup` | Sign up |
| GET | `/auth/me` | Fetch current user |
| POST | `/auth/refresh` | Refresh session |
| POST | `/auth/logout` | Log out current session |
| DELETE | `/auth/withdraw` | Withdraw account |
| POST | `/auth/forgot-password` | Request password-reset email |
| POST | `/auth/reset-password` | Reset password |
| POST | `/auth/change-password` | Change password while signed in |
| POST | `/auth/verify-email` | Verify email |
| POST | `/auth/resend-verification-email` | Resend verification email |
| POST | `/auth/request-email-change` | Request email change |
| POST | `/auth/confirm-email-change` | Confirm email change |
| GET | `/auth/sessions` | Fetch active sessions |
| DELETE | `/auth/sessions/:id` | Revoke a specific session |
| POST | `/auth/logout-other-sessions` | Revoke all other sessions |
| POST | `/auth/logout-all` | Revoke all sessions |

`AuthenticationService(baseURL:tokenStorage:)` wires `NetworkKit`'s `AuthorizationRequestInterceptor` to `SessionManager` so authenticated requests can use the current Access Token.

## Models

### User

```swift
public struct User: Equatable, Codable, Sendable {
    public let id: String
    public let email: String
    public let isEmailVerified: Bool
}
```

### Session

```swift
public struct Session: Equatable, Codable, Sendable {
    public let user: User
    public let accessToken: String
    public let refreshToken: String?
}
```

### ManagedSession

`ManagedSession` represents a login session managed by the server.

```swift
public struct ManagedSession: Identifiable, Equatable, Sendable {
    public let id: String
    public let createdAt: Date?
    public let startedAt: Date?
    public let expiresAt: Date
    public let lastRefreshedAt: Date?
    public let isCurrent: Bool
    public let deviceName: String?
}
```

## Architecture

AuthenticationKit is organized into the following layers:

```text
AuthenticationKit
├── Configuration
├── Data
│   ├── DTOs
│   ├── Endpoints
│   ├── Network
│   ├── Repositories
│   └── Storage
├── Domain
│   ├── Authentication
│   ├── Entities
│   ├── Models
│   ├── Repositories
│   ├── Service
│   ├── Session
│   └── UseCases
└── Presentation
    ├── Components
    ├── Login
    ├── SignUp
    ├── ForgotPassword
    ├── ResetPassword
    ├── ChangePassword
    ├── EmailVerification
    ├── EmailChange
    ├── SessionManagement
    ├── Error
    └── Theme
```

The default flow is:

```text
SwiftUI View
    ↓
ViewModel
    ↓
AuthenticationService / UseCase
    ↓
AuthenticationRepository
    ↓
NetworkKit
    ↓
Authentication Server
```

`SessionManager` owns the current session state and keeps it synchronized with Token Storage.

## Session Invalidation Policy

AuthenticationKit keeps local session state aligned with the server-side authentication behavior.

| Operation | Local Session |
| --- | --- |
| Login | Stored |
| Sign Up | Stored |
| Refresh | Replaced with refreshed `Session` |
| Logout | Cleared |
| Withdraw | Cleared |
| Change Password | Cleared |
| Reset Password | Cleared |
| Confirm Email Change | Kept, `User` refreshed |
| Revoke Other Session | Kept |
| Revoke Current Session | Cleared |
| Logout Other Sessions | Kept |
| Logout All Sessions | Cleared |

## Error Handling

Presentation-layer ViewModels use `AuthenticationErrorMessageMapper` to convert `AuthenticationError`, `NetworkError`, and `URLError` values into user-facing messages.

When using `AuthenticationService` directly, errors are propagated through `throws` and can be handled by the host application.

```swift
do {
    try await AuthenticationService.shared.logoutOtherSessions()
} catch {
    // Handle the error according to your app's policy.
}
```

## Testing

AuthenticationKit supports dependency injection for repositories and token storage so each layer can be tested independently.

Example test setup:

```swift
let repository = MockAuthenticationRepository()
let storage = InMemoryTokenStorage()

let service = AuthenticationService(
    repository: repository,
    tokenStorage: storage
)
```

The current test structure covers Repository, UseCase, Service, and Presentation/ViewModel behavior, including session persistence and invalidation policies.

## Notes

- Call `AuthenticationConfiguration.shared.configure(baseURL:)` before using `AuthenticationService.shared`.
- Successful login, sign up, and refresh operations persist the current `Session` to Token Storage.
- Successful logout, withdrawal, password change, password reset, current-session revocation, and logout-all operations clear the local `Session`.
- Confirming an email change preserves the current tokens and refreshes only the `User` stored in the current session.
- `EmailVerificationLink` and `EmailChangeLink` use `waktrainer` as the default URL scheme, but the scheme can be customized through their initializers.
- `ResetPasswordView` is currently available on iOS 17 and later.
