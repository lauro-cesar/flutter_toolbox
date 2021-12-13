import 'package:flutter_toolbox/notifiers/generic_map_notifier.dart';

class DjangoAuthState extends GenericMapNotifier {


  DjangoAuthState({required this.keyName, required this.baseUrl}) : super(keyName: keyName) {
    reloadMap().then((_) => {
      onInit().then((_) {
        _isReady = true;
        notifyListeners();
      })
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onInit() async {
    if (instanceMap['token'] != null) {
      onAdd({'activeRoute': 'app_wall'});
    } else {
      onAdd({'activeRoute': 'login_wall'});
    }
  }


  // Future<void> requestPassWordRecover(String email) async {
  //   Map<String, dynamic> responseData = {};
  //   Map<String, String> requestBody = {"email": email};
  //   Uri url = Uri.parse("${AppConstants.baseUrl}/${AppConstants.recoverpath}");
  //   final requestcsrfToken = await AppCallables.requestGet(url, AppConstants.sessionHeaders);
  //   if (requestcsrfToken.statusCode == 200) {
  //     responseData.addAll(jsonDecode(requestcsrfToken.body));
  //     requestBody.addAll({'csrfmiddlewaretoken': responseData['csrftoken']});
  //     Map<String, String> signinHeaders = {
  //       "Content-Type": "application/x-www-form-urlencoded",
  //       'X-CSRFToken': responseData['csrftoken'],
  //       'referer': "$url",
  //       'Cookie': Cookie.fromSetCookieValue(requestcsrfToken.headers['set-cookie'].toString()).toString()
  //     };
  //     await AppCallables.submitForm(url, requestBody, signinHeaders);
  //   }
  // }

  // Future<void> resetPassword(String email) async {
  //   await AppCallables.requestPassWordRecover(email);
  //   _alertMessage = "Enviamos um email para você reiniciar sua senha.";
  //   _showAlert = true;
  //   notifyListeners();
  // }

  Future<void> resetErros() async {
    _showAlert = false;
    _showPasswordResetButton = false;
    notifyListeners();
  }

  // Future<void> signIn(String email, String password, String nomeCompleto) async {
  //   onAdd({"email": email});
  //
  //   onSave();
  //   Map<String, dynamic> responseData = await AppCallables.createNewAccount(email, password, nomeCompleto);
  //   if (responseData['statusCode'] == 201) {
  //     onAdd(responseData);
  //     onAdd({'activeRoute': 'app_wall'});
  //     onSave();
  //     notifyListeners();
  //   } else if (responseData['statusCode'] == 400) {
  //     if (responseData['message_code'] == "existe") {
  //       _showPasswordResetButton = true;
  //       _alertMessage =
  //       "Não foi possivel criar sua conta!\nemail informado já existe!\nTente novamente ou clique em recuperar senha.";
  //       _showAlert = true;
  //       notifyListeners();
  //     } else {
  //       _showPasswordResetButton = true;
  //       _alertMessage = "Não foi possivel criar sua conta  com os dados informados";
  //       _showAlert = true;
  //       notifyListeners();
  //     }
  //   } else {
  //     _showPasswordResetButton = true;
  //     _alertMessage = "Não foi possivel criar sua conta  com os dados informados";
  //     _showAlert = true;
  //     notifyListeners();
  //   }
  // }
  // Future<void> logIn(String email, String password) async {
  //   onAdd({"email": email});
  //   onSave();
  //   Map<String, dynamic> responseData = await AppCallables.requestAuthToken(email, password);
  //
  //   if (responseData['statusCode'] == 200) {
  //     onAdd(responseData);
  //     onAdd({'activeRoute': 'app_wall'});
  //     onSave();
  //     notifyListeners();
  //   } else {
  //     _showPasswordResetButton = true;
  //     _alertMessage = "Não foi possivel efetuar login com os dados informados";
  //     _showAlert = true;
  //     notifyListeners();
  //   }
  // }
  Future<void> logOff() async {
    removeAll();
  }

  int get accountId {
    return instanceMap['id'] ?? "";
  }

  String? get userid {
    return accountId.toString();
  }

  String get authToken {
    return instanceMap['token'] ?? "";
  }

  String get userName {
    return instanceMap['first_name'] ?? "";
  }

  String get userEmail {
    return instanceMap['email'] ?? "";
  }

  String _alertMessage = "";
  String get alertMessage => _alertMessage;

  bool _showAlert = false;
  bool get showAlert => _showAlert;

  final String keyName;
  final String baseUrl;

  bool _isReady = false;
  bool _showPasswordResetButton = false;
  bool get showPasswordResetButton => _showPasswordResetButton;
  bool get isReady => _isReady;


  final List<String> routes = [
    'busy_screen',
    'app_wall',
    'login_wall',
    'signin_wall',
  ];

  int get activeRouteIndex {
    return routes.indexOf(activeRoute);
  }

  String get activeRoute {
    return instanceMap['activeRoute'] ?? "login_wall";
  }
}