import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

void showDiasporaRegistrationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RegistrationSheet(),
  );
}

class _RegistrationSheet extends StatefulWidget {
  const _RegistrationSheet();

  @override
  State<_RegistrationSheet> createState() => _RegistrationSheetState();
}

class _RegistrationSheetState extends State<_RegistrationSheet> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  bool _submitted = false;
  bool _submitting = false;

  // Page 1 - Personal Info
  final _fullNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String _gender = 'Male';
  final _nationalIdCtrl = TextEditingController();

  // Page 2 - Location
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Page 3 - Professional
  final _professionCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  String _reason = 'Work/Employment';

  final _reasons = [
    'Work/Employment',
    'Education/Study',
    'Family/Marriage',
    'Refugee/Asylum',
    'Business',
    'Retirement',
    'Other',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fullNameCtrl.dispose();
    _dobCtrl.dispose();
    _nationalIdCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _professionCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      _submit();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ApiClient.instance.submitDiasporaRegistration(
        fullName: _fullNameCtrl.text,
        dateOfBirth: _dobCtrl.text,
        gender: _gender,
        nationalId: _nationalIdCtrl.text,
        country: _countryCtrl.text,
        city: _cityCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        profession: _professionCtrl.text,
        yearsAbroad: _yearsCtrl.text,
        reasonForDiaspora: _reason,
      );
      if (mounted) setState(() { _submitted = true; _submitting = false; });
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission failed. Please check your connection and try again.'),
            backgroundColor: Color(0xFFB91C1C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),

            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.ugandaYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.how_to_reg_rounded, color: AppColors.ugandaYellow, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Diaspora Registration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                        Text('Official Uganda Diaspora Registry', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            if (_submitted)
              Expanded(child: _buildSuccess())
            else ...[
              // Progress indicators
              _buildProgressBar(),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPage1(scrollCtrl),
                    _buildPage2(scrollCtrl),
                    _buildPage3(scrollCtrl),
                  ],
                ),
              ),

              // Bottom nav
              _buildBottomNav(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final labels = ['Personal', 'Contact', 'Professional'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _currentPage;
          final isDone = i < _currentPage;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDone ? AppColors.ugandaRed : isActive ? Colors.black : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : Text('${i + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          if (i < 2)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isDone ? AppColors.ugandaRed : Colors.grey.shade200,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1(ScrollController ctrl) {
    return SingleChildScrollView(
      controller: ctrl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal Information'),
          const SizedBox(height: 16),
          _field('Full Name', _fullNameCtrl, hint: 'As on your passport/ID'),
          const SizedBox(height: 14),
          _field('Date of Birth', _dobCtrl, hint: 'DD/MM/YYYY', keyboardType: TextInputType.datetime),
          const SizedBox(height: 14),
          _label('Gender'),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Prefer not to say'].map((g) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _gender = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _gender == g ? Colors.black : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    g,
                    style: TextStyle(
                      color: _gender == g ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),
          _field('Passport / National ID Number', _nationalIdCtrl, hint: 'e.g. AA123456'),
          const SizedBox(height: 8),
          _infoBox('Your data is protected under the Uganda Data Protection Act 2019. This registration is for official government diaspora records only.'),
        ],
      ),
    );
  }

  Widget _buildPage2(ScrollController ctrl) {
    return SingleChildScrollView(
      controller: ctrl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Contact & Location'),
          const SizedBox(height: 16),
          _field('Country of Residence', _countryCtrl, hint: 'e.g. United Kingdom'),
          const SizedBox(height: 14),
          _field('City / State', _cityCtrl, hint: 'e.g. London'),
          const SizedBox(height: 14),
          _field('Phone Number', _phoneCtrl, hint: '+44 7700 000000', keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))]),
          const SizedBox(height: 14),
          _field('Email Address', _emailCtrl, hint: 'your@email.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 8),
          _infoBox('Your contact details will be used to send official communications from the Uganda government about diaspora programmes.'),
        ],
      ),
    );
  }

  Widget _buildPage3(ScrollController ctrl) {
    return SingleChildScrollView(
      controller: ctrl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Professional Information'),
          const SizedBox(height: 16),
          _field('Occupation / Profession', _professionCtrl, hint: 'e.g. Software Engineer, Doctor'),
          const SizedBox(height: 14),
          _field('Years Living Abroad', _yearsCtrl, hint: 'e.g. 5', keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 14),
          _label('Primary Reason for Being in Diaspora'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons.map((r) => GestureDetector(
              onTap: () => setState(() => _reason = r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _reason == r ? Colors.black : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _reason == r ? Colors.black : Colors.grey.shade200),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    color: _reason == r ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: _reason == r ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ugandaYellow.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.ugandaYellow, size: 18),
                    const SizedBox(width: 8),
                    const Text('Declaration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'I declare that all information provided is true and accurate. I understand that providing false information is an offence under Ugandan law.',
                  style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitting ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage == 2 ? AppColors.ugandaRed : Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting && _currentPage == 2
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      _currentPage == 2 ? 'Submit Registration' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Registration Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(
              'Thank you, ${_fullNameCtrl.text.isNotEmpty ? _fullNameCtrl.text.split(' ').first : 'Ugandan'}!\n\nYour diaspora registration has been submitted successfully. You will receive a confirmation email at ${_emailCtrl.text.isNotEmpty ? _emailCtrl.text : 'your email address'} within 48 hours.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondaryLight, height: 1.6, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ugandaYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ugandaYellow.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.ugandaYellow, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Keep your registration reference number for future correspondence.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.ugandaYellow, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  Widget _field(String label, TextEditingController ctrl, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 11.5, color: Colors.blue.shade800, height: 1.5))),
        ],
      ),
    );
  }
}
