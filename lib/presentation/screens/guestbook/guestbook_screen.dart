// lib/presentation/screens/guestbook/guestbook_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../data/models/guestbook_message_model.dart';
import '../../../data/repositories/interfaces/guestbook_repository.dart';
import '../../widgets/guestbook/guestbook_message_card.dart';

class GuestbookScreen extends StatefulWidget {
  const GuestbookScreen({super.key});

  @override
  State<GuestbookScreen> createState() => _GuestbookScreenState();
}

class _GuestbookScreenState extends State<GuestbookScreen> {
  late final IGuestbookRepository _guestbookRepository;
  List<GuestbookMessage> _allMessages = [];
  List<GuestbookMessage> _currentPageMessages = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<List<GuestbookMessage>>? _messagesSubscription;
  final Set<String> _newMessageIds = {};
  bool _showPassword = false;
  
  // Pagination
  int _currentPage = 0;
  final int _messagesPerPage = 10;
  int get _totalPages => (_allMessages.length / _messagesPerPage).ceil();
  bool get _hasNextPage => _currentPage < _totalPages - 1;
  bool get _hasPreviousPage => _currentPage > 0;

  @override
  void initState() {
    super.initState();
    try {
      _guestbookRepository = serviceLocator<IGuestbookRepository>();
      _setupRealtimeUpdates();
    } catch (e) {
      // If dependency injection fails, set loading to false and show error
      setState(() {
        _isLoading = false;
      });
      // Show error after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('초기화 실패: $e')),
          );
        }
      });
    }
  }

  void _setupRealtimeUpdates() {
    _messagesSubscription = _guestbookRepository.getApprovedMessagesStream().listen(
      (messages) {
        if (mounted) {
          // Detect new messages for animation
          final currentMessageIds = _allMessages.map((m) => m.id).toSet();
          final newMessageIds = messages
              .where((m) => !currentMessageIds.contains(m.id))
              .map((m) => m.id)
              .toSet();
          
          setState(() {
            _allMessages = messages;
            _updateCurrentPageMessages();
            _isLoading = false;
            _newMessageIds.addAll(newMessageIds);
          });
          
          // Clear new message flags after animation delay
          if (newMessageIds.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _newMessageIds.removeAll(newMessageIds);
                });
              }
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('실시간 업데이트 오류: $error'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: '다시 시도',
                textColor: Colors.white,
                onPressed: _setupRealtimeUpdates,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _nameController.dispose();
    _messageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateCurrentPageMessages() {
    if (_allMessages.isEmpty) {
      _currentPageMessages = [];
      return;
    }
    
    final startIndex = _currentPage * _messagesPerPage;
    final endIndex = (startIndex + _messagesPerPage).clamp(0, _allMessages.length);
    _currentPageMessages = _allMessages.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
        _updateCurrentPageMessages();
      });
    }
  }

  void _nextPage() {
    if (_hasNextPage) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_hasPreviousPage) {
      _goToPage(_currentPage - 1);
    }
  }

  Future<void> _loadMessages() async {
    // This method is now primarily used for manual refresh
    // Real-time updates are handled by the stream subscription
    try {
      await _guestbookRepository.getApprovedMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('새로고침 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addMessage(String? password) async {
    if (!_formKey.currentState!.validate()) return;

    final message = GuestbookMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
      password: password,
    );

    try {
      final success = await _guestbookRepository.addMessage(message);
      if (success) {
        _nameController.clear();
        _messageController.clear();
        _passwordController.clear();
        // Real-time stream will automatically update the UI
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('축하 메시지가 등록되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('메시지 등록에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddMessageDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  '축하 메시지 남기기',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '소중한 축하 메시지를 남겨주세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '이름을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    if (value.trim().length > 20) {
                      return '이름은 20자 이내로 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Message field
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: '축하 메시지',
                    hintText: '축하 메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  maxLength: 200,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '메시지를 입력해주세요';
                    }
                    if (value.trim().length < 5) {
                      return '메시지는 5자 이상 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: '삭제 비밀번호 (선택사항)',
                    hintText: '메시지 삭제시 필요한 비밀번호',
                    helperText: '나중에 메시지를 삭제하려면 비밀번호를 설정하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _addMessage(_passwordController.text.isNotEmpty ? _passwordController.text : null);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('등록하기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '방명록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMessageDialog,
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('메시지 남기기'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMessages,
              child: _allMessages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessagesList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.message_outlined,
                  size: 64,
                  color: Colors.pink.shade300,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '아직 축하 메시지가 없습니다',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '첫 번째 축하 메시지를 남겨보세요!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showAddMessageDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('메시지 남기기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _currentPageMessages.length + 1 + (_totalPages > 1 ? 1 : 0), // +1 for header, +1 for pagination if needed
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }
        
        // Check if this is the pagination row
        if (_totalPages > 1 && index == _currentPageMessages.length + 1) {
          return _buildPaginationControls();
        }
        
        final message = _currentPageMessages[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GuestbookMessageCard(
            message: message,
            textColor: Colors.black87,
            accentColor: Colors.pink.shade400,
            isEditMode: false,
            isNewMessage: _newMessageIds.contains(message.id),
            onDelete: (messageIdWithPassword) async {
              // Parse messageId and password
              final parts = messageIdWithPassword.split('|');
              if (parts.length != 2) return;
              
              final messageId = parts[0];
              final password = parts[1];
              
              final success = await _guestbookRepository.deleteMessageWithPassword(messageId, password);
              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('메시지가 삭제되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('비밀번호가 일치하지 않습니다'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.pink.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            '축하 메시지',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '총 ${_allMessages.length}개의 따뜻한 메시지',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: _hasPreviousPage ? _previousPage : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('이전'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasPreviousPage ? Colors.pink.shade400 : Colors.grey.shade300,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // Page indicators
          Row(
            children: List.generate(_totalPages, (index) {
              final isCurrentPage = index == _currentPage;
              return GestureDetector(
                onTap: () => _goToPage(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrentPage ? Colors.pink.shade400 : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrentPage ? Colors.white : Colors.black87,
                        fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          
          // Next button
          ElevatedButton.icon(
            onPressed: _hasNextPage ? _nextPage : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('다음'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasNextPage ? Colors.pink.shade400 : Colors.grey.shade300,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}