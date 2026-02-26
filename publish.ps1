# Publish script with Markdown support

Get-ChildItem -Path '.\Publish' -Recurse -Include '*.md' | ForEach-Object {
     = .FullName.Substring((Resolve-Path '.\Publish').Path.Length + 1)
     = Join-Path '.\Is-This-Anything' (Split-Path )
    if (!(Test-Path )) { New-Item -ItemType Directory -Path  }
     = Join-Path  (.BaseName + '.html')
    pandoc .FullName -o 
}

Copy-Item -Path '.\Publish\*.html' -Destination '.\Is-This-Anything\' -Recurse -Force -ErrorAction SilentlyContinue

git add .
git commit -m "publish update"
git push

Write-Host "Publish complete."
