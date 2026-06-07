import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';

class TourismDetailScreen extends StatefulWidget {
  final int id;
  const TourismDetailScreen({super.key, required this.id});

  @override
  State<TourismDetailScreen> createState() => _TourismDetailScreenState();
}

class _TourismDetailScreenState extends State<TourismDetailScreen> {
  Map<String, dynamic>? _attr;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getTourismById(widget.id);
      if (mounted) setState(() { _attr = Map<String, dynamic>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isHotel =>
      (_attr?['category'] ?? '').toString().toLowerCase().contains('hotel');

  void _showBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _HotelBookingSheet(hotelName: _attr?['name'] ?? 'Hotel'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      bottomNavigationBar: (!_loading && _attr != null && _isHotel)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: _showBookingSheet,
                  icon: const Icon(Icons.hotel_rounded, size: 20),
                  label: const Text('Book Your Stay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attr == null
              ? const Center(child: Text('Not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(_attr!['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        background: NetworkImageWidget(imageUrl: _attr!['imageUrl'], width: double.infinity, borderRadius: 0, fit: BoxFit.cover),
                        collapseMode: CollapseMode.fade,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_attr!['category'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.tourismOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text(_attr!['category'], style: const TextStyle(color: AppColors.tourismOrange, fontWeight: FontWeight.w600, fontSize: 12)),
                                  ),
                                const Spacer(),
                                if (_attr!['isFeatured'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('Featured', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.ugandaBlack)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_attr!['location'] != null)
                              Row(children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(_attr!['location'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              ]),
                            const SizedBox(height: 16),
                            if (_attr!['description'] != null) ...[
                              const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              Text(_attr!['description'], style: const TextStyle(fontSize: 15, height: 1.7)),
                              const SizedBox(height: 20),
                            ],
                            if (_attr!['openingHours'] != null) _buildDetail(Icons.access_time_rounded, 'Opening Hours', _attr!['openingHours']),
                            if (_attr!['entryFee'] != null) _buildDetail(Icons.attach_money_rounded, 'Entry Fee', _attr!['entryFee']),
                            if (_attr!['contactPhone'] != null) _buildDetail(Icons.phone_outlined, 'Contact', _attr!['contactPhone']),
                            if (_isHotel) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlack.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primaryBlack.withOpacity(0.08)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.hotel_rounded, color: AppColors.primaryBlack, size: 20),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Hotel Accommodation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                          Text('Tap "Book Your Stay" below to request a reservation.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.4)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }
}

// ── Hotel Booking Sheet ──────────────────────────────────────────────────────

class _HotelBookingSheet extends StatefulWidget {
  final String hotelName;
  const _HotelBookingSheet({required this.hotelName});

  @override
  State<_HotelBookingSheet> createState() => _HotelBookingSheetState();
}

class _HotelBookingSheetState extends State<_HotelBookingSheet> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 2;
  String _roomType = 'Standard';
  bool _submitted = false;

  static const _roomTypes = ['Standard', 'Deluxe', 'Suite', 'Presidential Suite'];
  static const _roomPrices = {'Standard': 80, 'Deluxe': 150, 'Suite': 250, 'Presidential Suite': 500};

  int get _nights => (_checkIn != null && _checkOut != null)
      ? _checkOut!.difference(_checkIn!).inDays.clamp(1, 365)
      : 1;
  int get _price => (_roomPrices[_roomType] ?? 80) * _nights;

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final earliest = isCheckIn ? now : (_checkIn ?? now).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkIn ?? now)
          : (_checkOut ?? (_checkIn ?? now).add(const Duration(days: 1))),
      firstDate: earliest,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlack),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && !_checkOut!.isAfter(picked)) {
            _checkOut = picked.add(const Duration(days: 1));
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  void _submit() {
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select check-in and check-out dates')),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SuccessView(
        hotelName: widget.hotelName,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        roomType: _roomType,
        guests: _guests,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.darkOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.hotel_rounded, color: AppColors.darkOrange, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.hotelName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryBlack), overflow: TextOverflow.ellipsis),
                      const Text('Booking Request', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _DateButton(label: 'Check-in', date: _checkIn, onTap: () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(child: _DateButton(label: 'Check-out', date: _checkOut, onTap: () => _pickDate(false))),
              ],
            ),

            const SizedBox(height: 20),
            const Text('Guests', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                _CounterBtn(
                  icon: Icons.remove_rounded,
                  onTap: _guests > 1 ? () => setState(() => _guests--) : null,
                ),
                const SizedBox(width: 12),
                Text('$_guests', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(width: 12),
                _CounterBtn(
                  icon: Icons.add_rounded,
                  onTap: _guests < 8 ? () => setState(() => _guests++) : null,
                ),
                const Spacer(),
                Text('${_guests == 1 ? "1 guest" : "$_guests guests"}', style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
              ],
            ),

            const SizedBox(height: 20),
            const Text('Room Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _roomTypes.map((t) {
                final sel = t == _roomType;
                return GestureDetector(
                  onTap: () => setState(() => _roomType = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryBlack : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? AppColors.primaryBlack : Colors.grey.shade200),
                    ),
                    child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: sel ? Colors.white : AppColors.primaryBlack)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primaryBlack.withOpacity(0.04), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimated Total', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('\$$_price USD', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primaryBlack)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$_nights ${_nights == 1 ? "night" : "nights"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
                      Text('\$${_roomPrices[_roomType] ?? 80} / night', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Request Booking'),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Our team will contact you within 24 hours to confirm',
                style: TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlack : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primaryBlack : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.white60 : AppColors.textSecondaryLight)),
            const SizedBox(height: 3),
            Text(
              selected ? DateFormat('MMM d, yyyy').format(date!) : 'Select date',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: selected ? Colors.white : AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primaryBlack : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: onTap != null ? Colors.white : Colors.grey.shade400),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String hotelName;
  final DateTime checkIn, checkOut;
  final String roomType;
  final int guests;
  const _SuccessView({required this.hotelName, required this.checkIn, required this.checkOut, required this.roomType, required this.guests});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Booking Request Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryBlack)),
          const SizedBox(height: 8),
          Text(
            'Your request for $hotelName has been submitted.\nWe\'ll confirm within 24 hours.',
            style: const TextStyle(color: AppColors.textSecondaryLight, height: 1.6, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _Row('Hotel', hotelName),
                _Row('Check-in', DateFormat('EEE, MMM d yyyy').format(checkIn)),
                _Row('Check-out', DateFormat('EEE, MMM d yyyy').format(checkOut)),
                _Row('Room', roomType),
                _Row('Guests', '$guests'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
          const Spacer(),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlack), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
