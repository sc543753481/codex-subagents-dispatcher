param(
    [string]$Source = "https://github.com/sc543753481/codex-subagents-dispatcher.git",
    [string]$Ref = "",
    [string[]]$Sparse = @(),
    [switch]$Authorize,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$marketplaceName = "codex-subagents-dispatcher"
$pluginName = "subagent-dispatcher"
$authorizationText = "When a task can be split into independent workstreams, prefer the subagent-dispatcher workflow and use up to 5 subagents by default, up to 8 for read-only research. Before spawning subagents, briefly state the split, whether each agent is read-only or may edit files, and how results will be synthesized."

if (-not $DryRun -and -not (Get-Command codex -ErrorAction SilentlyContinue)) {
    throw "Codex CLI was not found on PATH. Install and sign in to Codex, then run this installer again."
}

function Invoke-Codex {
    param([string[]]$Arguments)

    if ($DryRun) {
        Write-Host ("codex " + ($Arguments -join " "))
        return
    }

    & codex @Arguments
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

$marketplaceArgs = @("plugin", "marketplace", "add", $Source)
if ($Ref) {
    $marketplaceArgs += @("--ref", $Ref)
}
foreach ($path in $Sparse) {
    if ($path) {
        $marketplaceArgs += @("--sparse", $path)
    }
}

$marketplaceList = if ($DryRun) { "" } else { (& codex plugin marketplace list 2>$null) -join "`n" }
if ($marketplaceList -match "(?m)^$([regex]::Escape($marketplaceName))\s") {
    Write-Host "Marketplace already configured: $marketplaceName"
} else {
    Write-Host "Adding Codex plugin marketplace: $Source"
    Invoke-Codex $marketplaceArgs
}

$pluginSelector = "$pluginName@$marketplaceName"
$pluginList = if ($DryRun) { "" } else { (& codex plugin list 2>$null) -join "`n" }
if ($pluginList -match "(?m)^$([regex]::Escape($pluginSelector))\s+installed") {
    Write-Host "Plugin already installed: $pluginSelector"
} else {
    Write-Host "Installing $pluginName from $marketplaceName"
    Invoke-Codex @("plugin", "add", $pluginSelector)
}

$shouldAuthorize = $Authorize -or $env:SUBAGENT_DISPATCHER_AUTHORIZE -eq "1"
if ($shouldAuthorize) {
    $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
    $agentsPath = Join-Path $codexHome "AGENTS.md"

    if ($DryRun) {
        Write-Host "Would ensure authorization in $agentsPath"
    } else {
        New-Item -ItemType Directory -Force -Path $codexHome | Out-Null
        $existing = if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
            Get-Content -Raw -LiteralPath $agentsPath
        } else {
            ""
        }

        if ($existing -like "*subagent-dispatcher workflow*") {
            Write-Host "AGENTS.md authorization already present: $agentsPath"
        } else {
            $prefix = if ($existing.Trim()) { "`n`n" } else { "" }
            Add-Content -LiteralPath $agentsPath -Value "$prefix# subagent-dispatcher`n`n$authorizationText"
            Write-Host "Added AGENTS.md authorization: $agentsPath"
        }
    }
}

Write-Host ""
Write-Host "Ready: $pluginName."
Write-Host "Open a new Codex thread, then ask Codex to use subagent-dispatcher."
