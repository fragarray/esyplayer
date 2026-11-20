$ErrorActionPreference = 'Stop'
$dll = (Resolve-Path "$PSScriptRoot\..\build\windows\x64\runner\Release\libmpv-2.dll").Path

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class LibmpvSmokeTest {
  [DllImport(@"$dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern IntPtr mpv_create();
  [DllImport(@"$dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int mpv_set_option_string(IntPtr ctx, string name, string value);
  [DllImport(@"$dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int mpv_initialize(IntPtr ctx);
  [DllImport(@"$dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern IntPtr mpv_get_property_string(IntPtr ctx, string name);
  [DllImport(@"$dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern int mpv_command_string(IntPtr ctx, string command);
  [DllImport(@"$dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern void mpv_free(IntPtr ptr);
  [DllImport(@"$dll", CallingConvention = CallingConvention.Cdecl)]
  public static extern void mpv_terminate_destroy(IntPtr ctx);
}
"@

function Get-MpvProperty([IntPtr] $player, [string] $name, [bool] $optional = $false) {
  $value = [LibmpvSmokeTest]::mpv_get_property_string($player, $name)
  if ($value -eq [IntPtr]::Zero) {
    if ($optional) { return $null }
    throw "libmpv property unavailable: $name"
  }
  try {
    return [Runtime.InteropServices.Marshal]::PtrToStringAnsi($value)
  } finally {
    [LibmpvSmokeTest]::mpv_free($value)
  }
}

$player = [LibmpvSmokeTest]::mpv_create()
if ($player -eq [IntPtr]::Zero) {
  throw 'Could not create libmpv player'
}
try {
  foreach ($option in @(@('config', 'no'), @('vo', 'null'), @('ao', 'null'))) {
    if ([LibmpvSmokeTest]::mpv_set_option_string($player, $option[0], $option[1]) -ne 0) {
      throw "Could not set libmpv option: $($option[0])"
    }
  }
  if ([LibmpvSmokeTest]::mpv_initialize($player) -ne 0) {
    throw 'Could not initialize libmpv'
  }
  if ([LibmpvSmokeTest]::mpv_command_string(
    $player, 'loadfile "av://lavfi:color=c=black:s=320x240:r=5:d=20"'
  ) -ne 0) {
    throw 'Could not load synthetic video'
  }
  $culture = [Globalization.CultureInfo]::InvariantCulture
  $playing = $false
  for ($i = 0; $i -lt 60; $i++) {
    $time = Get-MpvProperty $player 'time-pos' $true
    if ($null -ne $time -and [double]::Parse($time, $culture) -ge 0.2) {
      $playing = $true
      break
    }
    Start-Sleep -Milliseconds 250
  }
  if (-not $playing) {
    throw 'Synthetic video did not start playing'
  }
  foreach ($command in @(
    'add sub-delay 0.1',
    'add secondary-sub-delay -0.1',
    'add secondary-sub-delay -0.1'
  )) {
    if ([LibmpvSmokeTest]::mpv_command_string($player, $command) -ne 0) {
      throw "libmpv command failed: $command"
    }
  }
  $primary = [double]::Parse((Get-MpvProperty $player 'sub-delay'), $culture)
  $secondary = [double]::Parse((Get-MpvProperty $player 'secondary-sub-delay'), $culture)
  if ([Math]::Abs($primary - 0.1) -gt 0.00001 -or
      [Math]::Abs($secondary + 0.2) -gt 0.00001) {
    throw "Incorrect subtitle delays: primary=$primary, secondary=$secondary"
  }
  Write-Output "Verified $(Get-MpvProperty $player 'mpv-version'): primary=$primary, secondary=$secondary"
} finally {
  [LibmpvSmokeTest]::mpv_terminate_destroy($player)
}
