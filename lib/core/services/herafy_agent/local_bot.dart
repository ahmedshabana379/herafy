// // lib/features/bot/gemini_bot_widget.dart
// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:herafy/core/constants/api_keys.dart';
// import 'package:herafy/core/networks/cache_helper.dart';
// import 'package:herafy/features/auth/models/services_model.dart';

// class GeminiBotWidget extends StatefulWidget {
//   final Function(BotAction) onConfirmRequest;
//   final List<ServiceModel> services;

//   const GeminiBotWidget({
//     super.key,
//     required this.onConfirmRequest,
//     required this.services,
//   });

//   @override
//   State<GeminiBotWidget> createState() => _GeminiBotWidgetState();
// }

// class _GeminiBotWidgetState extends State<GeminiBotWidget> {
//   final TextEditingController _inputController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<ChatMessage> _messages = [];
//   bool _isOpen = false;
//   bool _isTyping = false;
//   late GenerativeModel _model;
//   late ChatSession _chat;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeGemini();
//   }

//   Future<void> _initializeGemini() async {
//     try {
//       final user = await CacheHelper.getUserData();
//       final systemPrompt = _getDynamicPrompt(user);

//       _model = GenerativeModel(
//         model: 'gemini-1.5-flash',
//         apiKey: ApiKeys.geminiApiKey,
//         systemInstruction: Content.text(systemPrompt),
//       );

//       _chat = _model.startChat();
      
//       setState(() {
//         _isInitialized = true;
//       });
      
//       _addBotMessage(
//         'مرحباً! 👋\n\nأنا مساعدك الذكي في تطبيق حرفي.\n\nيمكنك أن تصف لي مشكلتك بالتفصيل، وسأقوم بتجهيز طلب الخدمة لك تلقائياً.\n\nمثلاً:\n• "عاوز سباك النهاردة عشان الحمام بينقط"\n• "محتاج كهربائي بكره الصبح عشان الفيش محروق"\n• "في تسريب مياه في المطبخ عاجل من فضلك"',
//       );
//     } catch (e) {
//       print('Error initializing Gemini: $e');
//       _addBotMessage('عذراً، حدث خطأ في تحميل المساعد. يرجى المحاولة مرة أخرى.');
//     }
//   }

//   String _getDynamicPrompt(user) {
//     // بناء قائمة الخدمات للـ prompt
//     final servicesList = widget.services.map((s) => '${s.name}: ${s.id}').join('\n');
    
//     return '''
// أنت مساعد ذكي لتطبيق "حرفي" - منصة تربط العملاء بالحرفيين المتخصصين.

// **معلومات المستخدم:**
// - الاسم: ${user?.fullName ?? 'زائر'}
// - البريد: ${user?.email ?? 'غير مسجل'}
// - النوع: ${user?.isProvider == true ? 'حرفي' : 'عميل'}

// **الخدمات المتاحة:**
// $servicesList

// **المهام التي يمكنك القيام بها:**
// 1. فهم مشكلة المستخدم بدقة
// 2. تحديد الخدمة المناسبة (مع ServiceId)
// 3. فهم الوقت المطلوب (الآن، بعد ساعة، بكره، إلخ)
// 4. كتابة وصف دقيق للمشكلة
// 5. اقتراح ميزانية مناسبة

// **عندما يطلب المستخدم خدمة، استجب بهذا التنسيق بالضبط:**
// [Action]{"type":"instant_request","serviceId":1,"description":"وصف المشكلة بالتفصيل","preferredTime":"2026-04-18T14:30:00","isUrgent":false}[/Action]

// **أمثلة على الوقت (تنسيق ISO):**
// - "الآن" أو "حالاً" → الوقت الحالي
// - "بعد ساعة" → الوقت الحالي + 1 ساعة
// - "بكرة الصبح الساعة 9" → غداً الساعة 09:00:00
// - "بعد العشاء" → اليوم الساعة 20:00:00
// - "يوم الأحد الجاي" → الأحد القادم الساعة 10:00:00

// **أمثلة على الميزانية المقترحة:**
// - سباك: 200-500 ج.م
// - كهربائي: 300-600 ج.م
// - نجار: 400-800 ج.م

