import 'package:flutter/material.dart';

class RSVPWidget extends StatefulWidget {
  final String title;
  final Function(RSVPResponse) onSubmit;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  const RSVPWidget({
    super.key,
    this.title = '참석 여부를 알려주세요',
    required this.onSubmit,
    this.enabled = true,
    this.padding,
  });

  @override
  State<RSVPWidget> createState() => _RSVPWidgetState();
}

class _RSVPWidgetState extends State<RSVPWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _memoController =
      TextEditingController(); // Separate controller for 불참 memo
  final _phoneController = TextEditingController();

  AttendanceStatus _attendanceStatus = AttendanceStatus.none;
  int _guestCount = 1;
  String _relationship = '친구';
  MealPreference _mealPreference = MealPreference.korean;
  final List<String> _dietaryRestrictions = [];
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _relationshipOptions = [
    '친구',
    '직장동료',
    '대학동기',
    '고등학교 동창',
    '가족',
    '친척',
    '지인',
    '기타',
  ];

  final List<String> _dietaryOptions = [
    '채식',
    '할랄',
    '견과류 알레르기',
    '해산물 알레르기',
    '유제품 알레르기',
    '글루텐 프리',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    _memoController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitRSVP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final response = RSVPResponse(
      name: _nameController.text.trim(),
      attendanceStatus: _attendanceStatus,
      guestCount: _guestCount,
      relationship: _relationship,
      mealPreference: _mealPreference,
      dietaryRestrictions: _dietaryRestrictions,
      message: _messageController.text.trim(),
      memo: _memoController.text.trim(), // Add memo field
      phone: _phoneController.text.trim(),
      submittedAt: DateTime.now().toUtc(),
    );

    try {
      await widget.onSubmit(response);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('참석 여부가 정상적으로 접수되었습니다!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.indigo.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 1,
              ),
            ],
          ),
          child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.check_circle,
            size: 60,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '참석 여부 접수 완료!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_nameController.text}님의 참석 여부가\n정상적으로 접수되었습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isSubmitted = false;
                _nameController.clear();
                _messageController.clear();
                _memoController.clear();
                _phoneController.clear();
                _attendanceStatus = AttendanceStatus.none;
                _guestCount = 1;
                _relationship = '친구';
                _mealPreference = MealPreference.korean;
                _dietaryRestrictions.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '새로운 참석자 등록',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.how_to_reg,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Name field
          _buildTextField(
            controller: _nameController,
            label: '성함',
            hint: '참석자 성함을 입력해주세요',
            icon: Icons.person,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return '성함을 입력해주세요';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Phone field
          _buildTextField(
            controller: _phoneController,
            label: '연락처 (선택)',
            hint: '연락처를 입력해주세요',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          // Attendance status
          _buildAttendanceSelector(),

          if (_attendanceStatus == AttendanceStatus.attending) ...[
            const SizedBox(height: 16),

            // Guest count
            _buildGuestCountSelector(),

            const SizedBox(height: 16),

            // Relationship
            _buildRelationshipSelector(),

            const SizedBox(height: 16),

            // Meal preference
            _buildMealPreferenceSelector(),

            const SizedBox(height: 16),

            // Dietary restrictions
            _buildDietaryRestrictionsSelector(),
          ],

          if (_attendanceStatus == AttendanceStatus.notAttending) ...[
            const SizedBox(height: 16),

            // Note field for not attending
            _buildTextField(
              controller: _memoController,
              label: '추가 메모 (선택사항)',
              hint: '',
              icon: Icons.note_alt,
              maxLines: 3,
            ),
          ],

          // Only show congratulatory message field when attending
          if (_attendanceStatus == AttendanceStatus.attending) ...[
            const SizedBox(height: 16),

            // Message field
            _buildTextField(
              controller: _messageController,
              label: '축하 메시지 (선택)',
              hint: '축하 메시지를 남겨주세요',
              icon: Icons.message,
              maxLines: 3,
            ),
          ],

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.enabled &&
                      !_isSubmitting &&
                      _attendanceStatus != AttendanceStatus.none
                  ? _submitRSVP
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      '참석 여부 전송',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.enabled &&
                                _attendanceStatus != AttendanceStatus.none
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blue.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참석 여부',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildAttendanceOption(
                AttendanceStatus.attending,
                '참석',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttendanceOption(
                AttendanceStatus.notAttending,
                '불참석',
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceOption(
    AttendanceStatus status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _attendanceStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _attendanceStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참석 인원',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              const Text('총 '),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _guestCount,
                  underline: const SizedBox(),
                  items: List.generate(10, (index) => index + 1)
                      .map((count) => DropdownMenuItem(
                            value: count,
                            child: Text('$count명'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _guestCount = value;
                      });
                    }
                  },
                ),
              ),
              const Text(' 참석'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관계',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _relationship,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.group, color: Colors.blue.shade600),
            ),
            items: _relationshipOptions
                .map((relationship) => DropdownMenuItem(
                      value: relationship,
                      child: Text(relationship),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _relationship = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealPreferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '식사 선호도',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMealOption(MealPreference.korean, '한식'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMealOption(MealPreference.western, '양식'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMealOption(MealPreference.vegetarian, '채식'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealOption(MealPreference preference, String label) {
    final isSelected = _mealPreference == preference;

    return GestureDetector(
      onTap: () {
        setState(() {
          _mealPreference = preference;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDietaryRestrictionsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '식이 제한 (선택)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dietaryOptions.map((restriction) {
            final isSelected = _dietaryRestrictions.contains(restriction);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _dietaryRestrictions.remove(restriction);
                  } else {
                    _dietaryRestrictions.add(restriction);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.shade50 : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.orange.shade400
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  restriction,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.orange.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

enum AttendanceStatus {
  none,
  attending,
  notAttending,
}

enum MealPreference {
  korean,
  western,
  vegetarian,
}

class RSVPResponse {
  final String name;
  final AttendanceStatus attendanceStatus;
  final int guestCount;
  final String relationship;
  final MealPreference mealPreference;
  final List<String> dietaryRestrictions;
  final String message;
  final String memo; // Additional memo field for not attending
  final String phone;
  final DateTime submittedAt;

  RSVPResponse({
    required this.name,
    required this.attendanceStatus,
    required this.guestCount,
    required this.relationship,
    required this.mealPreference,
    required this.dietaryRestrictions,
    required this.message,
    required this.memo,
    required this.phone,
    required this.submittedAt,
  });
}
