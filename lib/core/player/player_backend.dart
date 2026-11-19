// SPDX-License-Identifier: GPL-3.0-or-later

abstract interface class PlayerBackend {
  Future<void> open(String source);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setMuted(bool muted);
}
