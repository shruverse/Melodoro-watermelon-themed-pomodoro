import 'package:flutter/material.dart';
import '../models/study_session.dart';
import '../widgets/time_blocks_widget.dart';

class StatsBlocksScreen extends StatefulWidget {
  final List<StudySession> sessions;

  const StatsBlocksScreen({super.key, required this.sessions});

  @override
  State<StatsBlocksScreen> createState() => _StatsBlocksScreenState();
}

class _StatsBlocksScreenState extends State<StatsBlocksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final headerFontSize = isSmallScreen ? 24.0 : 28.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(padding),
            child: Text(
              '🍉 Study Stats',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),

          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFD81B60),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Day'),
                Tab(text: 'Month'),
                Tab(text: 'Year'),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildDayView(), _buildMonthView(), _buildYearView()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    return TimeBlocksWidget(
      sessions: widget.sessions,
      selectedDate: _selectedDate,
      viewType: TimeBlockViewType.day,
      onDateChanged: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget _buildMonthView() {
    return TimeBlocksWidget(
      sessions: widget.sessions,
      selectedDate: _selectedDate,
      viewType: TimeBlockViewType.month,
      onDateChanged: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget _buildYearView() {
    return TimeBlocksWidget(
      sessions: widget.sessions,
      selectedDate: _selectedDate,
      viewType: TimeBlockViewType.year,
      onDateChanged: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }
}
