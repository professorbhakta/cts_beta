param([string]$Path, [string]$Filter = "")
$raw = Get-Content -Raw -Encoding UTF8 $Path
Write-Host "len=$($raw.Length)"
$matches = [regex]::Matches($raw, '<node [^>]*?>')
foreach ($m in $matches) {
  $n = $m.Value
  $desc = ""
  $text = ""
  $bounds = ""
  $dm = [regex]::Match($n, 'content-desc="([^"]*)"')
  if ($dm.Success) { $desc = $dm.Groups[1].Value }
  $tm = [regex]::Match($n, ' text="([^"]*)"')
  if ($tm.Success) { $text = $tm.Groups[1].Value }
  $bm = [regex]::Match($n, 'bounds="([^"]*)"')
  if ($bm.Success) { $bounds = $bm.Groups[1].Value }
  $click = $n.Contains('clickable="true"')
  if (-not $desc -and -not $text) { continue }
  $line = "{0} | click={1} | {2} | {3}" -f $bounds, $click, $desc, $text
  if ($Filter -and ($line -notmatch $Filter)) { continue }
  Write-Host $line
}
