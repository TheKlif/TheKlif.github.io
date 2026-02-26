# Publish script (markdown from external Obsidian publish folder)

$source = "D:\Obsidian\Klif-Brain\Publish"

Get-ChildItem -Path $source -Recurse -Include "*.md" | ForEach-Object {
    $relative = $_.FullName.Substring($source.Length + 1)
    $targetDir = Join-Path ".\Is-This-Anything" (Split-Path $relative)
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir }
    $output = Join-Path $targetDir ($_.BaseName + ".html")
    pandoc $_.FullName -o $output
}

git add .
git commit -m "publish update"
git push

Write-Host "Publish complete."