// **تعليمات مهمة:**
// - تحدث باللهجة المصرية الدارجة
// - كن ودوداً ومحترفاً
// - اسأل عن الوقت إذا لم يذكره المستخدم
// - إذا كان الوصف غير واضح، اسأل أسئلة توضيحية
// - بعد فهم الطلب، أرسل Action بالتنسيق المطلوب
// ''';
//   }

//   void _addUserMessage(String text) {
//     setState(() {
//       _messages.add(ChatMessage(text: text, isUser: true));
//     });
//     _scrollToBottom();
//   }

//   void _addBotMessage(String text, {bool isLoading = false}) {
//     setState(() {
//       _messages.add(ChatMessage(text: text, isUser: false, isLoading: isLoading));
//     });
//     _scrollToBottom();
//   }

//   void _updateLastBotMessage(String text) {
//     setState(() {
//       if (_messages.isNotEmpty && !_messages.last.isUser) {
//         _messages.last = ChatMessage(text: text, isUser: false);
//       }
//     });
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> _sendMessage() async {
//     if (!_isInitialized) {
//       _addBotMessage('جاري تحميل المساعد... يرجى الانتظار.');
//       return;
//     }

//     final text = _inputController.text.trim();
//     if (text.isEmpty) return;

//     _addUserMessage(text);
//     _inputController.clear();
//     _addBotMessage('', isLoading: true);
//     _isTyping = true;

//     try {
//       final response = _chat.sendMessage(Content.text(text));
//       String fullText = '';
      
//       await for (final chunk in response) {
//         final chunkText = chunk.text ?? '';
//         fullText += chunkText;
        
//         // استخراج النص قبل الـ Action
//         String displayText = fullText;
//         final actionMatch = RegExp(r'\[Action\](.*?)\[/Action\]', caseSensitive: false).firstMatch(fullText);
//         if (actionMatch != null) {
//           displayText = fullText.substring(0, actionMatch.start);
//         }
        
//         if (displayText.isEmpty) displayText = 'جاري معالجة طلبك...';
//         _updateLastBotMessage(displayText);
//       }

//       // استخراج الـ Action
//       final actionMatch = RegExp(r'\[Action\](.*?)\[/Action\]', caseSensitive: false).firstMatch(fullText);
      
//       if (actionMatch != null) {
//         try {
//           final actionJson = actionMatch.group(1)!;
//           final actionData = jsonDecode(actionJson);
          
//           final botAction = BotAction(
//             serviceId: actionData['serviceId'],
//             description: actionData['description'],
//             preferredTime: actionData['preferredTime'] != null 
//                 ? DateTime.parse(actionData['preferredTime']) 
//                 : DateTime.now(),
//             isUrgent: actionData['isUrgent'] ?? false,
//             suggestedBudget: actionData['suggestedBudget'] ?? _getDefaultBudget(actionData['serviceId']),
//           );
          
//           // عرض ملخص الطلب وزر التأكيد
//           await Future.delayed(const Duration(milliseconds: 300));
//           _showConfirmationCard(botAction);
          
//         } catch (e) {
//           print('Error parsing action: $e');
//           _addBotMessage('عذراً، حدث خطأ في فهم طلبك. يرجى المحاولة مرة أخرى.');
//         }
//       }
      
//     } catch (e) {
//       print('Error sending message: $e');
//       _updateLastBotMessage('عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.');
//     } finally {
//       setState(() => _isTyping = false);
//     }
//   }

//   double _getDefaultBudget(int serviceId) {
//     switch (serviceId) {
//       case 1: return 300;
//       case 2: return 400;
//       case 3: return 500;
//       case 4: return 600;
//       case 5: return 700;
//       default: return 300;
//     }
//   }

//   void _showConfirmationCard(BotAction action) {
//     setState(() {
//       _messages.add(ChatMessage(
//         text: '',
//         isUser: false,
//         isActionButton: true,
//         action: action,
//       ));
//     });
//     _scrollToBottom();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // زر البوت
//         if (!_isOpen)
//           Positioned(
//             bottom: 20,
//             right: 16,
//             child: GestureDetector(
//               onTap: () => setState(() => _isOpen = true),
//               child: Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2b2854), Color(0xFF6C63FF)],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.4),
//                       blurRadius: 20,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.assistant,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//             ),
//           ),

//         // نافذة المحادثة
//         if (_isOpen)
//           Positioned(
//             bottom: 20,
//             right: 16,
//             child: Material(
//               elevation: 10,
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.85,
//                 height: 500,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   children: [
//                     _buildHeader(),
//                     Expanded(child: _buildMessagesList()),
//                     _buildInputBar(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: const BoxDecoration(
//         color: Color(0xFF2b2854),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.assistant, color: Colors.white),
//           const SizedBox(width: 8),
//           const Text(
//             'مساعد حرفي الذكي',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.white),
//             onPressed: () => setState(() => _isOpen = false),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessagesList() {
//     if (!_isInitialized) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('جاري تحميل المساعد الذكي...'),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.all(16),
//       itemCount: _messages.length,
//       itemBuilder: (context, index) {
//         final msg = _messages[index];
        
//         if (msg.isActionButton && msg.action != null) {
//           return _buildConfirmationCard(msg.action!);
//         }
        
//         return _buildMessageBubble(msg);
//       },
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage msg) {
//     return Align(
//       alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.6,
//         ),
//         decoration: BoxDecoration(
//           color: msg.isUser ? const Color(0xFF2b2854) : Colors.grey[200],
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: msg.isLoading
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//             : Text(
//                 msg.text,
//                 style: TextStyle(
//                   color: msg.isUser ? Colors.white : Colors.black87,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildConfirmationCard(BotAction action) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.green[50],
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.green[200]!),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               '📋 ملخص طلبك:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text('• الخدمة: ${_getServiceName(action.serviceId)}'),
//             Text('• الوصف: ${action.description}'),
//             Text('• الوقت: ${_formatTime(action.preferredTime)}'),
//             if (action.isUrgent) 
//               const Text('• عاجل: نعم', style: TextStyle(color: Colors.red)),
//             Text('• الميزانية المقترحة: ${action.suggestedBudget.toStringAsFixed(0)} ج.م'),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       widget.onConfirmRequest(action);
//                       setState(() => _isOpen = false);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text('تأكيد وإرسال الطلب'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       setState(() {
//                         _messages.removeWhere((m) => m.isActionButton);
//                       });
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Colors.grey),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text('تعديل'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getServiceName(int serviceId) {
//     final service = widget.services.firstWhere(
//       (s) => s.id == serviceId,
//       orElse: () => ServiceModel(id: 0, name: 'غير معروف'),
//     );
//     return service.name ?? 'غير معروف';
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final diff = time.difference(now);
    
//     if (diff.inMinutes < 1) return 'الآن';
//     if (diff.inMinutes < 60) return 'بعد ${diff.inMinutes} دقيقة';
//     if (diff.inDays == 1) return 'بكرة الساعة ${time.hour}:${time.minute}';
//     if (diff.inDays == 2) return 'بعد بكرة الساعة ${time.hour}:${time.minute}';
//     if (diff.inDays > 0) return '${time.day}/${time.month} الساعة ${time.hour}:${time.minute}';
//     return 'الساعة ${time.hour}:${time.minute}';
//   }

//   Widget _buildInputBar() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _inputController,
//               decoration: InputDecoration(
//                 hintText: 'اكتب طلبك بالعربية...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//               ),
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 8),
//           CircleAvatar(
//             backgroundColor: const Color(0xFF2b2854),
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white, size: 18),
//               onPressed: _isTyping ? null : _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUser;
//   final bool isLoading;
//   final bool isActionButton;
//   final BotAction? action;

//   ChatMessage({
//     required this.text,
//     required this.isUser,
//     this.isLoading = false,
//     this.isActionButton = false,
//     this.action,
//   });
// }

// class BotAction {
//   final int serviceId;
//   final String description;
//   final DateTime preferredTime;
//   final bool isUrgent;
//   final double suggestedBudget;

//   BotAction({
//     required this.serviceId,
//     required this.description,
//     required this.preferredTime,
//     required this.isUrgent,
//     required this.suggestedBudget,
//   });
// }