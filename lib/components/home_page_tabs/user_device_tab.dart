import 'package:flutter/material.dart';
import 'package:wifi_app/components/user_device_tab_forms/subject_form.dart';
import '../user_device_tab_forms/device_form.dart';

class UserDeviceTab extends StatefulWidget {
  const UserDeviceTab({super.key});

  @override
  State<UserDeviceTab> createState() => _UserDeviceTabState();
}

class _UserDeviceTabState extends State<UserDeviceTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device. form.
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Device",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DeviceForm(),
            SizedBox(height: 24.0),
            // User form.
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "User",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SubjectForm(),
          ],
        ),
      ),
    );
  }
}
