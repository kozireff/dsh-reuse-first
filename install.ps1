# Устанавливает правило «не изобретать колесо» в глобальные настройки DSH.
# Запуск: powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = 'Stop'
$dsh = Join-Path $env:USERPROFILE '.dsh'
$skillSrc = Join-Path $PSScriptRoot 'skills\reuse-first'
$gateSrc = Join-Path $PSScriptRoot 'GATE.md'
$skillDst = Join-Path $dsh 'skills\reuse-first'
$agents = Join-Path $dsh 'AGENTS.md'
$marker = '## Build vs reuse — GATE'

if (-not (Test-Path $gateSrc)) { throw "Не найден GATE.md рядом со скриптом: $gateSrc" }
if (-not (Test-Path $skillSrc)) { throw "Не найдена папка скилла: $skillSrc" }

# 1) скилл
New-Item -ItemType Directory -Force -Path (Split-Path $skillDst) | Out-Null
if (Test-Path $skillDst) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    Copy-Item $skillDst "$skillDst.bak-$stamp" -Recurse -Force
    Write-Host "Старый скилл сохранён: $skillDst.bak-$stamp"
    Remove-Item $skillDst -Recurse -Force
}
Copy-Item $skillSrc $skillDst -Recurse -Force
Write-Host "Скилл установлен: $skillDst"

# 2) правило в AGENTS.md
New-Item -ItemType Directory -Force -Path $dsh | Out-Null
if (-not (Test-Path $agents)) {
    Set-Content -Path $agents -Value "# Global agent rules`r`n" -NoNewline -Encoding utf8
    Write-Host "Создан новый AGENTS.md: $agents"
}
$current = Get-Content $agents -Raw
if ($current -match [regex]::Escape($marker)) {
    Write-Host "Раздел-шлюз уже есть в $agents — пропускаю (обновить вручную, если нужна новая версия)."
} else {
    Add-Content -Path $agents -Value "`r`n" -NoNewline
    Get-Content $gateSrc -Raw | Add-Content -Path $agents -NoNewline -Encoding utf8
    Write-Host "Раздел-шлюз добавлен в $agents"
}

Write-Host ''
Write-Host 'Готово. Перезапустите DSH (глобальные инструкции читаются при старте сессии).'
Write-Host 'Проверка: попросите агента «сделай инструмент для X» — он должен сначала загрузить скилл reuse-first'
Write-Host 'и показать таблицу кандидатов (маркет DSH / npm / GitHub / Hugging Face), а не писать код сразу.'
