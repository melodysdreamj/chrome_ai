[![pub package](https://img.shields.io/pub/v/chrome_ai.svg)](https://pub.dartlang.org/packages/chrome_ai)
[![GitHub](https://img.shields.io/github/stars/melodysdreamj/chrome_ai.svg?style=social&label=Star)](https://github.com/melodysdreamj/chrome_ai)

# ChromeAI
Recently, Chrome has added window.ai — a Gemini Nano AI model right inside your browser.  This means that web developers can instantly and unlimitedly use on-device AI without any configuration. 

I believe this will truly transform web applications. The use-cases are endless: smart auto-completion, error correction and validation, natural language filtering, auto-filling forms, UI suggestions, first-pass summarization, and search.

Accordingly, I have developed a library to enable this feature in Flutter. With this library, you can easily utilize the feature in Flutter web as well.


## Installation
you can watch this [video](https://www.youtube.com/watch?v=IUhVGdGxYcQ) to see how to enable AI in Chrome and run this library.

### 1. Enable AI in Chrome

Chrome built-in AI is a preview feature, you need to use chrome version 127 or greater, now in [dev](https://www.google.com/chrome/dev/?extra=devchannel) or [canary](https://www.google.com/chrome/canary/) channel, [may release on stable chanel at Jul 17, 2024](https://chromestatus.com/roadmap).

After then, you should turn on these flags:
* [chrome://flags/#prompt-api-for-gemini-nano](chrome://flags/#prompt-api-for-gemini-nano): `Enabled`
* [chrome://flags/#optimization-guide-on-device-model](chrome://flags/#optimization-guide-on-device-model): `Enabled BypassPrefRequirement`
* [chrome://components/](chrome://components/): Click `Optimization Guide On Device Model` to download the model.

### 2. Add library
```bash
flutter pub add chrome_ai
```

### 3. Run your project
##### 1. Open terminal and run web-server
```bash
flutter run -d web-server
```
##### 2. Open Chrome [dev](https://www.google.com/chrome/dev/?extra=devchannel) or [canary](https://www.google.com/chrome/canary/), and open your project in `http://localhost:port`


## Usage
### Check Availability of Chrome AI
```dart
import 'package:chrome_ai/chrome_ai.dart';

final availability = await ChromeAI.canCreateTextSession();
if(availability == AIModelAvailability.no){
    // can not create text session
}else if(availability == AIModelAvailability.afterDownload) {
    // need to download model
}else if(availability == AIModelAvailability.readily){
    // model is ready
}
```

### Generate Text
```dart
import 'package:chrome_ai/chrome_ai.dart';

final session = await ChromeAI.createTextSession();
var result = await session.prompt("why is the sky blue?");
print(result);  
```

### Generate Streaming Text
```dart
import 'package:chrome_ai/chrome_ai.dart';

final session = await ChromeAI.createTextSession();
final stream = session.promptStreaming("why is the sky blue?");

stream.listen((result) {
  print(result);
}).onError((e, stackTrace) {
  print(e.toString());
});
```

## Need Help!
This project is very new. If you have any questions, please open an issue. Contributions are very welcome.