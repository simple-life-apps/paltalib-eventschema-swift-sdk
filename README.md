# Palta Brain event schema Swift SDK

This is a Swift SDK to report analytics events to Palta Brain with event schema applied.

## Before integration
You don't integrate this package directly. You use individual package with generated events code for your particular event schema. 
Your individual package is protected from unauthorised access with Basic Auth which is built into package url. You won't need to setup authentication for individual users/devices. You should expect credential changes from time to time. You'll be notified about changes beforehand.
Prior to integration you should obtain required credentials from Palta Brain team:
- API key
- Reporting url
- *(SPM only)* Individual SPM package url
- *(Cocoapods only)* Pod name
- *(Cocoapods only)* Custom pod repo url

## SPM installation
Add provided package url as package dependency. SDK will be added automatically as a dependency. Each time you need to get new event schema version, trigger 'Update package' option in the UI.

## CocoaPods installation
Add provided pod name and spec url to your Podfile. SDK will be added automatically as a dependency. Each time you need to get new event schema version, raise pod version by one.

## Usage
### Setting up SDK
```
import PaltaAnalytics

PaltaAnalytics.shared.setAPIKey(
    "YOUR-API-KEY",
    and: URL(string: "YOUR-HOST-URL")!
)
```

### Reporting event
```
import PaltaAnalytics
import PaltaEvents

PaltaAnalytics.shared.log(
    EdgeCaseEvent(propBoolean: true)
)
```
Note that all event reporting is thread safe. All properties are optional and can be omitted for the sake of backwards compatability. However, developer is expected to fill all properties while implementing event. In case it is not possible, please notify your task reporter.

### Reporting event with event header
```
import PaltaAnalytics
import PaltaEvents

PaltaAnalytics.shared.log(
    EdgeCaseEvent(propBoolean: true)
        .with(EventHeader.EdgeCase(propEnum: .skip))
)
```
Number of applied headers is unlimited, but they should be tied to the event type in event schema.

### Modifiyng context
```
PaltaAnalytics.shared.editContext {
    $0.user.userID = "New user id"
    $0.appsflyer.appsflyerID = nil
}
```
You can do what ever you want in modifier closure, all work is considered atomic and is protected from races with other threads. However, you should avoid time-heavy operations in modifier block because other modifications are locked.
