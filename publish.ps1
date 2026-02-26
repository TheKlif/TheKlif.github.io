# Publish script (simple markdown conversion)

Get-ChildItem -Path ".\Publish" -Recurse -Include "*.md" | ForEach-Object {
    $relative = $_.FullName.Substring((Resolve-Path ".\Publish").Path.Length + 1)
    $targetDir = Join-Path ".\Is-This-Anything" (Split-Path $relative)
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir }
    $output = Join-Path $targetDir ($_.BaseName + ".html")
    pandoc $_.FullName -o $output
}

git add .
git commit -m "publish update"
git push

Write-Host "Publish complete."
