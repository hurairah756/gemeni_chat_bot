// ignore_for_file: annotate_overrides
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../networking/api_response.dart';
import '../../utils/constants.dart';
import 'home_repo.dart';
import 'message_model.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends Bloc {
  BuildContext context;
  State<StatefulWidget> state;
  HomeBloc(this.context, this.state) : super(null);

  final TextEditingController textEditingController = TextEditingController();

  late StreamSubscription<ConnectivityResult> subscription;
  final BehaviorSubject<ApiResponse<List<ChatMessageModel>>>
      messagesController =
      BehaviorSubject<ApiResponse<List<ChatMessageModel>>>.seeded(
          ApiResponse.completed([]));
  final _isOnlineController =
      BehaviorSubject<ApiResponse<bool>>.seeded(ApiResponse.completed(true));

  Stream<ApiResponse<bool>> get isOnlineStream => _isOnlineController.stream;

  Stream<ApiResponse<List<ChatMessageModel>>> get messagesStream =>
      messagesController.stream;

  void dispose() {
    messagesController.close();
    _isOnlineController.close();
  }

  void checkInternetConnectivity(
      BuildContext context, ConnectivityResult result) {
    _isOnlineController.sink.add(ApiResponse.loading());

    if (result == ConnectivityResult.none) {
      _isOnlineController.sink
          .add(ApiResponse.error(ConstantStrings.NO_INTERNET));
      log(ConstantStrings.NO_INTERNET,
          name: ConstantStrings.INTERNET_EXCEPTION);
    } else {
      _isOnlineController.sink.add(ApiResponse.completed(true));
      log(ConstantStrings.YES_INTERNET_CONNECETED,
          name: ConstantStrings.INTERNET_EXCEPTION);
    }
  }

  Future<void> generateChatTextMessage(String inputMessage) async {
    messagesController.sink.add(ApiResponse.loading());

    final currentResponse = messagesController.value;
    // List<ChatMessageModel> currentMessages = [];

    List<ChatMessageModel> currentMessages =
        List.from(currentResponse.data ?? []);

    currentMessages.add(ChatMessageModel(
        role: ConstantStrings.USER,
        parts: [ChatPartModel(text: inputMessage)]));

    try {
      String generatedText =
          await HomeRepo.chatTextGenerationRepo(currentMessages);

      if (generatedText.isNotEmpty) {
        currentMessages.add(ChatMessageModel(
            role: ConstantStrings.MODEL,
            parts: [ChatPartModel(text: generatedText)]));
      }
      messagesController.sink.add(ApiResponse.completed(currentMessages));

      await saveMessagesToPrefs(currentMessages);
    } catch (error) {
      if (!state.mounted) return;
      messagesController.sink.add(ApiResponse.error(
          "${ConstantStrings.FAILED_TO_GENERATE} ${error.toString()}"));
    }
  }

  Future<void> saveMessagesToPrefs(List<ChatMessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    String messagesJson =
        jsonEncode(messages.map((message) => message.toJson()).toList());
    await prefs.setString(ConstantStrings.CHAT_MESSAGES, messagesJson);
  }

  Future<List<ChatMessageModel>> loadMessagesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString(ConstantStrings.CHAT_MESSAGES);
    if (messagesJson != null) {
      List<dynamic> jsonList = jsonDecode(messagesJson);
      List<ChatMessageModel> messages =
          jsonList.map((json) => ChatMessageModel.fromJson(json)).toList();
      return messages;
    }
    return [];
  }
}
