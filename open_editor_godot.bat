@echo off
chcp 65001 > nul
echo ========================================================
echo   Запуск визуального редактора Godot 4.3 (Проект Юки 3D)
echo ========================================================
cd /d "%~dp0"
start "" "..\godot-engine\Godot_v4.3-stable_win64.exe" -e --path "%~dp0godot_project"
