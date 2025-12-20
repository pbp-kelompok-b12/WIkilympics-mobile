import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wikilympics/landingpoll/models/poll_model.dart';

class PollFormPage extends StatefulWidget {
  final PollQuestion? poll; // Null = Mode Add, Ada Isi = Mode Edit

  const PollFormPage({super.key, this.poll});

  @override
  State<PollFormPage> createState() => _PollFormPageState();
}

class _PollFormPageState extends State<PollFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();

  // List Controller untuk Opsi Jawaban (Supaya Dinamis)
  List<TextEditingController> _optionControllers = [];

  // --- Definisi Warna ---
  final Color _backgroundColor = const Color(0xFFF8F9FA); // Abu muda background
  final Color _cardColor = Colors.white;
  final Color _primaryTextColor = const Color(0xFF03045E); // Navy Tua
  final Color _borderColor = const Color(0xFF5C6BC0);
  final Color _accentColor = const Color(0xFFC8DB2C); // Lime Green

  @override
  void initState() {
    super.initState();
    if (widget.poll != null) {
      // MODE EDIT: Isi data dari yang sudah ada
      _questionController.text = widget.poll!.questionText;
      for (var option in widget.poll!.options) {
        _optionControllers.add(TextEditingController(text: option.optionText));
      }
    } else {
      // MODE ADD: Default kasih 2 kolom opsi kosong
      _optionControllers.add(TextEditingController());
      _optionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOptionField(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor.withOpacity(0.5), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryTextColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.poll != null;

    return Scaffold(
      backgroundColor: _backgroundColor,

      // --- APP BAR DENGAN LOGO ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Logo di tengah
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        // Logo Wikilympics
        title: Image.asset(
          'assets/wikilympics_banner.png',
          height: 32, // Ukuran disesuaikan agar rapi
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            // --- CARD FORM ---
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // JUDUL FORM
                  Center(
                    child: Text(
                      isEdit ? "Edit Poll" : "Create New Poll",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Fill in the details below",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // INPUT QUESTION
                  Text(
                    "Question",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: _primaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _questionController,
                    maxLines: 2,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                    decoration: _buildInputDecoration("e.g. Siapa atlet favoritmu?"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 24),

                  // HEADER OPTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Options",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: _primaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: _addOptionField,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.add_circle, color: _primaryTextColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Add Option",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryTextColor
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // DYNAMIC INPUT OPTIONS
                  ..._optionControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    TextEditingController controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                              decoration: _buildInputDecoration("Option ${index + 1}"),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: InkWell(
                                onTap: () => _removeOptionField(index),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.delete_rounded, color: Colors.red[400], size: 20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // TOMBOL SAVE
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          List<String> options = _optionControllers
                              .map((c) => c.text.trim())
                              .where((text) => text.isNotEmpty)
                              .toList();

                          if (options.length < 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Minimal harus ada 2 opsi jawaban!")),
                            );
                            return;
                          }

                          final url = isEdit
                              ? "http://127.0.0.1:8000/landingpoll/edit/${widget.poll!.id}/"
                              : "http://127.0.0.1:8000/landingpoll/create/";

                          try {
                            final response = await request.post(url, {
                              'question': _questionController.text,
                              'options': jsonEncode(options),
                            });

                            if (response['status'] == 'success') {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Poll saved successfully!")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${response['message']}")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error connection: $e")),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: _primaryTextColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: _accentColor.withOpacity(0.4),
                      ),
                      child: Text(
                        "SAVE POLL",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}