import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_toolbox/notifiers/generic_map_notifier.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../utils/static_methods.dart';

class GenericRestAndSocketNotifier extends GenericMapNotifier {
  GenericRestAndSocketNotifier(
      {required this.keyName,
      required this.baseSocketUrl,
      required this.baseRestUrl,
      required this.authHeaders,
      required this.ssoToken})
      : super(keyName: keyName);

  final String keyName;
  final Map<String, String> authHeaders;
  final String ssoToken;
  final String baseRestUrl;
  final String baseSocketUrl;
  WebSocketChannel? _ws_channel;
  StreamSubscription? _channelListener;
  Stream? stream;

  List<Map<int, dynamic>> _collections =[];
  List<Map<int, dynamic>> get collections => _collections;

  Map<String, dynamic> _last_data = {};
  Map<String, dynamic> get last_data => _last_data;
  bool _changeSelection = false;
  bool get changeSelection => _changeSelection;
  List<String> _inbound_data = [];
  bool in_dispose = false;
  int get totalUpdates => _inbound_data.length;
  Map<int, int> statusCodesByPage = {};

  List<int> _downloadedPages = [];

  Future<void> selectionChanged() async {
    _changeSelection = false;
  }

  int _activePage = 1;
  int get activePage => _activePage;
  int get totalPages =>
      throw UnimplementedError("Metodo para informar total de paginas");
  int get totalResults =>
      throw UnimplementedError("Metodo para informar total de resultados");
  bool get isReady =>
      throw UnimplementedError("Propriedade para informar da inicializacao");

  Future<void> onRequestPrevPage() async {
    onRequestPage(_activePage - 1, false);
  }

  Future<void> onRequestNextPage() async {
    onRequestPage(_activePage + 1, false);
  }

  // dynamic getById(int id) {
  //   return _records.firstWhere((record) => record.id == id);
  // }

  Future<void> onInit() async {
    throw UnimplementedError("Metodo para inicializar o objeto");
  }

  Future<void> onRebuildState(String newData) async {
    throw UnimplementedError(
        "Metodo para reconstruir o state nao implementado");
  }


  Future<Map<String, dynamic>> onComputeJson(String inputData) async {
    return jsonDecode(inputData);
  }

  Future<void> onParseCollection(int page, String inputData) async {
    Map<String, dynamic>  collection = await compute(onComputeJson, inputData);
    if(collection.containsKey("results")){
      List<dynamic> results = collection['results'];
      results.forEach((element) {
        onRebuildState(element);
      });

    }
  }

  Future<void> onRequestPage(int page, bool waitfor) async {
    _activePage = page;

    Uri url = Uri.parse("${baseRestUrl}");
    Map<String, String> query_string = {"page": page.toString()};
    query_string.addAll(url.queryParameters);
    url = url.replace(queryParameters: query_string);

    if (kDebugMode) {
      print(query_string);
      print("Download url $url");
    }

    final request = await StaticMethods.requestGet(url, authHeaders);

    if (request.statusCode == 200) {
      if (waitfor) {
        await onParseCollection(page, utf8.decode(request.bodyBytes));

      } else {
        onParseCollection(page, utf8.decode(request.bodyBytes));
      }
    } else {
      Future.delayed(Duration(seconds: 5), () {
        onRequestPage(page, waitfor);
      });
      if (kDebugMode) {
        print("Erro ao baixar");
      }
    }
  }

  Future<void> closeWs() async {
    _ws_channel?.sink.close(1000);
  }

  @override
  void dispose() {
    in_dispose = true;
    closeWs().then((value) => {
          super.dispose(),
        });
  }

  Future<void> sendMessage(String msg) async {
    _ws_channel?.sink.add(msg);
  }

  Future<void> onStartWs() async {
    final url = Uri.parse("${baseSocketUrl}?sso=$ssoToken");
    if (kDebugMode) {
      print("Start wss $url");
    }

    _ws_channel = WebSocketChannel.connect(url);
    stream = _ws_channel?.stream;

    stream?.listen((message) {
      onRebuildState(message);
    }, onError: (error) {
      Future.delayed(Duration(seconds: 5), () {
        closeWs().then((value) => onStartWs());
      });
    }, onDone: () {});
  }
}
