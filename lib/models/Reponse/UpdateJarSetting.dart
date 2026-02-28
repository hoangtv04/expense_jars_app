
class UpdateJarSetting {

final int id;
final String nameJar;
final String name;
final double balance;
final String description;

UpdateJarSetting({
  required this.id,
  required this.nameJar,
  required this.name,
  required this.balance,
  this.description = '',
});
}