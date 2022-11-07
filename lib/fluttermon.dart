import 'dart:async';
import 'dart:io';
import 'dart:convert';

class Monitor {
  late Process _process;
  final List<String> args;

  Future? _throttler;
  StreamSubscription<FileSystemEvent>? _subs;
  final List<String> _proxiedArgs = [];
  bool _isFvm = false;

  Monitor(this.args) {
    _parseArgs();
  }

  void _parseArgs() {
    for (String arg in args) {
      if (arg == '--fvm') {
        _isFvm = true;
        continue;
      }

      _proxiedArgs.add(arg);
    }
  }

  Future<void> _runUpdate() async {
    _process.stdin.write('r');
  }

  void _print(String line) {
    final trim = line.trim();
    if (trim.isNotEmpty) {
      print(trim);
    }
  }

  void _processLine(String line) {
    if (line.contains('More than one device connected')) {
      _print(
          "Fluttermon found multiple devices, device choosing menu isn't supported yet, please use the -d argument");
      _process.kill();
      exit(1);
    } else {
      _print(line);
    }
  }

  void _processError(String line) {
    _print(line);
    _process.kill();
    exit(1);
  }

  Future<void> start() async {
    _process = await (_isFvm
        ? Process.start('fvm', ['flutter', 'run', ..._proxiedArgs])
        : Process.start('powershell', [
            '-Noprofile',
            '-Command',
            'flutter',
            'run',
            ..._proxiedArgs,
          ]));

    _process.stdout.transform(utf8.decoder).forEach(_processLine);
    _process.stderr.transform(utf8.decoder).forEach(_processError);
    stdin.listen(_process.stdin.add);

    final currentDir = File('.');
    print('Watching ${currentDir.absolute.path} directory ...');

    _subs = currentDir.watch(recursive: true).listen((event) {
      if (event.path.startsWith('.\\lib')) {
        if (_throttler == null) {
          _throttler = _runUpdate();
          _throttler?.then((_) {
            print('Sent reload request...');
            _throttler = null;
          });
        }
      }
    });

    return _process.exitCode.then((value) => _subs?.cancel());
  }
}
