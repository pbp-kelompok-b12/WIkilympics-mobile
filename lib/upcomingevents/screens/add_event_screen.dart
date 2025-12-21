import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;

  void _submitForm() async {
    final request = context.read<CookieRequest>();

    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final response = await request.post(
        'http://127.0.0.1:8000/upcoming_event/create-event-flutter/',
        {
          'name': _eventNameController.text,
          'organizer': _organizerController.text,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'location': _locationController.text,
          'sport_branch': _sportController.text,
          'image_url': _photoUrlController.text,
          'description': _descriptionController.text,
        },
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("New event successfully added!")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${response['message'] ?? 'Something wrong'}")),
          );
        }
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // WIDGET LABEL
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: const Color(0xFF03045E),
        ),
      ),
    );
  }

  // WIDGET TEXT FIELD
  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontStyle: isOptional ? FontStyle.italic : FontStyle.normal,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF03045E), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF03045E), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: isOptional ? null : (value) => value == null || value.isEmpty ? "Cannot be empty" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Upcoming Event',
          style: GoogleFonts.poppins(
            color: const Color(0xFF03045E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Event name:"),
                  _buildTextField(_eventNameController, "Enter event name"),

                  _buildLabel("Organizer:"),
                  _buildTextField(_organizerController, "Enter organizer name"),

                  _buildLabel("Date:"),
                  TextFormField(
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      hintText: _selectedDate == null ? 'dd/mm/yyyy' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                      suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF03045E)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF03045E), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF03045E), width: 2.0),
                      ),
                    ),
                    validator: (value) => _selectedDate == null ? 'Date is required' : null,
                  ),

                  _buildLabel("Location:"),
                  _buildTextField(_locationController, "Enter location"),

                  _buildLabel("Sport:"),
                  _buildTextField(_sportController, "Enter sport category"),

                  _buildLabel("Photo URL (Optional):"),
                  _buildTextField(_photoUrlController, "https://example.com/image.jpg", isOptional: true),

                  _buildLabel("Description:"),
                  _buildTextField(_descriptionController, "Write description...", maxLines: 4),

                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF378355),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        "SAVE",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
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