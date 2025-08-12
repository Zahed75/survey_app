// question_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:survey_app/features/question/screens/result.dart';
import 'package:survey_app/features/question/controller/survey_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../common/widgets/alerts/u_alert.dart';
import '../../../data/services/auth_service.dart';

class QuestionScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const QuestionScreen({super.key, required this.surveyData});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool isSubmitting = false;
  late SurveyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SurveyController>();

    // ✅ ensure fresh form when opening
    controller.resetAll();

    _getLocation();
  }

  Future<void> _getLocation() async {
    if (!mounted) return;
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar("Permission Denied", "Location permission is required.");
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      controller.updateLocation(position.latitude, position.longitude);
    }
  }

  Future<void> pickImage(int questionId) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      controller.updateUploadedImage(questionId, image.path);
    }
  }

  Future<void> uploadFile(int questionId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      controller.updateUploadedImage(questionId, result.files.single.path);
    }
  }

  Future<void> detectLocation(int questionId) async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar("Permission Denied", "Location permission is required.");
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    controller.updateDetectedLocation(
      questionId,
      position.latitude,
      position.longitude,
    );
  }

  Widget buildQuestion(Map<String, dynamic> question) {
    final id = question['id'];
    final type = question['type'];
    final text = question['text'];
    final marks = question['marks'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (marks != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Marks: $marks",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // yes/no
            if (type == 'yesno') ...[
              Row(
                children: (question['choices'] as List).map<Widget>((choice) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilledButton.tonal(
                        onPressed: () => setState(() {
                          controller.updateAnswer(id, choice['id']);
                        }),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                          controller.answers[id] == choice['id']
                              ? Colors.green
                              : null,
                        ),
                        child: Text(choice['text']),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // single-choice (MCQ)
            if (type == 'choice') ...[
              ...(question['choices'] as List).map<Widget>((choice) {
                return RadioListTile(
                  title: Text(choice['text']),
                  value: choice['id'],
                  groupValue: controller.answers[id],
                  onChanged: (val) => setState(() {
                    controller.updateAnswer(id, val);
                  }),
                );
              }).toList(),
            ],

            // multiple_scoring (single pick, scored by choice.marks)
            if (type == 'multiple_scoring') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (question['choices'] as List).map<Widget>((choice) {
                  return RadioListTile(
                    title: Text('${choice['text']} (${choice['marks']} marks)'),
                    value: choice['id'],
                    groupValue: controller.answers[id],
                    onChanged: (val) => setState(() {
                      controller.updateAnswer(id, val);
                    }),
                  );
                }).toList(),
              ),
            ],

            // image
            if (type == 'image') ...[
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => pickImage(id),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => uploadFile(id),
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload'),
                  ),
                ],
              ),
              if (controller.uploadedImages[id] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selected: ${controller.uploadedImages[id]!.split("/").last}',
                  ),
                ),
            ],

            // location
            if (type == 'location') ...[
              FilledButton.icon(
                onPressed: () => detectLocation(id),
                icon: const Icon(Icons.location_on),
                label: const Text('Detect Location'),
              ),
              if (controller.detectedLocations[id] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "${controller.detectedLocations[id]!["latitude"]}, ${controller.detectedLocations[id]!["longitude"]}",
                  ),
                ),
            ],

            // text / remarks
            if (type == 'text' || type == 'remarks') ...[
              TextField(
                controller: TextEditingController(),
                maxLines: 3,
                onChanged: (val) => controller.updateAnswer(id, val),
                decoration: const InputDecoration(
                  hintText: "Write your response...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            // linear
            if (type == 'linear') ...[
              const SizedBox(height: 12),
              Text(
                "Select value: ${controller.answers[id] ?? question['min_value'] ?? 0}",
              ),
              Slider(
                min: (question['min_value'] ?? 0).toDouble(),
                max: (question['max_value'] ?? 20).toDouble(),
                divisions: ((question['max_value'] ?? 20) -
                    (question['min_value'] ?? 0))
                    .toInt(),
                value: (controller.answers[id] ?? (question['min_value'] ?? 0))
                    .toDouble(),
                label:
                "${controller.answers[id] ?? question['min_value'] ?? 0}",
                onChanged: (val) => setState(() {
                  controller.updateAnswer(id, val.round());
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ✅ Required validation using UAlert. Returns false if any required question is missing.
  bool _validateRequired(List questions) {
    for (final q in questions) {
      final int id = q['id'];
      final String type = q['type'];
      final bool isRequired = q['is_required'] == true;

      if (!isRequired) continue;

      if (type == 'yesno' || type == 'choice' || type == 'multiple_scoring') {
        if (!controller.answers.containsKey(id)) {
          UAlert.show(
            title: 'Required',
            message: 'Please answer: ${q['text']}',
            icon: Icons.error_outline,
            iconColor: Colors.redAccent,
          );
          return false;
        }
      } else if (type == 'text' || type == 'remarks') {
        final val = controller.answers[id];
        if (val == null || val.toString().trim().isEmpty) {
          UAlert.show(
            title: 'Required',
            message: 'Please provide a response for: ${q['text']}',
            icon: Icons.error_outline,
            iconColor: Colors.redAccent,
          );
          return false;
        }
      } else if (type == 'image') {
        if (controller.uploadedImages[id] == null) {
          UAlert.show(
            title: 'Required',
            message: 'Please upload an image for: ${q['text']}',
            icon: Icons.error_outline,
            iconColor: Colors.redAccent,
          );
          return false;
        }
      } else if (type == 'location') {
        if (controller.detectedLocations[id] == null) {
          UAlert.show(
            title: 'Required',
            message: 'Please detect location for: ${q['text']}',
            icon: Icons.error_outline,
            iconColor: Colors.redAccent,
          );
          return false;
        }
      } else if (type == 'linear') {
        if (!controller.answers.containsKey(id)) {
          UAlert.show(
            title: 'Required',
            message: 'Please select a value for: ${q['text']}',
            icon: Icons.error_outline,
            iconColor: Colors.redAccent,
          );
          return false;
        }
      }
    }
    return true;
  }

  // Future<void> submitSurvey() async {
  //   if (isSubmitting) return;
  //
  //   final questions = widget.surveyData['questions'] as List;
  //
  //   // ✅ required validation
  //   if (!_validateRequired(questions)) return;
  //
  //   setState(() => isSubmitting = true);
  //
  //   final questionResponses = <Map<String, dynamic>>[];
  //
  //   for (int i = 0; i < questions.length; i++) {
  //     final q = questions[i];
  //     final id = q['id'];
  //     final type = q['type'];
  //
  //     final entry = {"question": id};
  //
  //     // ✅ yes/no: send only the selected choice id
  //     if (type == 'yesno' && controller.answers.containsKey(id)) {
  //       entry["selected_choice"] = {
  //         "id": controller.answers[id],
  //       };
  //     }
  //     // ✅ choice (MCQ): send only id
  //     else if (type == 'choice' && controller.answers.containsKey(id)) {
  //       entry["selected_choice"] = {
  //         "id": controller.answers[id],
  //       };
  //     }
  //     // ✅ multiple_scoring: send only id
  //     else if (type == 'multiple_scoring' &&
  //         controller.answers.containsKey(id)) {
  //       entry["selected_choice"] = {
  //         "id": controller.answers[id],
  //       };
  //     } else if (type == 'image' && controller.uploadedImages[id] != null) {
  //       entry["image"] = await _encodeImageToBase64(
  //         controller.uploadedImages[id]!,
  //       );
  //     } else if (type == 'location' &&
  //         controller.detectedLocations[id] != null) {
  //       entry["location"] = {
  //         "lat": controller.detectedLocations[id]!["latitude"],
  //         "lon": controller.detectedLocations[id]!["longitude"],
  //       };
  //     } else if ((type == 'text' || type == 'remarks') &&
  //         controller.answers[id]?.isNotEmpty == true) {
  //       entry["answer_text"] = controller.answers[id];
  //     } else if (type == 'linear' && controller.answers[id] != null) {
  //       entry["linear_value"] = controller.answers[id];
  //     }
  //
  //     questionResponses.add(entry);
  //   }
  //
  //   final body = jsonEncode({
  //     "survey": widget.surveyData['id'],
  //     "location_lat": controller.latitude.value.toString(),
  //     "location_lon": controller.longitude.value.toString(),
  //     "question_responses": questionResponses,
  //   });
  //
  //   try {
  //     final res = await http.post(
  //       Uri.parse(
  //         "https://survey-backend.shwapno.app/survey/api/survey/submit-response/",
  //       ),
  //       headers: {
  //         "Authorization": "Bearer ${Get.find<AuthService>().getToken()}",
  //         "Content-Type": "application/json",
  //       },
  //       body: body,
  //     );
  //
  //     if (res.statusCode == 200 || res.statusCode == 201) {
  //       // ✅ clear state so returning shows a fresh form
  //       controller.resetAll();
  //
  //       final responseJson = jsonDecode(res.body);
  //       final responseId = responseJson['response_id'];
  //       Get.to(() => ResultScreen(responseId: responseId));
  //     } else {
  //       Get.snackbar("Error", "Error submitting survey: ${res.statusCode}");
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Error submitting survey: $e");
  //   } finally {
  //     if (mounted) setState(() => isSubmitting = false);
  //   }
  // }

  Future<void> submitSurvey() async {
    if (isSubmitting) return;

    final questions = widget.surveyData['questions'] as List;

    // ✅ required validation
    if (!_validateRequired(questions)) return;

    setState(() => isSubmitting = true);

    final questionResponses = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final id = q['id'];
      final type = q['type'];

      final entry = {"question": id};

      // ✅ yes/no: send only the selected choice id
      if (type == 'yesno' && controller.answers.containsKey(id)) {
        entry["selected_choice"] = {
          "id": controller.answers[id],
        };
      }
      // ✅ choice (MCQ): send only id
      else if (type == 'choice' && controller.answers.containsKey(id)) {
        entry["selected_choice"] = {
          "id": controller.answers[id],
        };
      }
      // ✅ multiple_scoring: send only id
      else if (type == 'multiple_scoring' && controller.answers.containsKey(id)) {
        entry["selected_choice"] = {
          "id": controller.answers[id],
        };
      }
      // ✅ image as base64
      else if (type == 'image' && controller.uploadedImages[id] != null) {
        entry["image"] = await _encodeImageToBase64(
          controller.uploadedImages[id]!,
        );
      }
      // ✅ per-question location
      else if (type == 'location' && controller.detectedLocations[id] != null) {
        entry["location"] = {
          "lat": controller.detectedLocations[id]!["latitude"],
          "lon": controller.detectedLocations[id]!["longitude"],
        };
      }
      // ✅ text / remarks
      else if ((type == 'text' || type == 'remarks') &&
          controller.answers[id]?.isNotEmpty == true) {
        entry["answer_text"] = controller.answers[id];
      }
      // ✅ linear
      else if (type == 'linear' && controller.answers[id] != null) {
        entry["linear_value"] = controller.answers[id];
      }

      questionResponses.add(entry);
    }

    // ✅ Include the selected site_code (fixes wrong site in result)
    final selectedSiteCode =
        GetStorage().read('selected_site_code') ??
            (widget.surveyData['site_code'] ?? '');

    final body = jsonEncode({
      "survey": widget.surveyData['id'],
      "site_code": selectedSiteCode, // ✅ IMPORTANT
      "location_lat": controller.latitude.value.toString(),
      "location_lon": controller.longitude.value.toString(),
      "question_responses": questionResponses,
    });

    try {
      final res = await http.post(
        Uri.parse(
          "https://survey-backend.shwapno.app/survey/api/survey/submit-response/",
        ),
        headers: {
          "Authorization": "Bearer ${Get.find<AuthService>().getToken()}",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // ✅ clear state so returning shows a fresh form
        controller.resetAll();

        final responseJson = jsonDecode(res.body);
        final responseId = responseJson['response_id'];

        // (Optional helper for later reads; doesn’t affect UI/UX)
        GetStorage().write('response_site_code_$responseId', selectedSiteCode);

        Get.to(() => ResultScreen(responseId: responseId));
      } else {
        Get.snackbar("Error", "Error submitting survey: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Error submitting survey: $e");
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<String> _encodeImageToBase64(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    return base64Encode(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.surveyData['questions'] as List;

    return Scaffold(
      appBar: AppBar(title: Text(widget.surveyData['title'])),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) => buildQuestion(questions[index]),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: isSubmitting ? null : submitSurvey,
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Submit Survey'),
        ),
      ),
    );
  }
}
