import 'package:contacts/add_contact.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<CallLogEntry> _callLogs = [];
  List<CallLogEntry> _filteredLogs = [];
  bool _permissionDenied = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter state
  CallType? _selectedFilter; // null means All

  // Grouped logs by date label
  Map<String, List<CallLogEntry>> _groupedLogs = {};

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
    _searchController.addListener(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _callLogs.where((log) {
        if (_selectedFilter != null && log.callType != _selectedFilter) {
          return false;
        }
        final name = log.name?.toLowerCase() ?? '';
        final number = log.number?.toLowerCase() ?? '';
        return name.contains(_searchQuery) || number.contains(_searchQuery);
      }).toList();

      _groupedLogs = _groupCallLogsByDate(_filteredLogs);
    });
  }

  Future<void> _fetchCallLogs() async {
    var status = await Permission.phone.request();

    if (status.isGranted) {
      Iterable<CallLogEntry> entries = await CallLog.get();
      setState(() {
        _callLogs = entries.toList();
        _permissionDenied = false;
      });
      _applyFilters();
    } else {
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  Map<String, List<CallLogEntry>> _groupCallLogsByDate(List<CallLogEntry> logs) {
    Map<String, List<CallLogEntry>> grouped = {};
    final now = DateTime.now();

    for (var log in logs) {
      if (log.timestamp == null) continue;

      final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp!);
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;

      String label;
      if (difference == 0) {
        label = 'Today';
      } else if (difference == 1) {
        label = 'Yesterday';
      } else {
        label = DateFormat('dd MMM yyyy').format(date);
      }

      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(log);
    }

    // Sort groups by date descending (Today first, then Yesterday, then others)
    var sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Yesterday') return -1;
        if (b == 'Yesterday') return 1;
        // Parse dates for other labels
        DateTime dateA = DateFormat('dd MMM yyyy').parse(a);
        DateTime dateB = DateFormat('dd MMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    Map<String, List<CallLogEntry>> sortedGrouped = {};
    for (var key in sortedKeys) {
      // Sort each group by timestamp descending (most recent first)
      grouped[key]!.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  IconData _getCallTypeIcon(CallType? type) {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
      case CallType.rejected:
        return Icons.call_end;
      case CallType.blocked:
        return Icons.block;
      case CallType.voiceMail:
        return Icons.voicemail;
      default:
        return Icons.phone;
    }
  }

  Color _getCallTypeColor(CallType? type) {
    switch (type) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
      case CallType.rejected:
        return Colors.orange;
      case CallType.blocked:
        return Colors.black;
      case CallType.voiceMail:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return "Unknown";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('hh:mm a').format(date);
  }

  Widget _buildFilterButton(String label, CallType? type) {
    final bool isSelected = _selectedFilter == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blue,
        onSelected: (_) {
          setState(() {
            if (_selectedFilter == type) {
              _selectedFilter = null;
            } else {
              _selectedFilter = type;
            }
          });
          _applyFilters();
        },
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      appBar: AppBar(
        leading: Icon(Icons.phone, color: Colors.blue,),
        title: const Text('Recent Calls'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: _permissionDenied
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 10),
                  const Text(
                    "Permission Denied",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchCallLogs,
                    label: const Text("Retry"),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      
                          decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      hintText: 'Search contacts',
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    ),
                  ),
                ),

                // Filter buttons
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _buildFilterButton("All", null),
                      _buildFilterButton("Missed", CallType.missed),
                      _buildFilterButton("Incoming", CallType.incoming),
                      _buildFilterButton("Outgoing", CallType.outgoing),
                      _buildFilterButton("Rejected", CallType.rejected),
                      _buildFilterButton("Blocked", CallType.blocked),
                      _buildFilterButton("Voicemail", CallType.voiceMail),
                    ],
                  ),
                ),

                // Call logs list grouped by day
                Expanded(
                  child: _filteredLogs.isEmpty
                      ? const Center(
                          child: Text(
                            "No call logs found",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          color: Colors.green,
                          onRefresh: _fetchCallLogs,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: _groupedLogs.entries.expand((entry) {
                              final dateLabel = entry.key;
                              final logs = entry.value;

                              return [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Text(
                                    dateLabel,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...logs.map((log) => Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor:
                                                  _getCallTypeColor(log.callType),
                                              child: Icon(
                                                _getCallTypeIcon(log.callType),
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    log.name ??
                                                        log.number ??
                                                        "Unknown",
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (log.number != null)
                                                    Text(
                                                      log.number!,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  if (log.timestamp != null)
                                                    Text(
                                                      _formatDate(log.timestamp),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                  GestureDetector(
                                                  onTap: () {
                                                   Navigator.push(context, MaterialPageRoute(builder: (context)=> 
                                                   ContactInsertPage(
                                                    name: log.name ?? '',
                                                    contact: log.number ?? '',
                                                   )));
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/share.png',
                                                    width: 35,
                                                    height: 35,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () {
                                                    openWhatsApp(
                                                      phoneNumber: log.number ?? '',
                                                      message: '',
                                                    );
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/whatsapp.png',
                                                    width: 35,
                                                    height: 35,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () {
                                                    launchSMS(
                                                        phoneNumber: log.number ?? "");
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/message.png',
                                                    width: 35,
                                                    height: 35,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ];
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  void openWhatsApp({required String phoneNumber, required String message}) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  void launchSMS({required String phoneNumber}) async {
    final Uri smsUrl = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch SMS to $phoneNumber')),
      );
    }
  }
}
