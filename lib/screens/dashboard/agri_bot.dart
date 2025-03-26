import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/chart.dart';
import '../../services/chat_service.dart';
import '../../services/profile_service.dart';
import '../../services/shared_prefs_helper.dart';
import '../../services/detection_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/formatt_message.dart';

class SmartFarmAssistant extends StatefulWidget {
  const SmartFarmAssistant({Key? key}) : super(key: key);

  @override
  _SmartFarmAssistantState createState() => _SmartFarmAssistantState();
}

class _SmartFarmAssistantState extends State<SmartFarmAssistant> {
  final ChatModel _chatModel = ChatModel();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  final VisionApiService _visionService = VisionApiService();
  final GeminiApiService _geminiService = GeminiApiService();
  final FocusNode _focusNode = FocusNode();
  UserProfile? _userProfile;
  final UserProfileService _profileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadUserProfile();
  }

  Future<void> _loadChatHistory() async {
    await _chatModel.loadMessages();
    if (_chatModel.messages.isEmpty) {
      _addBotMessage("Hello! I'm your Smart Farm Assistant. I can help with farming advice and analyze plant health from photos. How can I assist you today?");
    } else {
      setState(() {});
    }
  }

  Future<void> _loadUserProfile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {

      final cachedProfile = await SharedPrefsHelper.getUserProfile();
      if (cachedProfile != null) {
        setState(() {
          _userProfile = cachedProfile;
        });
      }


      final profile = await _profileService.getUserProfile(currentUser.id, context);
      if (profile != null) {
        setState(() {
          _userProfile = profile;
        });

        await SharedPrefsHelper.saveUserProfile(profile);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    final message = _chatModel.addMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: false,
    );

    setState(() {});
    _scrollToBottom();
  }

  void _addUserMessage(String text, {String? imagePath}) {
    if (text.isEmpty && imagePath == null) return;

    final message = _chatModel.addMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      imagePath: imagePath,
    );

    setState(() {
      _textController.clear();
    });

    _scrollToBottom();

    if (imagePath != null) {
      _analyzeImage(File(imagePath));
    } else {
      _getAIResponse(text);
    }
  }

  void _scrollToBottom() {

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future _getAIResponse(String query) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {

      final response = await _geminiService.getResponse(query);

      setState(() {
        _isAnalyzing = false;
      });

      _addBotMessage(response);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _addBotMessage("Sorry, I encountered an error processing your request. Please try again.");
    }
  }

  Future _analyzeImage(File imageFile) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {

      final analysisData = await _visionService.detectCropCondition(imageFile);


      final response = await _geminiService.getResponse(
          "Analyze this plant/crop and provide farming advice. If there are any signs of disease, explain what the disease is and recommend treatment.",
          contextData: analysisData
      );

      setState(() {
        _isAnalyzing = false;
      });

      _addBotMessage(response);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _addBotMessage("Sorry, I couldn't analyze the image. Please try again or upload a clearer photo.");
    }
  }

  Future _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      _addUserMessage("", imagePath: image.path);
    }
  }

  Future _pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      _addUserMessage("", imagePath: image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.eco_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('AgriBot'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickGalleryImage,
            tooltip: 'Select from gallery',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Smart AgriBot'),
                  content: const Text(
                      'This AI assistant helps farmers with crop advice and disease detection. Upload photos of your crops for analysis or ask questions about farming practices.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [theme.colorScheme.surface, theme.colorScheme.background]
                : [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Analysis status indicator
            if (_isAnalyzing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: isDarkMode ? theme.colorScheme.surface : Colors.green.shade50,
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Analyzing your request...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Chat messages
            Expanded(
              child: _chatModel.messages.isEmpty
                  ? _buildEmptyStateWidget(context)
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                itemCount: _chatModel.messages.length,
                itemBuilder: (context, index) {
                  final message = _chatModel.messages[index];
                  return _buildMessageWidget(context, message, index);
                },
              ),
            ),

            // Input area
            _buildInputWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.eco_rounded,
              size: 40,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Smart Farming Assistant',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about farming or upload\na photo for plant health analysis',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(BuildContext context, Message message, int index) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isFirstMessage = index == 0 ||
        _chatModel.messages[index - 1].isUser != message.isUser;
    final showAvatar = isFirstMessage;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
        top: isFirstMessage ? 8 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar for bot messages
          if (!message.isUser && showAvatar)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.eco_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
            )
          else if (!message.isUser && !showAvatar)
            const SizedBox(width: 48)
          else if (message.isUser)
              const SizedBox(width: 0),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isFirstMessage && !message.isUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 2),
                    child: Text(
                      'AgriBot',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),

                GestureDetector(
                  onLongPress: () {
                    _showMessageOptions(context, message);
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? theme.primaryColor
                          : isDarkMode
                          ? theme.cardTheme.color
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image if present
                          if (message.imagePath != null)
                            Stack(
                              children: [
                                Image.file(
                                  File(message.imagePath!),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Analyzing',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),


                          if (message.text.isNotEmpty)
                            FormattedMessageContent(
                              message: message.text,
                              isUser: message.isUser,
                              theme: theme,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                  child: Text(
                    DateFormat.jm().format(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),


          if (message.isUser && showAvatar)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 12, top: 4),
              decoration: BoxDecoration(
                color: _userProfile?.profilePicture.isEmpty ?? true
                    ? theme.primaryColor.withOpacity(0.7)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _userProfile?.profilePicture.isNotEmpty ?? false
                  ? CachedNetworkImage(
                imageUrl: _userProfile!.profilePicture,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.primaryColor.withOpacity(0.7),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.primaryColor.withOpacity(0.7),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
                  : const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            )
          else if (message.isUser && !showAvatar)
            const SizedBox(width: 48)
          else if (!message.isUser)
              const SizedBox(width: 0),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, Message message) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: theme.primaryColor),
              title: const Text('Copy Text'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Message copied to clipboard'),
                    backgroundColor: theme.primaryColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (message.isUser)
              ListTile(
                leading: Icon(Icons.edit, color: theme.primaryColor),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditMessageDialog(context, message);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditMessageDialog(BuildContext context, Message message) {
    final TextEditingController editController = TextEditingController(text: message.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          minLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedText = editController.text.trim();
              if (updatedText.isNotEmpty) {

                final index = _chatModel.messages.indexWhere((m) => m.id == message.id);
                if (index != -1) {

                  final updatedMessage = Message(
                    id: message.id,
                    text: updatedText,
                    isUser: message.isUser,
                    timestamp: message.timestamp,
                    imagePath: message.imagePath,
                  );


                  setState(() {
                    _chatModel.messages[index] = updatedMessage;
                  });

                  // Save the updated messages
                  _chatModel.saveMessages();


                  if (index < _chatModel.messages.length - 1 && _chatModel.messages[index + 1].isUser == false) {
                    _getAIResponse(updatedText);
                  }
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      editController.dispose();
    });
  }

  Widget _buildInputWidget(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardTheme.color : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Camera button
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _pickImage,
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: theme.primaryColor,
                ),
                tooltip: 'Take a photo',
              ),
            ),
            const SizedBox(width: 12),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: theme.textTheme.bodyMedium,
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              _addUserMessage(text.trim());
                            }
                          },
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ),

                    // Send button
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Material(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            final text = _textController.text.trim();
                            if (text.isNotEmpty) {
                              _addUserMessage(text);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}