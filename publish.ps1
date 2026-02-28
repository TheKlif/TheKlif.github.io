# Publish script (markdown + auto index + dark styling)

$source = "D:\Obsidian\Klif-Brain\Publish"
$site   = "D:\Is This Anything\TheKlif.github.io\Is-This-Anything"

# Convert markdown to HTML (slugified, lowercase)
Get-ChildItem -Path $source -Recurse -Include "*.md" | ForEach-Object {
    $relative = $_.FullName.Substring($source.Length + 1)
    $dir      = Split-Path $relative
    $targetDir = Join-Path $site ($dir.ToLower())
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir }

    $slug  = $_.BaseName -replace ' ', '-'
    $slug  = $slug.ToLower()

    $title = "$($_.BaseName) - Is This Anything?"

    $output = Join-Path $targetDir ($slug + ".html")

    # Read markdown (do not modify source)
    $content = Get-Content $_.FullName -Raw
    Write-Host "Processing file: $($_.FullName)"

    # (blank line normalization disabled for troubleshooting)

    # Convert Obsidian [!info] callouts to Pandoc div blocks
    $pattern = '(?ms)^\s*>\s*\[!info\]\s*(.*?)\r?\n((?:\s*>\s*.*\r?\n?)*)'

    $content = [regex]::Replace($content, $pattern, {
    param($match)

    $title = $match.Groups[1].Value.Trim()
    $body  = $match.Groups[2].Value

    # strip leading '>' from every body line
    $body = $body -replace '(?m)^\s*>\s?', ''

    return "`n::: {.info}`n`n**$title**`n`n$body`n:::`n"
})

    # write to temp file for pandoc
    $temp = "$env:TEMP\publish_temp.md"

    Push-Location $source

    pandoc "$_.FullName" -o $output `
        --from=markdown `
        --standalone `
        --resource-path="$source" `
        --metadata title="$title" `
        --include-before-body="$site\_header.html" `
        --include-after-body="$site\_footer.html"

    Pop-Location
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

foreach ($group in ($groups.GetEnumerator() | Sort-Object Name)) {

    if ($group.Key -eq "uncategorized") {
        continue
    }

    $heading = (Get-Culture).TextInfo.ToTitleCase($group.Key)
    $index += "<h2>$heading</h2><ul>`n"
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

if ($LASTEXITCODE -eq 0) {
    git add .
    git commit -m $COMMITMSG
    git push
} else {
    Write-Host "Publish failed; not committing."
}

Write-Host "Publish complete."
