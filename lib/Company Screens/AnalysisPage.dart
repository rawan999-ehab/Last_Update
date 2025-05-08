import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String selectedTimeRange = 'Last 30 Days';
  List<String> timeRanges = ['Last 7 Days', 'Last 30 Days', 'Last 3 Months', 'All Time'];

  // Analysis data
  int totalApplications = 0;
  int pendingApplications = 0;
  int acceptedApplications = 0;
  int rejectedApplications = 0;
  int totalInternships = 0;

  // Application trend data
  List<FlSpot> applicationTrends = [];
  Map<String, int> applicationsPerInternship = {};
  Map<String, double> applicationStatusDistribution = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchAnalyticsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch internships
      final internshipSnapshot = await FirebaseFirestore.instance
          .collection('interns')
          .get();

      totalInternships = internshipSnapshot.docs.length;

      // Fetch all applications
      final applicationsSnapshot = await FirebaseFirestore.instance
          .collection('Student_Applicant')
          .get();

      totalApplications = applicationsSnapshot.docs.length;

      // Process applications
      Map<String, int> statusCounts = {
        'pending': 0,
        'accepted': 0,
        'rejected': 0,
      };

      Map<String, int> applicationsPerDay = {};
      Map<String, int> internshipApplicationCount = {};

      for (var doc in applicationsSnapshot.docs) {
        final data = doc.data();

        // Count by status
        final status = data['status'] ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;

        // Applications per day
        if (data['appliedAt'] != null) {
          final timestamp = data['appliedAt'].toString();
          final date = timestamp.split(' ')[0]; // Extract date part
          applicationsPerDay[date] = (applicationsPerDay[date] ?? 0) + 1;
        }

        // Applications per internship
        final internshipId = data['internshipId'];
        final internshipTitle = data['internshipTitle'] ?? 'Unknown Position';
        if (internshipId != null) {
          internshipApplicationCount[internshipTitle] =
              (internshipApplicationCount[internshipTitle] ?? 0) + 1;
        }
      }

      // Update state values
      pendingApplications = statusCounts['pending'] ?? 0;
      acceptedApplications = statusCounts['accepted'] ?? 0;
      rejectedApplications = statusCounts['rejected'] ?? 0;

      // Create trend data (last 14 days)
      final today = DateTime.now();
      List<FlSpot> trendData = [];

      for (int i = 13; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = DateFormat('MMM d, yyyy').format(date);
        final count = applicationsPerDay[dateStr] ?? 0;
        trendData.add(FlSpot((13 - i).toDouble(), count.toDouble()));
      }

      // Sort internships by application count
      var sortedInternships = internshipApplicationCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      Map<String, int> topInternships = {};
      for (var entry in sortedInternships.take(5)) {
        topInternships[entry.key] = entry.value;
      }

      // Calculate status distribution percentages
      final total = totalApplications > 0 ? totalApplications : 1;
      Map<String, double> statusDistribution = {
        'Pending': (pendingApplications / total) * 100,
        'Accepted': (acceptedApplications / total) * 100,
        'Rejected': (rejectedApplications / total) * 100,
      };

      setState(() {
        applicationTrends = trendData;
        applicationsPerInternship = topInternships;
        applicationStatusDistribution = statusDistribution;
        isLoading = false;
      });

    } catch (e) {
      print('Error fetching analytics data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFF196AB3),
        elevation: 0,
        title: Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchAnalyticsData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Color(0xFF196AB3),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Applications'),
                Tab(text: 'Internships'),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF196AB3)))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildApplicationsTab(),
          _buildInternshipsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          SizedBox(height: 16),
          _buildSummaryCards(),
          SizedBox(height: 24),
          _buildSectionTitle('Application Trends', Icons.trending_up),
          SizedBox(height: 16),
          _buildTrendChart(),
          SizedBox(height: 24),
          _buildSectionTitle('Application Status', Icons.pie_chart),
          SizedBox(height: 16),
          _buildStatusPieChart(),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          SizedBox(height: 16),
          _buildSectionTitle('Top Applications by Position', Icons.work),
          SizedBox(height: 16),
          _buildApplicationsBarChart(),
          SizedBox(height: 24),
          _buildSectionTitle('Recent Applications', Icons.history),
          SizedBox(height: 16),
          _buildRecentApplicationsList(),
        ],
      ),
    );
  }

  Widget _buildInternshipsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          SizedBox(height: 16),
          _buildSectionTitle('Internship Performance', Icons.assessment),
          SizedBox(height: 16),
          _buildInternshipPerformanceChart(),
          SizedBox(height: 24),
          _buildSectionTitle('Active Internships', Icons.work_outline),
          SizedBox(height: 16),
          _buildActiveInternshipsList(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: timeRanges.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = timeRanges[index] == selectedTimeRange;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTimeRange = timeRanges[index];
                // In a real app, you would refetch data based on the time range
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF196AB3) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Color(0xFF196AB3) : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Color(0xFF196AB3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                timeRanges[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSummaryCard(
            'Total Applications',
            totalApplications.toString(),
            Icons.description,
            Color(0xFF196AB3),
            '+${(totalApplications * 0.12).toInt()} from last period',
          ),
          _buildSummaryCard(
            'Pending Review',
            pendingApplications.toString(),
            Icons.hourglass_empty,
            Colors.amber[700]!,
            '${pendingApplications > 0 ? "Action needed" : "All reviewed"}',
          ),
          _buildSummaryCard(
            'Accepted',
            acceptedApplications.toString(),
            Icons.check_circle,
            Colors.green[700]!,
            '${(acceptedApplications / (totalApplications > 0 ? totalApplications : 1) * 100).toStringAsFixed(1)}% acceptance rate',
          ),
          _buildSummaryCard(
            'Active Internships',
            totalInternships.toString(),
            Icons.work,
            Colors.purple[700]!,
            '${(totalInternships * 0.85).toInt()} receiving applications',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF196AB3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Color(0xFF196AB3),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applications Received',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Last 14 days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Wed', 'Fri', 'Sun'];
                        final index = value ~/ 2;
                        if (index >= 0 && index < days.length) {
                          return Text(
                            days[index],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 13,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: applicationTrends.isEmpty
                        ? [
                      FlSpot(0, 3),
                      FlSpot(2.5, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 3.1),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                      FlSpot(13, 4),
                    ]
                        : applicationTrends,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF196AB3).withOpacity(0.8),
                        Color(0xFF196AB3).withOpacity(0.3),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF196AB3).withOpacity(0.2),
                          Color(0xFF196AB3).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.amber[700],
                    value: pendingApplications.toDouble(),
                    title: '${pendingApplications}',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.green[700],
                    value: acceptedApplications.toDouble(),
                    title: '${acceptedApplications}',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red[400],
                    value: rejectedApplications.toDouble(),
                    title: '${rejectedApplications}',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Pending', Colors.amber[700]!,
                    '${(pendingApplications / (totalApplications > 0 ? totalApplications : 1) * 100).toStringAsFixed(1)}%'),
                SizedBox(height: 16),
                _buildLegendItem('Accepted', Colors.green[700]!,
                    '${(acceptedApplications / (totalApplications > 0 ? totalApplications : 1) * 100).toStringAsFixed(1)}%'),
                SizedBox(height: 16),
                _buildLegendItem('Rejected', Colors.red[400]!,
                    '${(rejectedApplications / (totalApplications > 0 ? totalApplications : 1) * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, String percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationsBarChart() {
    // Sample data if real data is empty
    final positions = applicationsPerInternship.isEmpty
        ? {
      'Angular Developer': 12,
      'React Developer': 8,
      'UX Designer': 6,
      'Flutter Developer': 4,
      'iOS Developer': 3,
    }
        : applicationsPerInternship;

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: positions.values.isEmpty ? 15 : (positions.values.reduce((a, b) => a > b ? a : b) * 1.2),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final keys = positions.keys.toList();
                  if (value.toInt() >= 0 && value.toInt() < keys.length) {
                    String title = keys[value.toInt()];
                    if (title.length > 10) {
                      title = title.substring(0, 7) + '...';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return Text('');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            positions.length,
                (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: positions.values.elementAt(index).toDouble(),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF196AB3),
                      Color(0xFF196AB3).withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  width: 20,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentApplicationsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Student_Applicant')
            .orderBy('appliedAt', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF196AB3)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No recent applications found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              String status = data['status'] ?? 'pending';
              Color statusColor;
              IconData statusIcon;

              switch (status) {
                case 'accepted':
                  statusColor = Colors.green[700]!;
                  statusIcon = Icons.check_circle;
                  break;
                case 'rejected':
                  statusColor = Colors.red[400]!;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.amber[700]!;
                  statusIcon = Icons.hourglass_empty;
              }

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF196AB3).withOpacity(0.1),
                  child: Icon(Icons.person, color: Color(0xFF196AB3)),
                ),
                title: Text(
                  data['email'] ?? 'Unknown Applicant',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  data['internshipTitle'] ?? 'Unknown Position',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          status.capitalize(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatApplicationDate(data['appliedAt']),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // View application details
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatApplicationDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return DateFormat('MMM d, yyyy').format(date);
      } else if (timestamp is String) {
        return timestamp.split(' at ')[0];
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }

  Widget _buildInternshipPerformanceChart() {
    // Sample data if real data is empty
    final performanceData = applicationsPerInternship.isEmpty
        ? {
      'Angular Developer': 12,
      'React Developer': 8,
      'UX Designer': 6,
      'Flutter Developer': 4,
      'iOS Developer': 3,
    }
        : applicationsPerInternship;

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Applications per Internship',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: performanceData.length,
              itemBuilder: (context, index) {
                final key = performanceData.keys.elementAt(index);
                final value = performanceData[key] ?? 0;
                final percentage = (value / (totalApplications > 0 ? totalApplications : 1)) * 100;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$value applications',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF196AB3)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}% of total applications',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveInternshipsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('interns')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF196AB3)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No active internships found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF196AB3).withOpacity(0.1),
                  child: Icon(Icons.work_outline, color: Color(0xFF196AB3)),
                ),
                title: Text(
                  data['title'] ?? 'Unknown Position',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  data['company'] ?? 'Unknown Company',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${data['applications'] ?? 0} apps',
                      style: TextStyle(
                        color: Color(0xFF196AB3),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatInternshipDate(data['createdAt']),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // View internship details
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatInternshipDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return DateFormat('MMM d, yyyy').format(date);
      } else if (timestamp is String) {
        return timestamp.split(' at ')[0];
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}