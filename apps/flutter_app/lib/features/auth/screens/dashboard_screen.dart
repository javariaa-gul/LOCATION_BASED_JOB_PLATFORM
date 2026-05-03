import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'job_post_screen.dart';
import '../controllers/job_controller.dart';

class DashboardController extends GetxController {
  // 0 = Home, 1 = Jobs, 2 = Profile
  var selectedIndex = 0.obs;
  var isPoster = true.obs;

  void toggleRole() {
    isPoster.value = !isPoster.value;
  }
}

class DashboardScreen extends StatelessWidget {
  // Dono controllers ko initialize kar rahe hain
  final dashboardController = Get.put(DashboardController());
  final jobController = Get.put(JobController()); // Job list yahan se aaye gi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            dashboardController.isPoster.value
                ? 'Poster Dashboard'
                : 'Seeker Dashboard',
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Role Switch Toggle
          Row(
            children: [
              Text(
                "Switch Role",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              Obx(
                () => Switch(
                  value: dashboardController.isPoster.value,
                  onChanged: (val) => dashboardController.toggleRole(),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        // Role ke mutabiq layout switch
        return dashboardController.isPoster.value
            ? _buildPosterLayout()
            : _buildSeekerLayout();
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: dashboardController.selectedIndex.value,
          onTap: (index) => dashboardController.selectedIndex.value = index,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => dashboardController.isPoster.value
            ? FloatingActionButton.extended(
                onPressed: () => Get.to(() => JobPostScreen()),
                label: Text("Post a Job"),
                icon: Icon(Icons.add),
                backgroundColor: Colors.blueAccent,
              )
            : Container(),
      ),
    );
  }

  // --- Poster View Layout (Ab Dynamic Hai) ---
  Widget _buildPosterLayout() {
    return Obx(() {
      final jobs = jobController.activeJobs;

      return ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Stat Card ab real count dikhaye ga
          _buildStatCard("Active Postings", "${jobs.length}", Colors.blue),

          SizedBox(height: 24),

          Text(
            "Your Recent Posts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          if (jobs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Icon(Icons.post_add, size: 50, color: Colors.grey),
                    Text(
                      "Aapne abhi tak koi job post nahi ki.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            // Job list cards
            ...jobs
                .map(
                  (job) => Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        child: Icon(Icons.handyman, color: Colors.blueAccent),
                      ),
                      title: Text(
                        job['title'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Price: Rs. ${job['priceValue']} (${job['priceType']})",
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        // Baad mein detail screen par jane ke liye
                      },
                    ),
                  ),
                )
                .toList(),
        ],
      );
    });
  }

  // Seeker View Layout
  Widget _buildSeekerLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style, size: 100, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text(
            "Jobs stack yahan nazar aayega",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            "(Tinder-style cards coming soon!)",
            style: TextStyle(fontSize: 12, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
