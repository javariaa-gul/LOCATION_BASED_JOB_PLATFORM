import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';

class JobController extends GetxController {
  // Observables
  var activeJobs = [].obs;
  var isLoading = false.obs;

  final ApiService _apiService = ApiService();

  // 1. Controller bante hi jobs fetch karega
  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  // 2. Database se saari jobs mangwane ka function
  Future<void> fetchJobs() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getAllJobs();

      if (response.statusCode == 200) {
        // Backend se aane wali list ko observable list mein assign karna
        activeJobs.assignAll(response.data);
      }
    } catch (e) {
      debugPrint("Fetch Jobs Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Nayi job post karne ka function
  void postJob(Map<String, dynamic> jobData) async {
    try {
      isLoading.value = true;

      final response = await _apiService.postJob(jobData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success ke baad dobara fetch karein taake list update ho jaye
        await fetchJobs();

        Get.back(); // Screen close karein
        Get.snackbar(
          "Success",
          "Job posted successfully!",
          backgroundColor: Colors.green.withOpacity(0.1),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Backend Error",
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.1),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
