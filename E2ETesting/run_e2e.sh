pod install
xcodebuild -workspace SendEvents.xcworkspace  -scheme SendEvents -sdk iphonesimulator16.2 -destination 'platform=iOS Simulator,name=iPhone 14 Pro Max,OS=16.2' -derivedDataPath Output -resultBundlePath Output/Results test
xcparse attachments Output/Results Output/Attachments --uti public.plain-text

export event_times=$(cat $(find Output/Attachments -type f -name 'times_*' -print -quit))
export event_names=$(cat $(find Output/Attachments -type f -name 'names_*' -print -quit))
export event_properties=$(cat $(find Output/Attachments -type f -name 'event-properties_*' -print -quit))
export header_properties=$(cat $(find Output/Attachments -type f -name 'header-properties_*' -print -quit))
export context_properties=$(cat $(find Output/Attachments -type f -name 'context-properties_*' -print -quit))

rm -rf Output
