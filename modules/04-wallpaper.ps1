# ============================================================
#  WIN 8.1 ULTRA TUNE - Module 04: Wallpaper generator
#  Draws a dark purple night landscape (moon over a lake) with
#  System.Drawing and saves it as wallpaper.png. No internet needed.
# ============================================================

Write-Host "   Generating wallpaper..."

Add-Type -AssemblyName System.Drawing

$w = 1920
$h = 1080
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Night sky gradient: deep navy -> purple horizon
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
$sky = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(255, 10, 8, 30), [System.Drawing.Color]::FromArgb(255, 70, 30, 110), 90)
$g.FillRectangle($sky, $rect)
$sky.Dispose()

# Stars
$rand = New-Object System.Random
for ($i = 0; $i -lt 400; $i++) {
    $x = $rand.Next(0, $w)
    $y = $rand.Next(0, [int]($h * 0.75))
    $a = $rand.Next(60, 220)
    $s = $rand.Next(1, 3)
    $star = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($a, 255, 255, 255))
    $g.FillEllipse($star, $x, $y, $s, $s)
    $star.Dispose()
}

# Moon with glow
$mx = [int]($w * 0.72)
$my = [int]($h * 0.25)
$mr = 110
$r = $mr + 120
while ($r -gt $mr) {
    $glow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(5, 210, 190, 255))
    $g.FillEllipse($glow, ($mx - $r), ($my - $r), (2 * $r), (2 * $r))
    $glow.Dispose()
    $r -= 4
}
$moon = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 235, 225, 255))
$g.FillEllipse($moon, ($mx - $mr), ($my - $mr), (2 * $mr), (2 * $mr))
$moon.Dispose()
# Craters
$craters = @(@(-30, -20, 28), @(20, 10, 18), @(0, 45, 14), @(40, -35, 12))
foreach ($c in $craters) {
    $cb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 120, 100, 180))
    $g.FillEllipse($cb, ($mx + $c[0]), ($my + $c[1]), $c[2], $c[2])
    $cb.Dispose()
}

# Mountain silhouettes
$pts = @(
    (New-Object System.Drawing.Point(0, [int]($h * 0.72))),
    (New-Object System.Drawing.Point([int]($w * 0.2), [int]($h * 0.55))),
    (New-Object System.Drawing.Point([int]($w * 0.38), [int]($h * 0.70))),
    (New-Object System.Drawing.Point([int]($w * 0.55), [int]($h * 0.60))),
    (New-Object System.Drawing.Point([int]($w * 0.75), [int]($h * 0.74))),
    (New-Object System.Drawing.Point($w, [int]($h * 0.66))),
    (New-Object System.Drawing.Point($w, $h)),
    (New-Object System.Drawing.Point(0, $h))
)
$mtn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 12, 8, 26))
$g.FillPolygon($mtn, $pts)
$mtn.Dispose()

# Lake with moon reflection
$lakeRect = New-Object System.Drawing.Rectangle(0, [int]($h * 0.8), $w, [int]($h * 0.2))
$lake = New-Object System.Drawing.Drawing2D.LinearGradientBrush($lakeRect, [System.Drawing.Color]::FromArgb(255, 20, 12, 40), [System.Drawing.Color]::FromArgb(255, 50, 25, 80), 90)
$g.FillRectangle($lake, $lakeRect)
$lake.Dispose()
$refl = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 220, 205, 255))
$g.FillEllipse($refl, ($mx - 60), [int]($h * 0.82), 120, [int]($h * 0.16))
$refl.Dispose()

$g.Dispose()

$outDir = Join-Path $env:USERPROFILE "Win81UltraTune"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$out = Join-Path $outDir "wallpaper.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Host ("   Wallpaper saved: " + $out)
