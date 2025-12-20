import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikilympics/upcomingevents/models/events_entry.dart';

class EditEventScreen extends StatefulWidget {
  final EventEntry event;
  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController, _organizerController, _locationController, _sportController, _photoUrlController, _descriptionController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.event.name);
    _organizerController = TextEditingController(text: widget.event.organizer);
    _locationController = TextEditingController(text: widget.event.location);
    _sportController = TextEditingController(text: widget.event.sportBranch);
    _photoUrlController = TextEditingController(text: widget.event.imageUrl);
    _descriptionController = TextEditingController(text: widget.event.description);
    _selectedDate = widget.event.date;
  }

  void _submitForm() async {
    final request = context.read<CookieRequest>();
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final response = await request.post(
        'http://127.0.0.1:8000/upcoming_event/edit-event-flutter/${widget.event.id}/',
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
        if (response['status'] == 'success' || response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Event updated successfully!", style: GoogleFonts.poppins()), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response['message']}")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Event', style: GoogleFonts.poppins(color: const Color(0xFF03045E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Event Name"),
                  _buildTextField(_eventNameController, "Enter name"),
                  _buildLabel("Organizer"),
                  _buildTextField(_organizerController, "Enter organizer"),
                  _buildLabel("Date"),
                  TextFormField(
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    decoration: InputDecoration(
                      hintText: _selectedDate == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF03045E)),
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF03045E)), borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF03045E), width: 2), borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  _buildLabel("Sport"),
                  _buildTextField(_sportController, "Enter sport category"),
                  _buildLabel("Location"),
                  _buildTextField(_locationController, "Enter location"),
                  _buildLabel("Photo URL (Optional)"),
                  _buildTextField(_photoUrlController, "https://example.com/image.jpg",
                  isOptional: true,
                  ),
                  _buildLabel("Description"),
                  _buildTextField(_descriptionController, "Write description", maxLines: 4),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF378355),
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: Text("UPDATE EVENT", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF03045E))),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isOptional = false}) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    // Validator untuk mengecek apakah field ini opsional atau tidak
    validator: (value) {
      if (isOptional) return null;
      if (value == null || value.isEmpty) {
        return "Field cannot be empty";
      }
      return null;
    },
    decoration: InputDecoration(
      hintText: hint,
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF03045E)), borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF03045E), width: 2), borderRadius: BorderRadius.circular(12)),
    ),
  );
}