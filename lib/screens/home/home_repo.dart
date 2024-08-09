// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:space_pod/utils/constants.dart';
import 'message_model.dart';

class HomeRepo {
  static Future<String> chatTextGenerationRepo(
      List<ChatMessageModel> previousMessages) async {
    final Dio dio = Dio();

    try {
      const url =
          "${ApiConstants.BASE_URL}/${ApiConstants.MODEL}:generateContent";

      final queryParameters = {
        'key': ApiConstants.apiKey,
      };

      final requestData = {
        "contents": previousMessages.map((e) => e.toMap()).toList(),
        "generationConfig": ApiConstants.generationConfig,
        "safetySettings": ApiConstants.safetySettings,
      };

      final response = await dio.post(
        url,
        queryParameters: queryParameters,
        data: requestData,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response
            .data[ConstantStrings.CANDIDATES]
            .first[ConstantStrings.CONTENT][ConstantStrings.PARTS]
            .first[ConstantStrings.TEXT];
      }
      log(response.toString());
      return '';
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}


