# Publish script (markdown + auto index + dark styling)

$source = "D:\Obsidian\Klif-Brain\Publish"
$site   = ".\Is-This-Anything"

# Convert markdown to HTML (slugified, lowercase)
Get-ChildItem -Path $source -Recurse -Include "*.md" | ForEach-Object {
    $relative = $_.FullName.Substring($source.Length + 1)
    $dir      = Split-Path $relative
    $targetDir = Join-Path $site ($dir.ToLower())
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir }

    $slug  = $_.BaseName -replace ' ', '-'
    $slug  = $slug.ToLower()

    $output = Join-Path $targetDir ($slug + ".html")

(Get-Content $_.FullName) -replace '!\[(.*?)\]\(((?!attachments/)[^)]+)\)', '![$1](attachments/$2)' |
Set-Content $_.FullName

pandoc $_.FullName -o $output `
    --css="/Is-This-Anything/style.css" `
    --resource-path="." `
    --metadata title="$title" `
    --include-before-body="Is-This-Anything/_header.html" `
    --include-after-body="Is-This-Anything/_footer.html"
}

# Auto index (grouped)
$index = @"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <title>All Musings</title>
  <link rel='stylesheet' href='/Is-This-Anything/style.css'>
</head>
<body>
  <h1>All Musings</h1>
"@

$groups = @{}

Get-ChildItem -Path $site -Recurse -Include "*.html" |
    Where-Object { $_.Name -ne "index.html" } |
    ForEach-Object {
        $full = $_.FullName
        $baseSite = (Resolve-Path $site).Path

        $rel = $full.Substring($baseSite.Length).TrimStart("\").Replace("\", "/")
        $folder = Split-Path $rel -Parent
        if ([string]::IsNullOrWhiteSpace($folder)) { $folder = "uncategorized" }

        if (-not $groups.ContainsKey($folder)) { $groups[$folder] = @() }

        $title = $_.BaseName -replace '-', ' '
        $title = (Get-Culture).TextInfo.ToTitleCase($title)
        $groups[$folder] += "<li><a href='$rel'>$title</a></li>"
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

# Copy attachment folders from source to site
Get-ChildItem -Path $source -Recurse -Directory -Filter "attachments" | ForEach-Object {
    $relative = $_.FullName.Substring($source.Length + 1)
    $dest = Join-Path $site $relative

    if (!(Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force
    }

    Copy-Item -Path (Join-Path $_.FullName '*') -Destination $dest -Recurse -Force
}

git add .
git commit -m "publish update"
git push

Write-Host "Publish complete."
