import 'package:flutter/services.dart' show rootBundle;
import 'package:terminal/include/assets.dart';

class CatFiles {
  static final textDir = TerminalAssets.TEXT_ROOT;
  // ignore: non_constant_identifier_names
  static final Map<String, Future<String> Function()> FILENAME_MAPS = {
    'neofetch.txt': () => _neofetch(),
    'mewo.txt': () => _mewo(),
    'news.txt': () => _assetFile('$textDir/news.txt'),
    'projects.txt': () => _assetFile('$textDir/projects.txt'),
    'publications.txt': () => _assetFile('$textDir/publications.txt'),
  };

  static Future<String> read(
      {required String? command,
      required String? filename,
      int numLines = -1}) async {
    Future<String> readString;
    if (filename == null) {
      if (command == 'cat') {
        readString = _mewo();
      } else {
        readString = Future.value('''<p>$command: no file specified</p>''');
      }
    } else if (FILENAME_MAPS.containsKey(filename)) {
      readString = FILENAME_MAPS[filename]!();
    } else {
      readString = Future.value(
          '''<p>$command: $filename: no such file or directory</p>''');
    }
    String result = await readString;
    if (numLines >= 1) {
      result = result.split('\n').take(numLines).join('\n');
    }
    return result;
  }

  static Future<String> _assetFile(String filename) async {
    return rootBundle.loadString(filename);
  }

  static Future<String> _mewo() {
    return Future.value(
        '''<pre>                                 ██              ██    
 Meow? (Waiting for           ██████          ██████  
 something to happen?)      ████  ██        ████  ██  
                          ████    ████    ████    ██  
                        ████    ████████████████  ██  
                    ████████████████████████████████  
                  ██████████████████████████████████  
                ████████████████████████████████████  
                ████████████████████████████████████  
    ██████████  ██████████████████████████████████████
  ████████████████████████████████████████████████████
  ████████████████████████████      ████████      ████
  ██████      ████████████████████████████████████████
                    ████████████████████████████████  
                        ██████████████████████████</pre>
''');
  }

  static Future<String> _neofetch() {
    var now = DateTime.now().toUtc();
    var birth = DateTime(1998, 7, 27);
    var bdayHasPassed = now.isAfter(DateTime(now.year, birth.month, birth.day));
    var lifeYears = now.year - birth.year - (bdayHasPassed ? 0 : 1);
    var lifeDays = now
        .difference(DateTime(
            bdayHasPassed ? now.year : now.year - 1, birth.month, birth.day))
        .inDays;
    // just in case so it does not say -1 days on my birthday
    lifeDays = lifeDays < 0 ? 0 : lifeDays;
    return Future.value('''
<table>
  <tr>
    <td>
      <img src="asset:assets/images/diego-neofetch.png" width="160"/>
    </td>
    <td>
      <pre>  </pre>
    </td>
    <td>
      <p><span>guest</span>@<span>terminal</span><br>
      --------------<br>
      <span>Name</span>: Diego<br>
      <span>Surname</span>: Royo<br>
      <span>Surname</span>: Meneses<br>
      <span>Uptime</span>: $lifeYears years, $lifeDays days<br>
      <span>Email</span>: <selectable>droyo at unizar dot es</selectable><br>
      <span>Occupation</span>: PhD Student<br>
      <span>Location</span>: Universidad de Zaragoza<br>
      <span>Location</span>: Zaragoza, España</p>
      <br>
      <pre><linkedin></linkedin> <github></github> <twitter></twitter></pre>
    </td>
  </tr>
</table>''');
  }
}
