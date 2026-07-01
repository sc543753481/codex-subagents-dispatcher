$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $root "plugins/subagent-dispatcher"
$manifestPath = Join-Path $pluginRoot ".codex-plugin/plugin.json"
$skillPath = Join-Path $pluginRoot "skills/subagent-dispatcher/SKILL.md"
$marketplacePath = Join-Path $root ".agents/plugins/marketplace.json"
$readmePath = Join-Path $root "README.md"

function Assert-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing file: $Path"
    }
}

function Assert-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Missing directory: $Path"
    }
}

Assert-File $manifestPath
Assert-File $skillPath
Assert-File $marketplacePath
Assert-File $readmePath
Assert-Directory (Join-Path $pluginRoot "skills/subagent-dispatcher/references")
Assert-File (Join-Path $root "LICENSE")
Assert-File (Join-Path $root ".gitignore")
Assert-File (Join-Path $root "docs/design.md")
Assert-File (Join-Path $root "examples/research.md")
Assert-File (Join-Path $root "examples/debugging.md")
Assert-File (Join-Path $root "examples/coding.md")

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$marketplace = Get-Content -Raw -LiteralPath $marketplacePath | ConvertFrom-Json
$skill = Get-Content -Raw -LiteralPath $skillPath
$readme = Get-Content -Raw -LiteralPath $readmePath

if ($manifest.name -ne "subagent-dispatcher") {
    throw "plugin.json name must be subagent-dispatcher"
}

if ($manifest.skills -ne "./skills/") {
    throw "plugin.json skills must point to ./skills/"
}

$entry = $marketplace.plugins | Where-Object { $_.name -eq "subagent-dispatcher" } | Select-Object -First 1
if (-not $entry) {
    throw "marketplace.json missing subagent-dispatcher entry"
}

if ($entry.source.path -ne "./plugins/subagent-dispatcher") {
    throw "marketplace source.path must be ./plugins/subagent-dispatcher"
}

if ($skill -notmatch "name:\s*subagent-dispatcher") {
    throw "SKILL.md missing subagent-dispatcher frontmatter name"
}

if ($readme -notmatch "AGENTS\.md") {
    throw "README.md must document standing authorization via AGENTS.md"
}

$scan = Get-ChildItem -LiteralPath $root -Recurse -File -Force |
    Where-Object { $_.FullName -ne $PSCommandPath } |
    Where-Object { $_.FullName -notlike (Join-Path $root ".git/*") } |
    Select-String -Pattern "TODO|\[TODO|placeholder|Local developer" -ErrorAction SilentlyContinue
if ($scan) {
    throw "Found template residue: $($scan | Select-Object -First 1)"
}

Write-Host "subagent-dispatcher repository check passed"
