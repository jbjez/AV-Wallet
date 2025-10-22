// lib/core/speed_tester.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Configuration for speed test parameters
class SpeedTestConfig {
  final Duration warmup;
  final Duration sampleWindow;
  final int parallel;
  final int uploadParallel;

  const SpeedTestConfig({
    this.warmup = const Duration(seconds: 2),
    this.sampleWindow = const Duration(seconds: 8),
    this.parallel = 8,
    this.uploadParallel = 6,
  });
}

/// Progress update during speed test
class SpeedProgress {
  final String phase;
  final double instantaneousMbps;
  final double averageMbps;
  final List<double> samples;
  final int totalBytes;
  final Duration elapsed;

  const SpeedProgress({
    required this.phase,
    required this.instantaneousMbps,
    required this.averageMbps,
    required this.samples,
    required this.totalBytes,
    required this.elapsed,
  });
}

/// Final speed test results
class SpeedResult {
  final double downloadMbps;
  final double uploadMbps;
  final double pingMs;
  final double jitterMs;
  final String serverUsed;
  final Duration totalTime;

  const SpeedResult({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.pingMs,
    required this.jitterMs,
    required this.serverUsed,
    required this.totalTime,
  });
}

/// Server configuration for speed testing
class SpeedTestServer {
  final String name;
  final String downloadUrl;
  final String? uploadUrl;
  final int maxFileSize; // in bytes
  final bool supportsRange;

  const SpeedTestServer({
    required this.name,
    required this.downloadUrl,
    this.uploadUrl,
    this.maxFileSize = 10 * 1024 * 1024 * 1024, // 10GB
    this.supportsRange = true,
  });
}

/// Main speed tester class
class SpeedTester {
  static const List<SpeedTestServer> _servers = [
    SpeedTestServer(
      name: 'Cloudflare',
      downloadUrl: 'https://speed.cloudflare.com/__down?bytes=0',
      supportsRange: true,
    ),
    SpeedTestServer(
      name: 'Netflix Fast',
      downloadUrl: 'https://fast.com/',
      supportsRange: false,
    ),
    SpeedTestServer(
      name: 'Hetzner',
      downloadUrl: 'https://speed.hetzner.de/10MB.bin',
      supportsRange: true,
    ),
  ];

  final SpeedTestConfig config;
  final StreamController<SpeedProgress> _progressController = StreamController<SpeedProgress>.broadcast();
  bool _isRunning = false;
  String? _selectedServer;

  SpeedTester({this.config = const SpeedTestConfig()});

  Stream<SpeedProgress> get progressStream => _progressController.stream;

