import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DjangoAuthProvider extends StatelessWidget {
  const DjangoAuthProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(),
      // child: MultiProvider(providers: [
      //   ChangeNotifierProvider(create: (_) => AuthState(keyName: "auth_state")),
      // ], child: AuthManager()),
    );
  }
}
