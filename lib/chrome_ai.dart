library chrome_ai;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'dart:async';

@JS('window.ai')
external JsAI? get jsAI;

@JS()
@anonymous
class JsAI {
  external dynamic canCreateTextSession();

  external dynamic createTextSession([JsAITextSessionOptions? options]);

  external Function get ontextmodeldownloadprogress;

  external dynamic textModelInfo();
}

@JS()
@anonymous
class JsAITextSession {
  external factory JsAITextSession();

  external dynamic prompt(String input);

  external dynamic promptStreaming(String input);

  external dynamic clone();

  external void destroy();

  external int get topK;

  external double get temperature;
}

@JS()
@anonymous
class JsAITextSessionOptions {
  external factory JsAITextSessionOptions({
    int? topK,
    double? temperature,
    String? systemPrompt,
    List<JsAIPrompt>? initialPrompts,
  });

  external int? get topK;

  external double? get temperature;

  external String? get systemPrompt;

  external List<JsAIPrompt>? get initialPrompts;
}

@JS()
@anonymous
class JsAIPrompt {
  external factory JsAIPrompt({
    String role,
    String content,
  });

  external String get role;

  external String get content;
}

@JS()
@anonymous
class JsAITextModelInfo {
  external factory JsAITextModelInfo();

  external int get defaultTopK;

  external int get maxTopK;

  external double get defaultTemperature;
}

enum AIModelAvailability { readily, afterDownload, no }

class ChromeAI {
  static Future<AIModelAvailability> canCreateTextSession() async {
    try {
    _checkAIAvailability();

      final promise = jsAI!.canCreateTextSession();
      final result = await promiseToFuture(promise);
      return _parseAIModelAvailability(result);
    } catch (e) {
      // throw Exception('Failed to check model availability: $e');
      return AIModelAvailability.no;
    }
  }

  static AIModelAvailability _parseAIModelAvailability(String value) {
    switch (value) {
      case 'readily':
        return AIModelAvailability.readily;
      case 'after-download':
        return AIModelAvailability.afterDownload;
      case 'no':
        return AIModelAvailability.no;
      default:
        throw Exception('Unknown AIModelAvailability value: $value');
    }
  }

  static Future<AITextSession> createTextSession(
      [AITextSessionOptions? options]) async {
    _checkAIAvailability();
    try {
      final jsOptions = options != null
          ? JsAITextSessionOptions(
        topK: options.topK,
        temperature: options.temperature,
        systemPrompt: options.systemPrompt,
        initialPrompts: options.initialPrompts
            ?.map((p) => JsAIPrompt(
          role: p.role.toString().split('.').last,
          content: p.content,
        ))
            .toList(),
      )
          : null;
      final promise = jsAI!.createTextSession(jsOptions);
      final result = await promiseToFuture(promise);
      return AITextSession._fromJsObject(result);
    } catch (e) {
      throw Exception('Failed to create text session: $e');
    }
  }

  static Future<AITextModelInfo> textModelInfo() async {
    _checkAIAvailability();
    try {
      final promise = jsAI!.textModelInfo();
      final result = await promiseToFuture(promise);
      return AITextModelInfo(
        defaultTopK: result.defaultTopK,
        maxTopK: result.maxTopK,
        defaultTemperature: result.defaultTemperature,
      );
    } catch (e) {
      throw Exception('Failed to get model info: $e');
    }
  }

  static void _checkAIAvailability() {
    if (jsAI == null) {
      throw Exception('AI functionality is not available in this browser.');
    }
  }
}

class AITextSession {
  final JsAITextSession _jsObject;

  AITextSession._fromJsObject(this._jsObject);

  Future<String> prompt(String input) async {
    try {
      final promise = _jsObject.prompt(input);
      return await promiseToFuture(promise);
    } catch (e) {
      throw Exception('Failed to prompt: $e');
    }
  }

  Stream<String> promptStreaming(String input) {
    try {
      final stream = _jsObject.promptStreaming(input);
      print('Starting promptStreaming for input: $input'); // 로그 추가
      return _convertReadableStreamToDartStream(stream);
      // return null;
    } catch (e) {
      print('Error starting promptStreaming: $e');
      throw Exception('Failed to prompt streaming: $e');
    }
  }


  int get topK => _jsObject.topK;

  double get temperature => _jsObject.temperature;

  Future<AITextSession> clone() async {
    try {
      final promise = _jsObject.clone();
      final result = await promiseToFuture(promise);
      return AITextSession._fromJsObject(result);
    } catch (e) {
      throw Exception('Failed to clone session: $e');
    }
  }

  void destroy() {
    _jsObject.destroy();
  }

  Stream<String> _convertReadableStreamToDartStream(dynamic readableStream) {
    final controller = StreamController<String>();
    final reader = readableStream.getReader();

    void read() {
      promiseToFuture(reader.read()).then((result) {
        final done = getProperty(result, 'done');
        final value = getProperty(result, 'value');
        print('Stream read result - done: $done, value: $value'); // 로그 추가
        if (!done) {
          if(value is String) {
            controller.add(value);
          }
          read();
        } else {
          if (!controller.isClosed) {
            controller.close();
          }
        }
      }).catchError((error) {
        print('Error occurred while reading stream: $error'); // 에러 로그 추가
        if (!controller.isClosed) {
          controller.addError('Error occurred: $error');
          controller.close();
        }
      });
    }

    read();
    return controller.stream;
  }
}

class AITextSessionOptions {
  final int? topK;
  final double? temperature;
  final String? systemPrompt;
  final List<AIPrompt>? initialPrompts;

  AITextSessionOptions(
      {this.topK, this.temperature, this.systemPrompt, this.initialPrompts});
}

class AIPrompt {
  final AIPromptRole role;
  final String content;

  AIPrompt({required this.role, required this.content});
}

enum AIPromptRole { system, user, assistant }

class AITextModelInfo {
  final int defaultTopK;
  final int maxTopK;
  final double defaultTemperature;

  AITextModelInfo({
    required this.defaultTopK,
    required this.maxTopK,
    required this.defaultTemperature,
  });
}