  /// Run complete speed test
  Future<SpeedResult> run() async {
    if (_isRunning) {
      throw StateError('Speed test already running');
    }

    _isRunning = true;
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Server discovery and ping/jitter test
      _selectedServer = await _discoverBestServer();
      final pingResult = await _testPingAndJitter();

      // 2. Download test
      final downloadResult = await _testDownload();

      // 3. Upload test
      final uploadResult = await _testUpload();

      stopwatch.stop();

      return SpeedResult(
        downloadMbps: downloadResult,
        uploadMbps: uploadResult,
        pingMs: pingResult.ping,
        jitterMs: pingResult.jitter,
        serverUsed: _selectedServer ?? 'Unknown',
        totalTime: stopwatch.elapsed,
      );
    } finally {
      _isRunning = false;
    }
  }

  /// Stop the current test
  void stop() {
    _isRunning = false;
  }

  /// Discover the best server for testing
  Future<String> _discoverBestServer() async {
    for (final server in _servers) {
      try {
        _progressController.add(SpeedProgress(
          phase: 'Testing ${server.name}...',
          instantaneousMbps: 0,
          averageMbps: 0,
          samples: [],
          totalBytes: 0,
          elapsed: Duration.zero,
        ));

        final speed = await _testServerSpeed(server);
        if (speed > 20) { // Minimum 20 Mbps
          return server.name;
        }
      } catch (e) {
        // Try next server
        continue;
      }
    }
    throw Exception('No suitable server found');
  }

  /// Test a single server's speed
  Future<double> _testServerSpeed(SpeedTestServer server) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(server.downloadUrl));
      if (server.supportsRange) {
        request.headers.set('Range', 'bytes=0-1048575'); // 1MB test
      }
      
      final response = await request.close();
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final stopwatch = Stopwatch()..start();
      int bytes = 0;
      
      await for (final chunk in response) {
        bytes += chunk.length;
        if (stopwatch.elapsedMilliseconds > 2000) break; // 2 second test
      }
      
      stopwatch.stop();
      final seconds = stopwatch.elapsedMilliseconds / 1000.0;
      return seconds > 0 ? (bytes * 8) / (seconds * 1e6) : 0;
    } finally {
      client.close();
    }
  }

  /// Test ping and jitter
  Future<({double ping, double jitter})> _testPingAndJitter() async {
    _progressController.add(SpeedProgress(
      phase: 'Testing ping...',
      instantaneousMbps: 0,
      averageMbps: 0,
      samples: [],
      totalBytes: 0,
      elapsed: Duration.zero,
    ));

    final server = _servers.firstWhere((s) => s.name == _selectedServer);
    final client = HttpClient();
    final rtts = <int>[];

    try {
      for (int i = 0; i < 15; i++) {
        final stopwatch = Stopwatch()..start();
        try {
          final request = await client.headUrl(Uri.parse(server.downloadUrl));
          final response = await request.close();
          if (response.statusCode >= 200 && response.statusCode < 300) {
            stopwatch.stop();
            rtts.add(stopwatch.elapsedMilliseconds);
          }
        } catch (e) {
          // Skip failed pings
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } finally {
      client.close();
    }

    if (rtts.isEmpty) {
      return (ping: 0.0, jitter: 0.0);
    }

    rtts.sort();
    final median = rtts[rtts.length ~/ 2];
    final deviations = rtts.map((rtt) => (rtt - median).abs()).toList();
    deviations.sort();
    final mad = deviations[deviations.length ~/ 2];

    return (ping: median.toDouble(), jitter: mad.toDouble());
  }

  /// Test download speed
  Future<double> _testDownload() async {
    _progressController.add(SpeedProgress(
      phase: 'Warming up download...',
      instantaneousMbps: 0,
      averageMbps: 0,
      samples: [],
      totalBytes: 0,
      elapsed: Duration.zero,
    ));

    final server = _servers.firstWhere((s) => s.name == _selectedServer);
    final client = HttpClient();
    final samples = <double>[];

    try {
      // Warmup phase
      await _runDownloadPhase(client, server, config.warmup, samples, true);
      
      // Sample phase
      samples.clear();
      await _runDownloadPhase(client, server, config.sampleWindow, samples, false);
      
      return _calculateRobustAverage(samples);
    } finally {
      client.close();
    }
  }

  /// Run a download phase
  Future<void> _runDownloadPhase(
    HttpClient client,
    SpeedTestServer server,
    Duration duration,
    List<double> samples,
    bool isWarmup,
  ) async {
    final futures = <Future<void>>[];
    final stopwatch = Stopwatch()..start();
    final lastUpdate = DateTime.now();

    for (int i = 0; i < config.parallel; i++) {
      futures.add(_downloadStream(client, server, duration, samples, lastUpdate, isWarmup));
    }

    // Progress updates
    final progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isRunning || stopwatch.elapsed >= duration) {
        timer.cancel();
        return;
      }

      final totalBytes = samples.isNotEmpty ? samples.reduce((a, b) => a + b) : 0;
      final avgMbps = samples.isNotEmpty ? samples.reduce((a, b) => a + b) / samples.length : 0.0;
      final instantMbps = samples.isNotEmpty ? samples.last : 0.0;

      _progressController.add(SpeedProgress(
        phase: isWarmup ? 'Warming up download...' : 'Downloading...',
        instantaneousMbps: instantMbps,
        averageMbps: avgMbps,
        samples: List.from(samples),
        totalBytes: totalBytes.toInt(),
        elapsed: stopwatch.elapsed,
      ));
    });

    await Future.wait(futures);
    progressTimer.cancel();
  }

  /// Download stream for a single connection
  Future<void> _downloadStream(
    HttpClient client,
    SpeedTestServer server,
    Duration duration,
    List<double> samples,
    DateTime lastUpdate,
    bool isWarmup,
  ) async {
    final stopwatch = Stopwatch()..start();
    int totalBytes = 0;
    int lastBytes = 0;
    DateTime lastTime = DateTime.now();

    while (_isRunning && stopwatch.elapsed < duration) {
      try {
        final request = await client.getUrl(Uri.parse(server.downloadUrl));
        if (server.supportsRange) {
          final startByte = totalBytes % server.maxFileSize;
          final endByte = min(startByte + 1024 * 1024, server.maxFileSize - 1);
          request.headers.set('Range', 'bytes=$startByte-$endByte');
        }

        final response = await request.close();
        if (response.statusCode != 200 && response.statusCode != 206) {
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }

        await for (final chunk in response) {
          if (!_isRunning || stopwatch.elapsed >= duration) break;
          
          totalBytes += chunk.length;
          final now = DateTime.now();
          
          if (now.difference(lastTime).inMilliseconds >= 200) {
            final bytesDelta = totalBytes - lastBytes;
            final timeDelta = now.difference(lastTime).inMilliseconds / 1000.0;
            final mbps = (bytesDelta * 8) / (timeDelta * 1e6);
            
            if (!isWarmup) {
              samples.add(mbps);
            }
            
            lastBytes = totalBytes;
            lastTime = now;
          }
        }
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Test upload speed
  Future<double> _testUpload() async {
    _progressController.add(SpeedProgress(
      phase: 'Warming up upload...',
      instantaneousMbps: 0,
      averageMbps: 0,
      samples: [],
      totalBytes: 0,
      elapsed: Duration.zero,
    ));

    final samples = <double>[];

    // Warmup phase
    await _runUploadPhase(config.warmup, samples, true);
    
    // Sample phase
    samples.clear();
    await _runUploadPhase(config.sampleWindow, samples, false);
    
    return _calculateRobustAverage(samples);
  }

  /// Run upload phase
  Future<void> _runUploadPhase(Duration duration, List<double> samples, bool isWarmup) async {
    final futures = <Future<void>>[];
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < config.uploadParallel; i++) {
      futures.add(_uploadStream(duration, samples, isWarmup));
    }

    // Progress updates
    final progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      final avgMbps = samples.isNotEmpty ? samples.reduce((a, b) => a + b) / samples.length : 0.0;
      final instantMbps = samples.isNotEmpty ? samples.last : 0.0;

      _progressController.add(SpeedProgress(
        phase: isWarmup ? 'Warming up upload...' : 'Uploading...',
        instantaneousMbps: instantMbps,
        averageMbps: avgMbps,
        samples: List.from(samples),
        totalBytes: 0,
        elapsed: stopwatch.elapsed,
      ));
    });

    await Future.wait(futures);
    progressTimer.cancel();
  }

  /// Upload stream for a single connection
  Future<void> _uploadStream(Duration duration, List<double> samples, bool isWarmup) async {
    final stopwatch = Stopwatch()..start();
    int totalBytes = 0;
    int lastBytes = 0;
    DateTime lastTime = DateTime.now();

    while (_isRunning && stopwatch.elapsed < duration) {
      try {
        final client = HttpClient();
        final request = await client.postUrl(Uri.parse('https://httpbin.org/post'));
        request.headers.set('Content-Type', 'application/octet-stream');
        
        // Generate random data
        final random = Random();
        final chunkSize = 64 * 1024; // 64KB chunks
        final data = Uint8List(chunkSize);
        for (int i = 0; i < chunkSize; i++) {
          data[i] = random.nextInt(256);
        }

        final sink = request;
        sink.add(data);
        await sink.close();

        final response = await request.done;
        if (response.statusCode == 200) {
          totalBytes += chunkSize;
          final now = DateTime.now();
          
          if (now.difference(lastTime).inMilliseconds >= 200) {
            final bytesDelta = totalBytes - lastBytes;
            final timeDelta = now.difference(lastTime).inMilliseconds / 1000.0;
            final mbps = (bytesDelta * 8) / (timeDelta * 1e6);
            
            if (!isWarmup) {
              samples.add(mbps);
            }
            
            lastBytes = totalBytes;
            lastTime = now;
          }
        }
        
        client.close();
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Calculate robust average (trim top/bottom 20%)
  double _calculateRobustAverage(List<double> samples) {
    if (samples.isEmpty) return 0;
    
    samples.sort();
    final trimCount = (samples.length * 0.2).round();
    final trimmed = samples.sublist(trimCount, samples.length - trimCount);
    
    if (trimmed.isEmpty) return samples.first;
    return trimmed.reduce((a, b) => a + b) / trimmed.length;
  }

  void dispose() {
    _progressController.close();
  }
}
