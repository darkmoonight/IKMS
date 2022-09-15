import 'package:http/http.dart' as http;
import 'package:project_cdis/app/data/audiences.dart';
import 'package:project_cdis/app/data/professors.dart';

class RomoteServise {
  Future<List<Audiences>?> getAudiencesData() async {
    List<Audiences>? audiences;
    var client = http.Client();
    var url = Uri.parse('https://edu.donstu.ru/api/raspAudlist');
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var result = audiencesFromJson(response.body);
      audiences = result.data;
    }
    return audiences;
  }

  Future<List<Professors>?> getProfessorsData() async {
    List<Professors>? professors;
    var client = http.Client();
    var url = Uri.parse('https://edu.donstu.ru/api/raspTeacherlist');
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var result = professorsFromJson(response.body);
      professors = result.data;
    }
    return professors;
  }
}
