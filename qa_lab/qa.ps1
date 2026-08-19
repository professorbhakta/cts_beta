param(
  [Parameter(Mandatory=$true)][string]$Device,
  [Parameter(Mandatory=$true)][string]$Action,
  [int]$X = 0,
  [int]$Y = 0,
  [string]$Text = "",
  [string]$Out = "qa.png"
)
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$lab = "d:\cts_beta\qa_lab"
switch ($Action) {
  "shot" {
    & $adb -s $Device shell screencap -p /sdcard/qa.png | Out-Null
    & $adb -s $Device pull /sdcard/qa.png "$lab\$Out" | Out-Null
    "SHOT $lab\$Out"
  }
  "tap" {
    & $adb -s $Device shell input tap $X $Y
    "TAP $X $Y"
  }
  "text" {
    $escaped = $Text -replace ' ', '%s' -replace "'", "\'"
    & $adb -s $Device shell input text $escaped
    "TEXT $Text"
  }
  "key" {
    & $adb -s $Device shell input keyevent $X
    "KEY $X"
  }
  "dump" {
    & $adb -s $Device shell uiautomator dump /sdcard/uidump.xml | Out-Null
    & $adb -s $Device pull /sdcard/uidump.xml "$lab\uidump.xml" | Out-Null
    "DUMP $lab\uidump.xml"
  }
  "focus" {
    & $adb -s $Device shell dumpsys window | Select-String -Pattern "mCurrentFocus" | Select-Object -First 3
  }
}