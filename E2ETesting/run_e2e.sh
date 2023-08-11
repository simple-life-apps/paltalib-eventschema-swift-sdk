pod install
xcodebuild -workspace SendEvents.xcworkspace  -scheme SendEvents -sdk iphonesimulator16.2 -destination 'platform=iOS Simulator,name=iPhone 14 Pro Max,OS=16.2' -derivedDataPath Output -resultBundlePath Output/Results test | xcpretty && xcode_exit=${PIPESTATUS[0]}

if [ $xcode_exit != 0 ]; then
  exit $xcode_exit
fi

xcparse attachments Output/Results Output/Attachments --uti public.plain-text

event_times=$(cat $(find Output/Attachments -type f -name 'times_*' -print -quit))
event_names=$(cat $(find Output/Attachments -type f -name 'names_*' -print -quit))
event_properties=$(cat $(find Output/Attachments -type f -name 'event-properties_*' -print -quit))
header_properties=$(cat $(find Output/Attachments -type f -name 'header-properties_*' -print -quit))
context_properties=$(cat $(find Output/Attachments -type f -name 'context-properties_*' -print -quit))

rm -rf Output

echo "event_times=$event_times" >> "$GITHUB_OUTPUT"
echo "event_names=$event_names" >> "$GITHUB_OUTPUT"
echo "event_properties=$event_properties" >> "$GITHUB_OUTPUT"
echo "header_properties=$header_properties" >> "$GITHUB_OUTPUT"
echo "context_properties=$context_properties" >> "$GITHUB_OUTPUT"
