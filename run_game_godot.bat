@echo off
chcp 65001 > nul
echo ========================================================
echo   Запуск игры "Юки 3D: Pocket Companion" на Godot 4.3
echo ========================================================
cd /d "%~dp0"
start "" "..\godot-engine\Godot_v4.3-stable_win64.exe" --path "%~dp0godot_project"
