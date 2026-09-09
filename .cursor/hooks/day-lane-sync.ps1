# Day-lane sync for this machine (online/offline safe).
# Modes: pull (sessionStart) | push (stop)
# Never force. Only professor-cts / professor-dock.

param(
  [ValidateSet("pull", "push")]
  [string]$Mode = "push",
  [string]$RepoRoot = "",
  [string]$DayBranch = ""
)

$ErrorActionPreference = "Continue"

function Finish([string]$msg) {
  if ($msg) { [Console]::Error.WriteLine($msg) }
  Write-Output "{}"
}

try { $null = [Console]::In.ReadToEnd() } catch { }

if (-not $RepoRoot) { $RepoRoot = (Get-Location).Path }
if (-not (Test-Path (Join-Path $RepoRoot ".git"))) {
  Finish ""
  exit 0
}

$allowed = @("professor-cts", "professor-dock")

Push-Location $RepoRoot
try {
  $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
  if (-not $branch -or $branch -eq "HEAD") {
    Finish ""
    exit 0
  }

  if ($DayBranch -and $branch -ne $DayBranch) {
    Finish "Day-lane $Mode skipped: on '$branch' (day lane is '$DayBranch')."
    exit 0
  }
  if ($allowed -notcontains $branch) {
    Finish "Day-lane $Mode skipped: '$branch' is not a day lane."
    exit 0
  }

  # Offline-friendly: fetch may fail — never crash the agent turn
  $fetch = git fetch origin $branch 2>&1 | Out-String
  if ($LASTEXITCODE -ne 0) {
    Finish "Day-lane $Mode: offline or fetch failed for $branch (local work kept)."
    exit 0
  }

  git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null | Out-Null
  $hasUpstream = ($LASTEXITCODE -eq 0)

  if ($Mode -eq "pull") {
    if (-not $hasUpstream) {
      git branch --set-upstream-to="origin/$branch" $branch 2>$null | Out-Null
    }
    $dirty = (git status --porcelain 2>$null)
    if ($dirty) {
      Finish "Day-lane pull skipped: dirty working tree on $branch (commit/stash first)."
      exit 0
    }
    $out = git pull --ff-only origin $branch 2>&1 | Out-String
    [Console]::Error.WriteLine($out)
    if ($LASTEXITCODE -ne 0) {
      Finish "Day-lane pull: ff-only failed on $branch (manual merge needed)."
    } else {
      Finish "Day-lane pull OK: $branch synced from origin."
    }
    exit 0
  }

  # Mode = push
  if (-not $hasUpstream) {
    $out = git push -u origin $branch 2>&1 | Out-String
    [Console]::Error.WriteLine($out)
    if ($LASTEXITCODE -ne 0) {
      Finish "Day-lane push: offline or push failed for $branch."
    } else {
      Finish "Day-lane push OK: $branch (set upstream)."
    }
    exit 0
  }

  $counts = (git rev-list --left-right --count "@{u}...HEAD" 2>$null).Trim()
  if (-not $counts) {
    Finish ""
    exit 0
  }
  $parts = $counts -split "\s+"
  $behind = [int]$parts[0]
  $ahead = [int]$parts[1]

  if ($ahead -gt 0 -and $behind -eq 0) {
    $out = git push origin $branch 2>&1 | Out-String
    [Console]::Error.WriteLine($out)
    if ($LASTEXITCODE -ne 0) {
      Finish "Day-lane push: offline or push failed ($ahead local commit(s) kept)."
    } else {
      Finish "Day-lane push OK: $ahead commit(s) on $branch."
    }
  } elseif ($ahead -gt 0 -and $behind -gt 0) {
    Finish "Day-lane push skipped: $branch diverged (ahead $ahead, behind $behind)."
  } else {
    Finish "Day-lane push: $branch already in sync."
  }
} finally {
  Pop-Location
}

exit 0
