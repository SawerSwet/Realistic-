# ============================================================
#  WIN 8.1 ULTRA TUNE - Module 04: Wallpaper generator (v2)
#  Smooth purple night landscape: moon with soft glow, two
#  mountain layers, lake with shimmering reflection.
#  No internet needed.
# ============================================================

Write-Host "   Generating wallpaper (v2)..."

Add-Type -AssemblyName System.Drawing

$w = 1920
$h = 1080
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Night sky gradient: deep navy -> violet horizon
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
$sky = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(255, 8, 6, 28), [System.Drawing.Color]::FromArgb(255, 88, 44, 130), 90)
$g.FillRectangle($sky, $rect)
$sky.Dispose()

# Stars
$rand = New-Object System.Random
for ($i = 0; $i -lt 450; $i++) {
    $x = $rand.Next(0, $w)
    $y = $rand.Next(0, [int]($h * 0.70))
    $a = $rand.Next(50, 210)
    $s = $rand.Next(1, 3)
    $star = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($a, 255, 255, 255))
    $g.FillEllipse($star, $x, $y, $s, $s)
    $star.Dispose()
}

# Moon with large soft glow
$mx = [int]($w * 0.74)
$my = [int]($h * 0.24)
$mr = 95
$r = $mr + 160
while ($r -gt $mr) {
    $glow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(6, 215, 195, 255))
    $g.FillEllipse($glow, ($mx - $r), ($my - $r), (2 * $r), (2 * $r))
    $glow.Dispose()
    $r -= 5
}
$moon = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 232, 255))
$g.FillEllipse($moon, ($mx - $mr), ($my - $mr), (2 * $mr), (2 * $mr))
$moon.Dispose()
# Soft craters
$craters = @(@(-28, -18, 24), @(18, 8, 16), @(-2, 38, 12), @(34, -30, 11))
foreach ($c in $craters) {
    $cb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(45, 125, 105, 185))
    $g.FillEllipse($cb, ($mx + $c[0]), ($my + $c[1]), $c[2], $c[2])
    $cb.Dispose()
}

# Far mountain layer: smooth wave silhouette
$farPts = New-Object System.Collections.Generic.List[System.Drawing.Point]
for ($x = 0; $x -le $w; $x += 32) {
    $y = [int]($h * 0.60 + [Math]::Sin($x / 210.0) * 55 + [Math]::Sin($x / 71.0) * 22)
    [void]$farPts.Add((New-Object System.Drawing.Point($x, $y)))
}
[void]$farPts.Add((New-Object System.Drawing.Point($w, $h)))
[void]$farPts.Add((New-Object System.Drawing.Point(0, $h)))
$farBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 62, 40, 105))
$g.FillPolygon($farBrush, $farPts.ToArray())
$farBrush.Dispose()

# Near mountain layer: darker, lower
$nearPts = New-Object System.Collections.Generic.List[System.Drawing.Point]
for ($x = 0; $x -le $w; $x += 32) {
    $y = [int]($h * 0.70 + [Math]::Sin($x / 160.0 + 2.0) * 40 + [Math]::Sin($x / 53.0) * 16)
    [void]$nearPts.Add((New-Object System.Drawing.Point($x, $y)))
}
[void]$nearPts.Add((New-Object System.Drawing.Point($w, $h)))
[void]$nearPts.Add((New-Object System.Drawing.Point(0, $h)))
$nearBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 16, 10, 34))
$g.FillPolygon($nearBrush, $nearPts.ToArray())
$nearBrush.Dispose()

# Lake: dark violet gradient at the bottom
$lakeTop = [int]($h * 0.78)
$lakeRect = New-Object System.Drawing.Rectangle(0, $lakeTop, $w, ($h - $lakeTop))
$lake = New-Object System.Drawing.Drawing2D.LinearGradientBrush($lakeRect, [System.Drawing.Color]::FromArgb(255, 26, 16, 52), [System.Drawing.Color]::FromArgb(255, 58, 32, 96), 90)
$g.FillRectangle($lake, $lakeRect)
$lake.Dispose()

# Moon reflection: shimmering horizontal streaks (no ugly blob)
for ($i = 0; $i -lt 26; $i++) {
    $ry = $lakeTop + 8 + $i * (($h - $lakeTop - 20) / 26.0)
    $rw = 150 - $i * 3 + $rand.Next(-25, 25)
    if ($rw -lt 30) { $rw = 30 }
    $rh = 3 + $rand.Next(0, 5)
    $ra = [Math]::Max(8, 40 - $i)
    $streak = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($ra, 225, 210, 255))
    $g.FillEllipse($streak, ($mx - $rw / 2), [int]$ry, $rw, $rh)
    $streak.Dispose()
}

# Subtle horizon glow line
$glowLine = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 190, 160, 255))
$g.FillRectangle($glowLine, 0, ($lakeTop - 2), $w, 3)
$glowLine.Dispose()

$g.Dispose()

$outDir = Join-Path $env:USERPROFILE "Win81UltraTune"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$out = Join-Path $outDir "wallpaper.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Host ("   Wallpaper saved: " + $out)
