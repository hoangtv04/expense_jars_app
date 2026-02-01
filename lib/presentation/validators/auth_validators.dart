String? signupEmailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }

  final email = value.trim();

  if (!email.contains('@')) {
    return 'Email must contain @';
  }

  if (!email.endsWith('@gmail.com')) {
    return 'Email must end with @gmail.com';
  }

  final localPart = email.replaceAll('@gmail.com', '');
  if (localPart.isEmpty) {
    return 'Invalid Gmail address';
  }

  return null;
}
