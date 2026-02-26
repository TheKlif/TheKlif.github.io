# Publish script (external Obsidian + slugified filenames + lowercase directories)

$source = "D:\Obsidian\Klif-Brain\Publish"

Get-ChildItem -Path $source -Recurse -Include "*.md" | ForEach-Object {
    $relative = $_.FullName.Substring($source.Length + 1)
    $dir = Split-Path $relative

    # lowercase directory path
    $targetDir = Join-Path ".\Is-This-Anything" ($dir.ToLower())
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir }

    # slugify filename (no spaces, lowercase)
    $slug = $_.BaseName -replace ' ', '-'
    $slug = $slug.ToLower()

    $output = Join-Path $targetDir ($slug + ".html")
    pandoc $_.FullName -o $output
}

git add .
git commit -m "publish update"
git push

Write-Host "Publish complete."
