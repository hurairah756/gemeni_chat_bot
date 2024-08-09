// ignore_for_file: constant_identifier_names
// const apiKey = "AIzaSyBIznqLu7wT41LwvlntI7n15a6ozBCJIVE";

class ConstantImages {
  static const String ASSET_IMAGE_PATH = 'assets/images/';
  static const String ASSET_FONTS_PATH = 'assets/fonts/';
  static const String ASSET_ANIM_PATH = 'assets/animation/';

  static const String SPACE_IMAGE = "${ASSET_IMAGE_PATH}space_bg.jpg";
  static const String SPLASH_PIC = "${ASSET_IMAGE_PATH}splash_pic.jpg";
  static const String LOADER = "${ASSET_ANIM_PATH}loader.json";
}

class ConstantStrings {
  static const String ERROR = "Error";
  static const String FAILED = "No Internet";
  static const String ROUTE_ERROR = "This is not the page you are looking for";
  static const String TRAJAN = "Trajan";

  static const String FAILED_TO_FETCH = "Failed to fetch news data";
  static const String EXCEPTION_OCCURRED = "Exception occurred:";
  static const String NEWS_EXCEPTION = "News Exception";
  static const String NO_INTERNET = "No Internet";
  static const String NO_INTERNET_CONNECTION = "No Internet Connection";
  static const String ERROR_SNAPSHOT = "Error:";

  static const String YES_INTERNET_CONNECETED = "Yes Internet connected";
  static const String INTERNET_EXCEPTION = "Internet Exception";

  static const String USER = "user";
  static const String USER_U = "User";
  static const String MODEL = "model";

  static const String FAILED_TO_GENERATE =
      "Failed to generate chat text message:";

  static const String SPACE_POD = "Space Pod";
  static const String ASK_SOMETHING = "Ask Something from AI";

  static const String ERROR_OCCURED = "An unknown error occurred";
  static const String ERROR_EXC = "Error:";

  static const String SIXTY_FOUR = "SixtyFour";
  static const String GALAXY = "Galaxy";

  static const String CANDIDATES = "candidates";
  static const String CHAT_MESSAGES = "chat_messages";
  static const String CONTENT = "content";
  static const String PARTS = "parts";
  static const String TEXT = "text";
  static const String LOADING = "Loading...";
}

class ApiConstants {
  static const String BASE_URL =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String MODEL = 'gemini-1.0-pro';
  static const String apiKey = 'AIzaSyBIznqLu7wT41LwvlntI7n15a6ozBCJIVE';
  static const generationConfig = {
    "temperature": 0.9,
    "topK": 1,
    "topP": 1,
    "maxOutputTokens": 2048,
    "stopSequences": []
  };
  static const safetySettings = [
    {
      "category": "HARM_CATEGORY_HARASSMENT",
      "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
      "category": "HARM_CATEGORY_HATE_SPEECH",
      "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
      "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
      "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    },
    {
      "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
      "threshold": "BLOCK_MEDIUM_AND_ABOVE"
    }
  ];
}
