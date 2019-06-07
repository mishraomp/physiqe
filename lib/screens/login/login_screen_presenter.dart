import 'package:physique_gym/data/rest_ds.dart';
import 'package:physique_gym/models/user.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(User user);
  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  RestDatasource api = new RestDatasource();
  LoginScreenPresenter(this._view);

  doLogin(String username, String password) {
    if(username=='omprakashmishra3978') {
      User user = new User(username, password);
      _view.onLoginSuccess(user);
    }else {
      _view.onLoginError('invalid user name or password');
    }
  }
}