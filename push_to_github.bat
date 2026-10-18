@echo off
chcp 65001 > nul
echo ========================================================
echo   Отправка проекта "Юки 3D (Talking Tom Style)" на GitHub
echo   Репозиторий: https://github.com/228burger228/GameMykorman
echo ========================================================
echo.

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ОШИБКА] Утилита Git не найдена в системе!
    echo Пожалуйста, установите Git с официального сайта: https://git-scm.com/downloads
    echo или используйте GitHub Desktop: https://desktop.github.com/
    echo.
    pause
    exit /b
)

cd /d "%~dp0"

echo [1/5] Проверка / инициализация Git репозитория...
if not exist ".git" (
    git init
    git branch -M main
    git remote add origin https://github.com/228burger228/GameMykorman.git
)

echo [2/5] Добавление файлов проекта...
git add .

echo [3/5] Создание коммита...
git commit -m "feat: upgrade to 3D Talking Tom engine with WebGL, swipe rooms, voice repeater and interactive physics"

echo [4/5] Отправка на GitHub в ветку main...
git push -u origin main

echo.
echo ========================================================
echo   Готово! Обновленная 3D-игра успешно выгружена на GitHub.
echo ========================================================
pause
