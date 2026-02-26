# Publish script (markdown + auto index, minimal dark)

$site = ".\Is-This-Anything"

# Convert markdown to HTML (slugified, lowercase)
Get-ChildItem -Path "D:\Obsidian\Klif-Brain\Publish" -Recurse -Include "*.md" | ForEach-Object {
    $relative = $_.FullName.Substring("D:\Obsidian\Klif-Brain\Publish".Length + 1)
    $dir = Split-Path $relative
    $targetDir = Join-Path $site ($dir.ToLower())
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir }

    $slug = $_.BaseName -replace ' ', '-'
    $slug = $slug.ToLower()

    $output = Join-Path $targetDir ($slug + ".html")
    pandoc $_.FullName -o $output
}

# Auto index (minimal, dark)
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
  <ul>
"@

Get-ChildItem -Path $site -Recurse -Include "*.html" |
    Where-Object { $_.Name -ne "index.html" } |
    ForEach-Object {
        $rel = $_.FullName.Substring((Resolve-Path $site).Path.Length + 1).Replace("\", "/")
        $title = $_.BaseName -replace '-', ' '
        $title = (Get-Culture).TextInfo.ToTitleCase($title)
        $index += "    <li><a href='$rel'>$title</a></li>`n"
    }

$index += @"
  </ul>
</body>
</html>
"@

Set-Content "$site/index.html" $index

# Git publish
git add .
git commit -m "publish update"
git push

Write-Host "Publish complete."
