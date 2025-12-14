import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_feeds/stream_feeds.dart';

class ActivityComposer extends StatefulWidget {
  const ActivityComposer({super.key, required this.userFeed});

  final Feed userFeed;

  @override
  State<ActivityComposer> createState() => _ActivityComposerState();
}

class _ActivityComposerState extends State<ActivityComposer> {
  final TextEditingController _controller = TextEditingController();
  StreamAttachment? _attachment;
  bool _hasText = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (_hasText != hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'What is happening?',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          if (_attachment != null)
            Image.file(File(_attachment!.file.path), height: 100, width: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  _pickImage();
                },
                icon: Icon(Icons.image_outlined),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _hasText && !_isSending ? _createActivity : null,
                child: Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createActivity() async {
    setState(() => _isSending = true);
    await widget.userFeed.addActivity(
      request: FeedAddActivityRequest(
        feeds: [widget.userFeed.fid.toString()],
        type: 'post',
        text: _controller.text,
        attachmentUploads: _attachment != null ? [_attachment!] : null,
      ),
    );
    _controller.clear();
    setState(() {
      _attachment = null;
      _isSending = false;
    });
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final attachment = StreamAttachment(
        type: AttachmentType.image,
        file: AttachmentFile.fromXFile(image),
      );
      setState(() => _attachment = attachment);
    }
  }
}
