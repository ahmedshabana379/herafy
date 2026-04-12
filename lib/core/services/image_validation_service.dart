import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:herafy/core/networks/end_points.dart';
import 'package:image/image.dart' as img;

enum DocumentType { nationalId, personalPhoto, criminalRecord }

class ValidationResult {
  final bool isValid;
  final String? rejectionReason;
  ValidationResult({required this.isValid, this.rejectionReason});
}

class ImageValidationService {
  static const String _apiKey = AppEndPoints.geminiApiKey;
  
  // استخدم API v1beta مع النموذج الصحيح
  static const String _baseUrl = 
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent";

  static Future<ValidationResult> validateDocument({
    required File imageFile,
    required DocumentType documentType,
    String? firstName,
    String? lastName,
    String? birthDate,
  }) async {
    try {
      print("🔍 START GEMINI VALIDATION: $documentType");

      // معالجة الصورة
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        return ValidationResult(
          isValid: false,
          rejectionReason: "الصورة تالفة أو غير صالحة",
        );
      }

      final resized = decoded.width > 1024 
          ? img.copyResize(decoded, width: 1024) 
          : decoded;
      final compressedBytes = img.encodeJpg(resized, quality: 75);
      final base64Image = base64Encode(compressedBytes);

      // بناء الـ prompt
      final prompt = _buildPrompt(
        documentType,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
      );

      print("📤 SENDING TO GEMINI API...");
      
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image,
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.1,
            "topP": 0.95,
            "topK": 40,
            "maxOutputTokens": 1024,
          }
        }),
      );

      if (response.statusCode != 200) {
        print("❌ API Error ${response.statusCode}: ${response.body}");
        // لا تمرر الصورة تلقائياً - ارفضها إذا فشل الـ API
        return ValidationResult(
          isValid: false,
          rejectionReason: "حدث خطأ في التحقق من الصورة، يرجى المحاولة مرة أخرى",
        );
      }

      final responseData = jsonDecode(response.body);
      print("✅ API Response received");

      // استخراج النص من الـ response
      final String? text = responseData['candidates']?[0]?['content']?['parts']?[0]?['text'];
      
      if (text == null || text.isEmpty) {
        return ValidationResult(
          isValid: false,
          rejectionReason: "لم نتمكن من تحليل الصورة، يرجى المحاولة مرة أخرى",
        );
      }

      print("📥 Gemini Response: $text");
      
      // تنظيف الـ JSON من أي نص إضافي
      String cleanJson = text;
      if (text.contains('{') && text.contains('}')) {
        final start = text.indexOf('{');
        final end = text.lastIndexOf('}') + 1;
        cleanJson = text.substring(start, end);
      }
      
      try {
        final result = jsonDecode(cleanJson);
        final isValid = result['isValid'] == true;
        final reason = result['reason'] as String?;
        
        print("📊 Validation result: isValid=$isValid, reason=$reason");
        
        return ValidationResult(
          isValid: isValid,
          rejectionReason: isValid ? null : (reason ?? "الصورة غير مناسبة"),
        );
      } catch (e) {
        print("❌ JSON parsing error: $e");
        return ValidationResult(
          isValid: false,
          rejectionReason: "خطأ في تحليل نتيجة التحقق",
        );
      }
      
    } catch (e) {
      print("❌ ERROR IN VALIDATION SERVICE: $e");
      return ValidationResult(
        isValid: false,
        rejectionReason: "حدث خطأ أثناء التحقق من الصورة",
      );
    }
  }

  static String _buildPrompt(
    DocumentType type, {
    String? firstName,
    String? lastName,
    String? birthDate,
  }) {
    switch (type) {
      case DocumentType.nationalId:
        return '''
أنت نظام تدقيق صارم للتحقق من بطاقات الهوية المصرية.

المطلوب:
1. تأكد أن الصورة تحتوي على بطاقة هوية مصرية حقيقية (ليست نسخة ورقية، ليست صورة من شاشة موبايل)
2. تحقق من وضوح الصورة: يجب أن تكون جميع البيانات مقروءة بوضوح
3. تأكد من عدم وجود تعديل أو فوتوشوب على الصورة
4. إذا تم توفير بيانات للمطابقة، تحقق من تطابقها مع البيانات الموجودة في البطاقة

بيانات المطابقة (إذا وجدت):
- الاسم: ${firstName ?? ""} ${lastName ?? ""}
- تاريخ الميلاد: ${birthDate ?? ""}

أجب فقط بـ JSON بهذا التنسيق الدقيق:
{
  "isValid": true/false,
  "reason": "سبب الرفض بالعربية (إذا كان isValid=false)"
}

ملاحظات هامة:
- إذا كانت الصورة غير واضحة أو مقطوعة => isValid=false
- إذا كانت الصورة لبطاقة مزيفة أو من شاشة موبايل => isValid=false
- إذا كانت البيانات غير مطابقة (عند توفيرها) => isValid=false
- فقط إذا كانت الصورة لبطاقة هوية مصرية حقيقية وواضحة ومطابقة للبيانات => isValid=true
''';
      
      case DocumentType.personalPhoto:
        return '''
أنت نظام تدقيق صارم للتحقق من الصور الشخصية.

المطلوب:
1. تأكد أن الصورة تحتوي على وجه شخص حقيقي (ليست رسمة أو كرتون)
2. تأكد أن الوجه واضح وغير محجوب (بدون نظارة شمسية، كمامة، أو تغطية)
3. الصورة يجب أن تكون ملونة وواضحة
4. الوجه يجب أن يكون في مواجهة الكاميرا

أجب فقط بـ JSON بهذا التنسيق:
{
  "isValid": true/false,
  "reason": "سبب الرفض بالعربية"
}

- إذا كان الوجه غير واضح أو محجوب => isValid=false
- إذا كانت الصورة لشخص آخر غير حقيقي => isValid=false
- فقط إذا كانت الصورة صورة شخصية واضحة لوجه حقيقي => isValid=true
''';
      
      case DocumentType.criminalRecord:
        return '''
أنت نظام تدقيق للتحقق من فيش وتشبيه (سجل جنائي).

المطلوب:
1. تأكد أن الصورة تحتوي على مستند رسمي لفيش وتشبيه
2. تحقق من وضوح النص والبيانات
3. المستند يجب أن يكون من جهة رسمية

أجب فقط بـ JSON بهذا التنسيق:
{
  "isValid": true/false,
  "reason": "سبب الرفض بالعربية"
}

- إذا كانت الصورة غير واضحة => isValid=false
- إذا كان المستند ليس فيش وتشبيه رسمي => isValid=false
- فقط إذا كانت الصورة واضحة لمستند رسمي => isValid=true
''';
    }
  }
}