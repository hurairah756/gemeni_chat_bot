// ignore_for_file: type_literal_in_constant_pattern, sized_box_for_whitespace
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:space_pod/screens/home/home_controller.dart';
import '../../networking/api_response.dart';
import '../../utils/constants.dart';
import 'message_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _bloc = HomeBloc(context, this);

  @override
  void initState() {
    super.initState();
    _bloc.subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      _bloc.checkInternetConnectivity(context, result);
    });
    _bloc.loadMessagesFromPrefs().then((messages) {
      _bloc.messagesController.sink.add(ApiResponse.completed(messages));
    });
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      _bloc = HomeBloc(context, this);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ApiResponse<bool>>(
        stream: _bloc.isOnlineStream,
        builder: (context, snapshot) {
          switch (snapshot.data?.status ?? Status.loading) {
            case Status.loading:
              return const Center(
                child: SpinKitCircle(
                  size: 50,
                  color: Colors.blue,
                ),
              );
            case Status.completed:
              return StreamBuilder<ApiResponse<List<ChatMessageModel>>>(
                stream: _bloc.messagesStream,
                builder: (context, snapshot) {
                  Status status = snapshot.data?.status ?? Status.loading;
                  List<ChatMessageModel> messages = snapshot.data?.data ?? [];
                  String? errorMessage = snapshot.data?.message;
                  return Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          opacity: 0.5,
                          image: AssetImage(ConstantImages.SPACE_IMAGE),
                          fit: BoxFit.cover),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 100,
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ConstantStrings.SPACE_POD,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                              Icon(
                                Icons.image_search,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child:
                              _buildChatContent(messages, status, errorMessage),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _bloc.textEditingController,
                                  style: const TextStyle(color: Colors.black),
                                  cursorColor: Theme.of(context).primaryColor,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    fillColor: Colors.white,
                                    hintText: ConstantStrings.ASK_SOMETHING,
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade400),
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () {
                                  if (_bloc
                                      .textEditingController.text.isNotEmpty) {
                                    String text =
                                        _bloc.textEditingController.text;
                                    _bloc.textEditingController.clear();
                                    _bloc.generateChatTextMessage(text);
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: const Center(
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            case Status.error:
              return Center(
                child: Text(
                    '${ConstantStrings.ERROR_SNAPSHOT} ${snapshot.data?.message ?? ''}'),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}

Widget _buildChatContent(
    List<ChatMessageModel> messages, Status status, String? errorMessage) {
  if (status == Status.loading) {
    return Center(
      child: Row(
        children: [
          Container(
              height: 130,
              width: 130,
              child: Lottie.asset(ConstantImages.LOADER)),
          const SizedBox(width: 15),
          const Text(ConstantStrings.LOADING),
        ],
      ),
    );
  } else if (status == Status.completed) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        ChatMessageModel message = messages[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.amber.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.role == ConstantStrings.USER
                    ? ConstantStrings.USER_U
                    : ConstantStrings.SPACE_POD,
                style: TextStyle(
                  fontSize: 14,
                  color: message.role == ConstantStrings.USER
                      ? Colors.amber
                      : Colors.purple.shade200,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message.parts.first.text,
                style: const TextStyle(height: 1.2),
              ),
            ],
          ),
        );
      },
    );
  } else {
    return Center(
      child: Text(
        '${ConstantStrings.ERROR_EXC} ${errorMessage ?? ConstantStrings.ERROR_OCCURED}',
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late HomeBloc _bloc = HomeBloc(context, this);
//
//   @override
//   void initState() {
//     super.initState();
//     _bloc.subscription = Connectivity()
//         .onConnectivityChanged
//         .listen((ConnectivityResult result) {
//       _bloc.checkInternetConnectivity(context, result);
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     if (mounted) {
//       _bloc = HomeBloc(context, this);
//     }
//     super.didChangeDependencies();
//   }
//
//   @override
//   void dispose() {
//     _bloc.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<ApiResponse<List<ChatMessageModel>>>(
//         stream: _bloc.messagesStream,
//         builder: (context, snapshot) {
//           switch (snapshot.data?.status ?? Status.loading) {
//             case Status.loading:
//               return Center(
//                 child: Row(
//                   children: [
//                     Container(
//                         height: 150,
//                         width: 150,
//                         child: Lottie.asset('assets/animation/loader.json')),
//                     const SizedBox(width: 20),
//                     const Text("Loading..."),
//                   ],
//                 ),
//               );
//             case Status.completed:
//               List<ChatMessageModel> messages = snapshot.data!.data ?? [];
//               return Container(
//                 width: double.maxFinite,
//                 height: double.maxFinite,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                       opacity: 0.5,
//                       image: AssetImage("assets/images/space_bg.jpg"),
//                       fit: BoxFit.cover),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       height: 100,
//                       child: const Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Space Pod',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 22),
//                           ),
//                           Icon(
//                             Icons.image_search,
//                             color: Colors.white,
//                           )
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                         child: ListView.builder(
//                             itemCount: messages.length,
//                             itemBuilder: (context, index) {
//                               return Container(
//                                   margin: const EdgeInsets.only(
//                                       bottom: 12, left: 16, right: 16),
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(16),
//                                       color: Colors.amber.withOpacity(0.1)),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         messages[index].role == "user"
//                                             ? "User"
//                                             : "Space Pod",
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             color:
//                                                 messages[index].role == "user"
//                                                     ? Colors.amber
//                                                     : Colors.purple.shade200),
//                                       ),
//                                       const SizedBox(
//                                         height: 12,
//                                       ),
//                                       Text(
//                                         messages[index].parts.first.text,
//                                         style: const TextStyle(height: 1.2),
//                                       ),
//                                     ],
//                                   ));
//                             })),
//                     // if (_controller.generating)
//                     //   Row(
//                     //     children: [
//                     //       Container(
//                     //           height: 100,
//                     //           width: 100,
//                     //           child:
//                     //               Lottie.asset('assets/animation/loader.json')),
//                     //       const SizedBox(
//                     //         width: 20,
//                     //       ),
//                     //       const Text("Loading..."),
//                     //     ],
//                     //   ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 30, horizontal: 15),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _bloc.textEditingController,
//                               style: const TextStyle(color: Colors.black),
//                               cursorColor: Theme.of(context).primaryColor,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(100),
//                                 ),
//                                 fillColor: Colors.white,
//                                 hintText: "Ask Something from AI",
//                                 hintStyle:
//                                     TextStyle(color: Colors.grey.shade400),
//                                 filled: true,
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(100),
//                                   borderSide: BorderSide(
//                                       color: Theme.of(context).primaryColor),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           InkWell(
//                             onTap: () {
//                               if (_bloc.textEditingController.text.isNotEmpty) {
//                                 String text = _bloc.textEditingController.text;
//                                 _bloc.textEditingController.clear();
//                                 // chatBloc.add(ChatGenerateNewTextMessageEvent(
//                                 //     inputMessage: text));
//                                 _bloc.generateChatTextMessage(text);
//                               }
//                             },
//                             child: CircleAvatar(
//                               radius: 32,
//                               backgroundColor: Colors.white,
//                               child: CircleAvatar(
//                                 radius: 30,
//                                 backgroundColor: Theme.of(context).primaryColor,
//                                 child: const Center(
//                                   child: Icon(
//                                     Icons.send,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             case Status.error:
//               return Center(
//                 child: Text('Error ${snapshot.data?.message ?? ''}'),
//               );
//             default:
//               return const SizedBox();
//           }
//         },
//       ),
//     );
//   }
// }
