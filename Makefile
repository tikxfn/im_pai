
BUILDNAME=2.0.0
MID=1
apk-online:
	GIT_HASH=$$(git rev-parse HEAD); \
	echo "const String gitHash = '$$GIT_HASH';" > lib/git_hash.dart
	flutter pub get
	flutter build apk --release --obfuscate --split-debug-info=./build/debug/info --build-name=$(BUILDNAME) --build-number=1 --dart-define=API_ENV=online --dart-define=MID=$(MID)
apk-dev:
	flutter pub get
	flutter build apk --release --obfuscate --split-debug-info=./build/debug/info --build-name=$(BUILDNAME) --build-number=1 --dart-define=MID=$(MID)
ipa-dev:
	flutter pub get
	flutter build ipa --release --obfuscate --split-debug-info=./build/debug/info --build-name=$(BUILDNAME) --build-number=1 --dart-define=API_ENV=dev --dart-define=MID=$(MID)
ipa-online:
	flutter pub get
	flutter build ipa --release --obfuscate --split-debug-info=./build/debug/info --build-name=$(BUILDNAME) --build-number=1 --dart-define=API_ENV=online --dart-define=MID=$(MID)
appbundle-online:
	flutter pub get
	flutter build appbundle --release --obfuscate --split-debug-info=./build/debug/info --build-name=$(BUILDNAME) --build-number=1 --dart-define=API_ENV=online --dart-define=MID=$(MID)
win:
	flutter pub get
	flutter build windows --release --obfuscate --split-debug-info=./build/debug/info --build-name=$(BUILDNAME) --build-number=1 --dart-define=API_ENV=online --dart-define=APP_TYPE=IM --dart-define=MID=$(MID)
sign:
	jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
		-keystore \
		android/app/im-keystore.jks \
		Verify_no_sign.apk \
		im
keystore-SHA1:
	keytool -list -v -keystore android/app/im-keystore.jks