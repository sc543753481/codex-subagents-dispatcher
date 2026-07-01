$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $root "plugins/subagent-dispatcher"
$manifestPath = Join-Path $pluginRoot ".codex-plugin/plugin.json"
$skillPath = Join-Path $pluginRoot "skills/subagent-dispatcher/SKILL.md"
$marketplacePath = Join-Path $root ".agents/plugins/marketplace.json"
$readmePath = Join-Path $root "README.md"
$zhReadmePath = Join-Path $root "README.zh-CN.md"

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
Assert-File $zhReadmePath
Assert-Directory (Join-Path $pluginRoot "skills/subagent-dispatcher/references")
Assert-File (Join-Path $root "LICENSE")
Assert-File (Join-Path $root ".gitignore")
Assert-File (Join-Path $root "scripts/install.ps1")
Assert-File (Join-Path $root "scripts/install.sh")
Assert-File (Join-Path $root "scripts/verify-install.ps1")
Assert-File (Join-Path $root "docs/design.md")
Assert-File (Join-Path $root "examples/research.md")
Assert-File (Join-Path $root "examples/debugging.md")
Assert-File (Join-Path $root "examples/coding.md")

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$marketplace = Get-Content -Raw -LiteralPath $marketplacePath | ConvertFrom-Json
$skill = Get-Content -Raw -LiteralPath $skillPath
$readme = Get-Content -Raw -LiteralPath $readmePath
$zhReadme = Get-Content -Raw -LiteralPath $zhReadmePath

if ($manifest.name -ne "subagent-dispatcher") {
    throw "plugin.json name must be subagent-dispatcher"
}

if ($manifest.skills -ne "./skills/") {
    throw "plugin.json skills must point to ./skills/"
}

if ($manifest.repository -notmatch "github\.com/sc543753481/codex-subagents-dispatcher") {
    throw "plugin.json must include repository metadata"
}

if ($manifest.interface.websiteURL -notmatch "github\.com/sc543753481/codex-subagents-dispatcher") {
    throw "plugin.json interface must include websiteURL metadata"
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

if ($zhReadme -notmatch "AGENTS\.md") {
    throw "README.zh-CN.md must document standing authorization via AGENTS.md"
}

if ($readme -notmatch "README\.zh-CN\.md") {
    throw "README.md must link to README.zh-CN.md"
}

if ($zhReadme -notmatch "README\.md") {
    throw "README.zh-CN.md must link to README.md"
}

if ($readme -notmatch "raw\.githubusercontent\.com/sc543753481/codex-subagents-dispatcher") {
    throw "README.md must document one-line remote installers"
}

if ($readme -notmatch "codex://plugins/install/subagent-dispatcher") {
    throw "README.md must document the Codex app plugin install deep link boundary"
}

if ($readme -notmatch "verify-install\.ps1") {
    throw "README.md must document install verification"
}

if ($zhReadme -notmatch "verify-install\.ps1") {
    throw "README.zh-CN.md must document install verification"
}

$scan = Get-ChildItem -LiteralPath $root -Recurse -File -Force |
    Where-Object { $_.FullName -ne $PSCommandPath } |
    Where-Object { $_.FullName -notlike (Join-Path $root ".git/*") } |
    Select-String -Pattern "TODO|\[TODO|placeholder|Local developer" -ErrorAction SilentlyContinue
if ($scan) {
    throw "Found template residue: $($scan | Select-Object -First 1)"
}

Write-Host "subagent-dispatcher repository check passed"
