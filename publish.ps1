# Publish script with Markdown support

# 1. Convert Markdown files in Publish to HTML and place in site folder
Get-ChildItem -Path '.\Publish' -Recurse -Include '*.md' | ForEach-Object {
     = .FullName.Substring((Resolve-Path '.\Publish').Path.Length + 1)
     = Join-Path '.\Is-This-Anything' (Split-Path )
    if (!(Test-Path )) { New-Item -ItemType Directory -Path  }
     = Join-Path  (.BaseName + '.html')
    pandoc .FullName -o 
}

# 2. Also copy any existing HTML files in Publish (if you use them)
Copy-Item -Path '.\Publish\*.html' -Destination '.\Is-This-Anything\' -Recurse -Force -ErrorAction SilentlyContinue

# 3. Git operations
git add .
git commit -m 'publish update'
git push

Write-Host 'Publish complete.'
