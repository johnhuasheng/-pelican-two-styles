@echo off
setlocal DisableDelayedExpansion
title Pelican Coast Club
set "APP=%~dp0index.html"
if not exist "%APP%" (
  echo index.html was not found.
  echo Extract the complete ZIP first. Keep this launcher next to index.html.
  pause
  exit /b 1
)
start "" "%APP%"
if errorlevel 1 (
  echo Could not open the page with your default browser.
  echo Open index.html with Edge, Chrome, Firefox, or Safari.
  pause
  exit /b 1
)
exit /b 0
