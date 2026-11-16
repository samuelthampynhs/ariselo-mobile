import 'dart:convert';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Gives the /tabs web page a voice inside the app.
///
/// The grown-ups' avatars speak with the browser's speech (window.speechSynthesis), and move their
/// lips from its word timings. Android's WebView has no speech at all, and iOS's varies, so the app
/// puts its own in its place: the page's speechSynthesis and SpeechSynthesisUtterance are replaced
/// by a small stand-in that hands each sentence to the tablet's own text-to-speech, and sends the
/// start, word and end events back. The page doesn't know the difference.
class SpeechBridge {
  SpeechBridge(this.web, {FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  static const channel = 'AriseloSpeech';

  final WebViewController web;
  final FlutterTts _tts;
  String? _current;

  /// Adds the channel the page talks to. Call before the page loads.
  Future<void> attach() async {
    await web.addJavaScriptChannel(channel, onMessageReceived: (m) => handle(m.message));
    await _tts.setLanguage('en-GB');
    await _tts.awaitSpeakCompletion(false);
    _tts.setStartHandler(() => _send('start', 0));
    _tts.setProgressHandler((text, start, end, word) => _send('boundary', start));
    _tts.setCompletionHandler(() => _finish('end'));
    _tts.setCancelHandler(() => _finish('end'));
    _tts.setErrorHandler((_) => _finish('error'));
  }

  /// Puts the stand-in into the page. Safe to call on every page load.
  Future<void> install() => web.runJavaScript(polyfill);

  /// A message from the page: {"op": "speak", "id", "text", "pitch", "rate"} or {"op": "cancel"}.
  Future<void> handle(String message) async {
    final Map<String, dynamic> m;
    try {
      m = jsonDecode(message) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (m['op'] == 'cancel') {
      await _stop();
    } else if (m['op'] == 'speak') {
      await _stop();
      final text = (m['text'] as String? ?? '').trim();
      final id = '${m['id']}';
      if (text.isEmpty) {
        _current = id;
        _finish('end');
        return;
      }
      _current = id;
      await _tts.setPitch(((m['pitch'] as num?) ?? 1).toDouble().clamp(0.5, 2.0));
      // the web's rate is 1 for normal speech; flutter_tts's is 0.5 on both platforms
      await _tts.setSpeechRate((((m['rate'] as num?) ?? 1).toDouble() * 0.5).clamp(0.2, 0.9));
      await _tts.speak(text);
    }
  }

  Future<void> _stop() async {
    if (_current == null) return;
    await _tts.stop();
    _finish('end'); // the page waits for "end" before the next sentence
  }

  void _finish(String type) {
    final id = _current;
    if (id == null) return;
    _current = null;
    _call(id, type, 0);
  }

  void _send(String type, int charIndex) {
    final id = _current;
    if (id != null) _call(id, type, charIndex);
  }

  void _call(String id, String type, int charIndex) {
    web.runJavaScript(
      'window.__ariseloSpeech && window.__ariseloSpeech.event(${jsonEncode(id)}, ${jsonEncode(type)}, $charIndex)',
    );
  }

  Future<void> dispose() => _tts.stop();

  /// The page side of the bridge.
  static const polyfill = r'''
(function () {
  if (window.__ariseloSpeech) return;
  var waiting = {}, n = 0;
  function Utterance(text) {
    this.text = text || ''; this.lang = 'en-GB'; this.pitch = 1; this.rate = 1; this.volume = 1; this.voice = null;
    this.onstart = null; this.onend = null; this.onerror = null; this.onboundary = null;
  }
  var synth = {
    speaking: false, pending: false, paused: false, onvoiceschanged: null,
    speak: function (u) {
      var id = String(++n);
      waiting[id] = u; synth.speaking = true;
      AriseloSpeech.postMessage(JSON.stringify({ op: 'speak', id: id, text: u.text, pitch: u.pitch, rate: u.rate }));
    },
    cancel: function () { AriseloSpeech.postMessage(JSON.stringify({ op: 'cancel' })); },
    getVoices: function () { return []; },
    pause: function () {}, resume: function () {},
    addEventListener: function () {}, removeEventListener: function () {}
  };
  window.__ariseloSpeech = {
    event: function (id, type, charIndex) {
      var u = waiting[id];
      if (!u) return;
      if (type === 'end' || type === 'error') { delete waiting[id]; synth.speaking = Object.keys(waiting).length > 0; }
      var h = u['on' + type];
      if (h) { try { h({ charIndex: charIndex || 0, name: 'word', utterance: u }); } catch (e) {} }
    }
  };
  try { Object.defineProperty(window, 'speechSynthesis', { value: synth, configurable: true }); }
  catch (e) { window.speechSynthesis = synth; }
  window.SpeechSynthesisUtterance = Utterance;
})();
''';
}
