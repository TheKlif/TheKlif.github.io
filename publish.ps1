# Publish script (basic version)

# 1. Copy published content into site folder
Copy-Item -Path '.\Publish\*' -Destination '.\Is-This-Anything\' -Recurse -Force

# 2. Git operations
git add .
git commit -m 'publish update'
git push

Write-Host 'Publish complete.'
