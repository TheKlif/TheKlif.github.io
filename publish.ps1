# Publish script (markdown + auto index + dark styling)

$source = "D:\Obsidian\Klif-Brain\Publish"
$site   = ".\Is-This-Anything"

Get-ChildItem -Path $source -Recurse -Include "*.md" | ForEach-Object {
    $relative = $_.FullName.Substring($source.Length + 1)
    $dir      = Split-Path $relative
    $targetDir = Join-Path $site ($dir.ToLower())
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir }

    $slug  = $_.BaseName -replace ' ', '-'
    $slug  = $slug.ToLower()

    $output = Join-Path $targetDir ($slug + ".html")
    pandoc $_.FullName -o $output --css="../style.css"
}

# Build index grouped by folder
$index = @"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <title>All Musings</title>
  <link rel='stylesheet' href='../style.css'>
</head>
<body>
  <h1>All Musings</h1>
"@

$groups = @{}

Get-ChildItem -Path $site -Recurse -Include "*.html" |
    Where-Object { $_.Name -ne "index.html" } |
    ForEach-Object {
        $folder = Split-Path $_.FullName -Parent
        $relFolder = $folder.Substring((Resolve-Path $site).Path.Length + 1).Trim("\").ToLower()
        if ($relFolder -eq "") { $relFolder = "uncategorized" }
        if (-not $groups.ContainsKey($relFolder)) { $groups[$relFolder] = @() }

        $rel = $_.FullName.Substring((Resolve-Path $site).Path.Length + 1).Replace("\", "/")
        $title = $_.BaseName -replace '-', ' '
        $title = (Get-Culture).TextInfo.ToTitleCase($title)
        $groups[$relFolder] += "<li><a href='$rel'>$title</a></li>"
    }

foreach ($group in $groups.GetEnumerator()) {
    $index += "<h2>$($group.Key)</h2><ul>`n"
    $index += ($group.Value -join "`n")
    $index += "`n</ul>`n"
}

$index += @"
</body>
</html>
"@

Set-Content "$site/index.html" $index

git add .
git commit -m "publish update"
git push

Write-Host "Publish complete."
