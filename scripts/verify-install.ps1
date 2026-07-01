param(
    [string]$MarketplaceName = "codex-subagents-dispatcher",
    [string]$PluginName = "subagent-dispatcher"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    throw "Codex CLI was not found on PATH."
}

$marketplaces = codex plugin marketplace list --json | ConvertFrom-Json
$marketplace = $marketplaces.marketplaces | Where-Object { $_.name -eq $MarketplaceName } | Select-Object -First 1
if (-not $marketplace) {
    throw "Marketplace not configured: $MarketplaceName. Run scripts/install.ps1 first."
}

$plugins = codex plugin list --json | ConvertFrom-Json
$pluginId = "$PluginName@$MarketplaceName"
$plugin = $plugins.installed | Where-Object { $_.pluginId -eq $pluginId } | Select-Object -First 1
if (-not $plugin) {
    throw "Plugin is not installed: $pluginId. Run scripts/install.ps1 first."
}

if (-not $plugin.enabled) {
    throw "Plugin is installed but disabled: $pluginId. Enable it in Codex Plugins or ~/.codex/config.toml."
}

Write-Host "Verified marketplace: $MarketplaceName"
Write-Host "Verified installed plugin: $pluginId"
Write-Host "Open a new Codex thread so the plugin skill is loaded."
