import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For timestamp formatting

class MessagesScreen extends StatefulWidget {
  final List messages;
  const MessagesScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.separated(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      itemBuilder: (context, index) {
        final message = widget.messages[index]['message'];
        final isUserMessage = widget.messages[index]['isUserMessage'];
        final timestamp = widget.messages[index]['timestamp'];

        // Format the timestamp in 12-hour format with AM/PM
        final formattedTime = DateFormat('hh:mm a').format(timestamp);

        return Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUserMessage) // Show chatbot logo only for bot messages
                Icon(
                  Icons.smart_toy,
                  // Use a chatbot logo icon (e.g., Android icon)
                  color: Colors.lightBlue.shade700,
                  size: 30,
                ),
              SizedBox(width: 8), // Space between icon and message
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomRight: Radius.circular(isUserMessage ? 0 : 20),
                    topLeft: Radius.circular(isUserMessage ? 20 : 0),
                  ),
                  color: isUserMessage
                      ? Colors.white // User message color
                      : Colors.lightBlue.shade700, // Bot message color
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxWidth: w * 2 / 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text.text[0],
                      style: TextStyle(
                        color: isUserMessage
                            ? Colors.black // User message text color
                            : Colors.white, // Bot message text color
                      ),
                    ),
                    SizedBox(height: 4), // Space between message and timestamp
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: isUserMessage ? Colors.grey : Colors.white70,
                        fontSize: 10, // Small font size for the timestamp
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, i) => const Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: widget.messages.length,
    );
  }
}