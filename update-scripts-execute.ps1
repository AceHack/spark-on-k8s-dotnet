Get-ChildItem -Path "*.sh" -Recurse | ForEach-Object { git update-index --chmod=+x "$_" }
