import 'package:flutter/material.dart';

class PregnancyInfo extends StatelessWidget {
  final Map<String, dynamic> pregnancyData;

  const PregnancyInfo({super.key, required this.pregnancyData});

  @override
  Widget build(BuildContext context){
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text('Current Week'),
            subtitle: Text('Week ${pregnancyData['currentWeek']}'),
            leading: Icon(Icons.calendar_today),
          ),
        ),
        
        Card(
          child: ListTile(
            title: Text('Baby Size'),
            subtitle: Text(pregnancyData['babySize']),
            leading: Icon(Icons.child_care),
          ),
        ),

        Card(
          child: ListTile(
            title: Text('Due Date'),
            subtitle: Text(DateTime.parse(pregnancyData['dueDate']).toString().split(' ')[0]),
            leading: Icon(Icons.event),
          ),
        ),

        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Weekly Tips'),
                leading: Icon(Icons.lightbulb),
              ),
              ...pregnancyData['weeklyTips'].map((tip) => 
              Padding(padding: 
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('. $tip')
              ) ).toList(),
            ],
          ),
        ),
      ], 
    );
  }

}


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class Pregnancytracker extends StatelessWidget{
//   final int currentWeek;
//   final String babySize;
//   final List<String> weeklyTips;
//   final DateTime dueDate;
//   final double babyHeight;
//   final double babyWeight;

//   const Pregnancytracker({
//     super.key,
//     required this.currentWeek,
//     required this.babySize,
//     required this.weeklyTips,
//     required this.dueDate,
//     required this.babyHeight,
//     required this.babyWeight,
//   });

//   int get _daysLeft{
//     return dueDate.difference(DateTime.now()).inDays;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildWeekProgress(context),
//         const SizedBox(height: 16),
//         _buildBabyCard(context),
//         const SizedBox(height: 16),
//         _buildTipsCard(context),
//       ],
//     );
//   }

//   Widget _buildWeekProgress(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Week $currentWeek of 40',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 8),
//             LinearProgressIndicator(
//               value: currentWeek / 40,
//               backgroundColor: Colors.grey[200],
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Due Date: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBabyCard(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               child: const Icon(Icons.child_care, color: Colors.white, size: 36),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Your baby is the size of a $babySize',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildInfoColumn(context, 'Baby Height', '${babyHeight.toStringAsFixed(1)} cm'),
//                 _buildInfoColumn(context, 'Baby Weight', '${babyWeight.toStringAsFixed(0)} gr'),
//                 _buildInfoColumn(context, 'Days Left', '$_daysLeft days'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTipsCard(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Weekly Tips',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 8),
//             ...weeklyTips.map((tip) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle,
//                       color: Theme.of(context).colorScheme.primary),
//                   const SizedBox(width: 8),
//                   Expanded(child: Text(tip)),
//                 ],
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoColumn(BuildContext context, String label, String value) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }
// }