// lib/features/auth/screens/job_post_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/job_controller.dart';

class JobPostScreen extends StatefulWidget {
  @override
  _JobPostScreenState createState() => _JobPostScreenState();
}

class _JobPostScreenState extends State<JobPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final JobController jobController = Get.find<JobController>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // Location ke liye

  // Default values
  String _priceType = 'FIXED';
  String _genderPreference = 'ANY';
  bool _isRemote = false;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post a New Job"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Job Details"),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Job Title (e.g. AC Repair)",
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (v) => v!.isEmpty ? "Title is required" : null,
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Description is required" : null,
              ),
              SizedBox(height: 20),

              _buildSectionTitle("Location & Matching"),
              // Location Field with Toggle Logic
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Work Location",
                  hintText: "Enter area or use live location",
                  prefixIcon: Icon(Icons.location_on, color: Colors.redAccent),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: () {
                      // Yahan Geolocator integrate hoga
                      _locationController.text = "Detecting live location...";
                      // For now static placeholder for testing
                      Future.delayed(Duration(seconds: 1), () {
                        setState(
                          () => _locationController.text =
                              "Gulshan-e-Iqbal, Karachi",
                        );
                      });
                    },
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? "Location is vital for AI matching" : null,
              ),
              SizedBox(height: 10),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Is this a Remote/Online job?"),
                subtitle: Text(
                  "Will skip physical location matching if enabled",
                ),
                value: _isRemote,
                onChanged: (v) => setState(() => _isRemote = v),
              ),
              SizedBox(height: 15),

              _buildSectionTitle("Budget & Timing"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Budget (Rs.)",
                        prefixText: "PKR ",
                      ),
                      validator: (v) => v!.isEmpty ? "Enter price" : null,
                    ),
                  ),
                  SizedBox(width: 15),
                  DropdownButton<String>(
                    value: _priceType,
                    items: ['FIXED', 'HOURLY']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _priceType = v!),
                  ),
                ],
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: "Estimated Duration",
                  hintText: "e.g. 3 days or 2 hours",
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
                title: Text("Expected Start Date"),
                subtitle: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              SizedBox(height: 20),

              _buildSectionTitle("Worker Preference"),
              Wrap(
                spacing: 10,
                children: [
                  _buildChoiceChip("Any"),
                  _buildChoiceChip("Male"),
                  _buildChoiceChip("Female"),
                ],
              ),

              SizedBox(height: 40),

              // Post Button with State handling
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: jobController.isLoading.value
                        ? null
                        : _submitJob,
                    child: jobController.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Submit Job Posting",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _genderPreference == label.toUpperCase(),
      onSelected: (s) =>
          setState(() => _genderPreference = label.toUpperCase()),
      selectedColor: Colors.blueAccent.withOpacity(0.2),
      checkmarkColor: Colors.blueAccent,
    );
  }

  void _submitJob() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> jobData = {
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "priceValue": double.tryParse(_priceController.text) ?? 0.0,
        "priceType": _priceType.toUpperCase(),
        "genderPreference": _genderPreference.toUpperCase(),

        "isRemote": _isRemote,
        "address": _locationController.text.trim(),
        "expectedDuration": _durationController.text.trim(),
        "startTime": _selectedDate.toIso8601String(),
      };

      // Controller ko call karein
      Get.find<JobController>().postJob(jobData);
    }
  }
}
