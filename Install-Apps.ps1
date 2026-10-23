if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$apps = Get-Content (Join-Path $PSScriptRoot 'apps.json') -Raw -Encoding UTF8 | ConvertFrom-Json

$form = New-Object System.Windows.Forms.Form
$form.Text = 'PC-APP Installer'
$form.Size = New-Object System.Drawing.Size(460, 560)
$form.StartPosition = 'CenterScreen'

$list = New-Object System.Windows.Forms.CheckedListBox
$list.CheckOnClick = $true
$list.Location = New-Object System.Drawing.Point(10, 10)
$list.Size = New-Object System.Drawing.Size(420, 330)
foreach ($a in $apps) { [void]$list.Items.Add($a.name) }
$form.Controls.Add($list)

$btnAll = New-Object System.Windows.Forms.Button
$btnAll.Text = 'Alle auswählen'
$btnAll.Location = New-Object System.Drawing.Point(10, 350)
$btnAll.Size = New-Object System.Drawing.Size(130, 30)
$btnAll.Add_Click({ for ($i = 0; $i -lt $list.Items.Count; $i++) { $list.SetItemChecked($i, $true) } })
$form.Controls.Add($btnAll)

$btnGo = New-Object System.Windows.Forms.Button
$btnGo.Text = 'Installieren'
$btnGo.Location = New-Object System.Drawing.Point(300, 350)
$btnGo.Size = New-Object System.Drawing.Size(130, 30)
$form.Controls.Add($btnGo)

$bar = New-Object System.Windows.Forms.ProgressBar
$bar.Location = New-Object System.Drawing.Point(10, 390)
$bar.Size = New-Object System.Drawing.Size(420, 20)
$form.Controls.Add($bar)

$log = New-Object System.Windows.Forms.TextBox
$log.Multiline = $true
$log.ReadOnly = $true
$log.ScrollBars = 'Vertical'
$log.Location = New-Object System.Drawing.Point(10, 420)
$log.Size = New-Object System.Drawing.Size(420, 85)
$form.Controls.Add($log)

$btnGo.Add_Click({
    $sel = @($list.CheckedIndices | ForEach-Object { $apps[$_] })
    if ($sel.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show('Bitte mindestens eine App auswählen.'); return }
    $btnGo.Enabled = $false
    $bar.Maximum = $sel.Count
    $bar.Value = 0
    $log.Clear()
    foreach ($a in $sel) {
        $log.AppendText("Installiere $($a.name) ...`r`n")
        [System.Windows.Forms.Application]::DoEvents()
        $p = Start-Process winget -ArgumentList "install --id $($a.id) -e --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -WindowStyle Hidden
        if ($p.ExitCode -eq 0) { $log.AppendText("  OK: $($a.name)`r`n") }
        else { $log.AppendText("  FEHLER ($($p.ExitCode)): $($a.name)`r`n") }
        $bar.Value++
        [System.Windows.Forms.Application]::DoEvents()
    }
    $log.AppendText("Fertig.`r`n")
    $btnGo.Enabled = $true
})

[void]$form.ShowDialog()
