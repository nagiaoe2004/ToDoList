/// Định dạng ngày hiển thị (dd/MM/yyyy).
String formatDate(DateTime value) {
  final String day = value.day.toString().padLeft(2, '0');
  final String month = value.month.toString().padLeft(2, '0');
  final String year = value.year.toString();
  return '$day/$month/$year';
}
