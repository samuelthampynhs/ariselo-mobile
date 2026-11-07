import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';

/// Who is signed in: a parent, a child, or nobody.
class Session extends ChangeNotifier {
  Session(this.api);

  final Api api;
  Me? me;
  bool loading = true;

  Future<Me?> refresh() async {
    try {
      me = Me.fromJson((await api.get('identity', '/me')) as Map<String, dynamic>);
    } on ApiError {
      me = null;
    } finally {
      loading = false;
      notifyListeners();
    }
    return me;
  }

  Future<void> logout() async {
    try {
      await api.post('identity', '/logout');
    } on ApiError {
      // signed out on the phone either way
    }
    await api.forgetSession();
    me = null;
    notifyListeners();
  }
}
