@echo off
chcp 65001 > nul
echo ========================================================
echo   Yuki Pocket Companion - Запуск тестов игрового движка
echo ========================================================
echo.
"C:\Users\User1\.gemini\antigravity\scratch\godot-engine\Godot_v4.3-stable_win64_console.exe" --headless --path "%~dp0godot_project" -s res://tests/test_interactions.gd
pause
