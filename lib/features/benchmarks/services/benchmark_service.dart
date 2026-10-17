import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../models/benchmark_model.dart';

class BenchmarkService {
  // 1. Single-Core CPU Benchmark
  static Future<BenchmarkResult> runSingleCoreCpu({
    required String deviceModel,
  }) async {
    final stopwatch = Stopwatch()..start();

    final ops = await Isolate.run(() {
      int count = 0;
      // Sieve of Eratosthenes up to 80,000
      const limit = 80000;
      final isPrime = Uint8List(limit + 1)..fillRange(2, limit + 1, 1);
      for (int p = 2; p * p <= limit; p++) {
        if (isPrime[p] == 1) {
          for (int i = p * p; i <= limit; i += p) {
            isPrime[i] = 0;
          }
        }
      }
      for (int i = 2; i <= limit; i++) {
        if (isPrime[i] == 1) count++;
      }

      // Matrix multiplication 64x64
      const n = 64;
      final a = List.generate(
        n,
        (i) => List.generate(n, (j) => (i + j).toDouble()),
      );
      final b = List.generate(
        n,
        (i) => List.generate(n, (j) => (i - j).toDouble()),
      );
      final c = List.generate(n, (_) => List.filled(n, 0.0));

      for (int repeat = 0; repeat < 60; repeat++) {
        for (int i = 0; i < n; i++) {
          for (int j = 0; j < n; j++) {
            double sum = 0;
            for (int k = 0; k < n; k++) {
              sum += a[i][k] * b[k][j];
            }
            c[i][j] = sum;
          }
        }
      }

      return count;
    });

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds.clamp(1, 60000);
    final score = ((100000 / elapsedMs) * 10).round();

    return BenchmarkResult(
      testType: 'CPU_SINGLE',
      timestamp: DateTime.now(),
      executionTimeMs: elapsedMs,
      score: score,
      deviceModel: deviceModel,
      metrics: {
        'primesCount': ops,
        'elapsedMs': elapsedMs,
        'algorithm': 'Sieve of Eratosthenes (80k) + Float64 Matrix 64x64 (60 iterations)',
      },
    );
  }

  // 2. Multi-Core CPU Benchmark
  static Future<BenchmarkResult> runMultiCoreCpu({
    required int coresCount,
    required String deviceModel,
  }) async {
    final effectiveCores = coresCount.clamp(1, 16);
    final stopwatch = Stopwatch()..start();

    final tasks = List.generate(effectiveCores, (coreIndex) {
      return Isolate.run(() {
        // Compute Sieve + SHA256 hashing
        const limit = 50000;
        final isPrime = Uint8List(limit + 1)..fillRange(2, limit + 1, 1);
        for (int p = 2; p * p <= limit; p++) {
          if (isPrime[p] == 1) {
            for (int i = p * p; i <= limit; i += p) {
              isPrime[i] = 0;
            }
          }
        }

        final buffer = Uint8List(256);
        for (int i = 0; i < 256; i++) {
          buffer[i] = (i ^ coreIndex) & 0xFF;
        }

        var digest = sha256.convert(buffer);
        for (int i = 0; i < 3000; i++) {
          digest = sha256.convert(digest.bytes);
        }

        return digest.toString();
      });
    });

    await Future.wait(tasks);
    stopwatch.stop();

    final elapsedMs = stopwatch.elapsedMilliseconds.clamp(1, 60000);
    final score = (((100000 * effectiveCores) / elapsedMs) * 8).round();

    return BenchmarkResult(
      testType: 'CPU_MULTI',
      timestamp: DateTime.now(),
      executionTimeMs: elapsedMs,
      score: score,
      deviceModel: deviceModel,
      metrics: {
        'coresUtilized': effectiveCores,
        'elapsedMs': elapsedMs,
        'algorithm': 'Parallel Sieve (50k) + SHA-256 (3,000 rounds per core)',
      },
    );
  }

  // 3. Storage I/O Benchmark
  static Future<BenchmarkResult> runStorageIo({
    required String deviceModel,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/phonescope_storage_bench.tmp');

    const totalBytes = 16 * 1024 * 1024; // 16 MB
    const blockSize = 64 * 1024; // 64 KB
    final block = Uint8List(blockSize)..fillRange(0, blockSize, 0xAA);
    final blocksCount = totalBytes ~/ blockSize;

    // Sequential Write
    final writeStopwatch = Stopwatch()..start();
    final sink = tempFile.openWrite(mode: FileMode.writeOnly);
    for (int i = 0; i < blocksCount; i++) {
      sink.add(block);
    }
    await sink.flush();
    await sink.close();
    writeStopwatch.stop();

    final writeElapsedMs = writeStopwatch.elapsedMilliseconds.clamp(1, 60000);
    final writeSpeedMbSec =
        (totalBytes / (1024 * 1024)) / (writeElapsedMs / 1000.0);

    // Sequential Read
    final readStopwatch = Stopwatch()..start();
    final reader = tempFile.openSync(mode: FileMode.read);
    final readBuffer = Uint8List(blockSize);
    int totalRead = 0;
    while (totalRead < totalBytes) {
      final read = reader.readIntoSync(readBuffer);
      if (read <= 0) break;
      totalRead += read;
    }
    reader.closeSync();
    readStopwatch.stop();

    final readElapsedMs = readStopwatch.elapsedMilliseconds.clamp(1, 60000);
    final readSpeedMbSec =
        (totalBytes / (1024 * 1024)) / (readElapsedMs / 1000.0);

    // Always clean up immediately
    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (_) {}

    final score = ((writeSpeedMbSec * 8) + (readSpeedMbSec * 5)).round();

    return BenchmarkResult(
      testType: 'STORAGE_IO',
      timestamp: DateTime.now(),
      executionTimeMs: writeElapsedMs + readElapsedMs,
      score: score,
      deviceModel: deviceModel,
      metrics: {
        'writeSpeedMbSec': writeSpeedMbSec,
        'readSpeedMbSec': readSpeedMbSec,
        'testFileSizeMb': 16,
        'algorithm': 'Sequential Block I/O (16MB buffer, 64KB blocks)',
      },
    );
  }
}
