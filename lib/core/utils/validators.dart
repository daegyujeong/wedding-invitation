class Validators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '필드'}는 필수입니다.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식을 입력해주세요.';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요.';
    }

    if (value.trim().length < 2) {
      return '이름은 2자 이상 입력해주세요.';
    }

    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '메시지를 입력해주세요.';
    }

    if (value.trim().length < 5) {
      return '메시지는 5자 이상 입력해주세요.';
    }

    if (value.trim().length > 500) {
      return '메시지는 500자 이하로 입력해주세요.';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 전화번호는 선택사항
    }

    final phoneRegex = RegExp(r'^010-?\d{4}-?\d{4}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll('-', ''))) {
      return '올바른 전화번호 형식을 입력해주세요. (예: 010-1234-5678)';
    }

    return null;
  }
}
