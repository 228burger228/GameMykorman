/**
 * ЮКИ 3D — СТУДИЙНЫЙ 3D-ДВИЖОК ДЛЯ КАРМАННОГО КОМПАНЬОНА (V2 PRO)
 * Технологии: Three.js WebGL + Процедурные HD-текстуры (Canvas) + Studio Lighting + Toon Anime Shading + WebAudio DSP
 */

// --- 1. ГЛОБАЛЬНОЕ СОСТОЯНИЕ ИГРЫ ---
const gameState = {
  name: 'Юки',
  level: 1,
  xp: 40,
  gold: 350,
  crystals: 25,
  hunger: 85,
  hygiene: 90,
  energy: 75,
  mood: 95,
  currentRoom: 0, // 0: Гостиная, 1: Кухня, 2: Ванная, 3: Спальня
  isSleeping: false,
  soundEnabled: true,
  outfit: 'pink'
};

// --- 2. ГЕНЕРАТОР ПРОЦЕДУРНЫХ HD-ТЕКСТУР (TEXTURE STUDIO) ---
// Превращает плоские примитивы в высокодетализированный 3D-арт консольного качества
const TextureStudio = {
  createCanvas(w = 512, h = 512) {
    const canvas = document.createElement('canvas');
    canvas.width = w;
    canvas.height = h;
    return canvas;
  },

  // Выразительные аниме-глаза с многослойным градиентом, бликами и глубиной
  createAnimeEyeTexture() {
    const canvas = this.createCanvas(512, 512);
    const ctx = canvas.getContext('2d');

    // Белок глаза со скругленным затемнением по краям
    const bgGrad = ctx.createRadialGradient(256, 256, 120, 256, 256, 250);
    bgGrad.addColorStop(0, '#ffffff');
    bgGrad.addColorStop(0.85, '#f5eff8');
    bgGrad.addColorStop(1, '#dfd5e6');
    ctx.fillStyle = bgGrad;
    ctx.beginPath();
    ctx.arc(256, 256, 240, 0, Math.PI * 2);
    ctx.fill();

    // Верхняя тень века
    const shadowGrad = ctx.createLinearGradient(0, 0, 0, 220);
    shadowGrad.addColorStop(0, 'rgba(60, 40, 80, 0.35)');
    shadowGrad.addColorStop(1, 'rgba(60, 40, 80, 0)');
    ctx.fillStyle = shadowGrad;
    ctx.fillRect(0, 0, 512, 220);

    // Радужка (Anime Iris) - насыщенный фиолетово-малиновый градиент
    const irisGrad = ctx.createLinearGradient(0, 100, 0, 420);
    irisGrad.addColorStop(0, '#2d1448'); // глубокий темный верх
    irisGrad.addColorStop(0.4, '#7b2cbf');
    irisGrad.addColorStop(0.7, '#c77dff');
    irisGrad.addColorStop(1, '#ff99c8'); // светлый нижний ободок
    ctx.fillStyle = irisGrad;
    ctx.beginPath();
    ctx.ellipse(256, 265, 160, 190, 0, 0, Math.PI * 2);
    ctx.fill();

    // Контур радужки
    ctx.lineWidth = 10;
    ctx.strokeStyle = '#1e0836';
    ctx.stroke();

    // Зрачок
    ctx.fillStyle = '#120524';
    ctx.beginPath();
    ctx.ellipse(256, 250, 75, 95, 0, 0, Math.PI * 2);
    ctx.fill();

    // Нижняя световая дуга (Anime light crescent)
    ctx.strokeStyle = 'rgba(255, 230, 250, 0.65)';
    ctx.lineWidth = 14;
    ctx.beginPath();
    ctx.arc(256, 275, 125, 0.25 * Math.PI, 0.75 * Math.PI);
    ctx.stroke();

    // Главный большой блик (Specular highlight)
    ctx.fillStyle = '#ffffff';
    ctx.beginPath();
    ctx.ellipse(205, 185, 45, 55, -0.2, 0, Math.PI * 2);
    ctx.fill();

    // Второстепенный блик
    ctx.beginPath();
    ctx.arc(315, 320, 22, 0, Math.PI * 2);
    ctx.fill();

    // Звездная искра
    ctx.beginPath();
    ctx.arc(220, 310, 12, 0, Math.PI * 2);
    ctx.fill();

    return new THREE.CanvasTexture(canvas);
  },

  // Лицо: нежный румянец, тени и тончайшие реснички
  createFaceTexture() {
    const canvas = this.createCanvas(512, 512);
    const ctx = canvas.getContext('2d');

    // Базовый цвет кожи
    ctx.fillStyle = '#ffede4';
    ctx.fillRect(0, 0, 512, 512);

    // Румянец на щечках (Мягкие градиентные пятна)
    const drawBlush = (x, y) => {
      const g = ctx.createRadialGradient(x, y, 10, x, y, 90);
      g.addColorStop(0, 'rgba(255, 90, 130, 0.65)');
      g.addColorStop(0.5, 'rgba(255, 120, 150, 0.35)');
      g.addColorStop(1, 'rgba(255, 120, 150, 0)');
      ctx.fillStyle = g;
      ctx.beginPath();
      ctx.arc(x, y, 90, 0, Math.PI * 2);
      ctx.fill();

      // Белые милые полоски смущения
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.75)';
      ctx.lineWidth = 4;
      ctx.lineCap = 'round';
      [-22, 0, 22].forEach(offset => {
        ctx.beginPath();
        ctx.moveTo(x + offset - 8, y + 10);
        ctx.lineTo(x + offset + 8, y - 10);
        ctx.stroke();
      });
    };
    drawBlush(120, 310);
    drawBlush(392, 310);

    // Носик (маленькая аккуратная тень)
    ctx.fillStyle = 'rgba(235, 140, 130, 0.7)';
    ctx.beginPath();
    ctx.arc(256, 290, 4, 0, Math.PI * 2);
    ctx.fill();

    return new THREE.CanvasTexture(canvas);
  },

  // Текстура свитера с трикотажной вязкой и вышивкой сердечка
  createSweaterTexture(color = '#ff6584') {
    const canvas = this.createCanvas(512, 512);
    const ctx = canvas.getContext('2d');

    ctx.fillStyle = color;
    ctx.fillRect(0, 0, 512, 512);

    // Вязаный узор (вертикальные ребра)
    ctx.fillStyle = 'rgba(0, 0, 0, 0.04)';
    for (let x = 0; x < 512; x += 12) {
      ctx.fillRect(x, 0, 5, 512);
    }
    ctx.fillStyle = 'rgba(255, 255, 255, 0.06)';
    for (let x = 6; x < 512; x += 12) {
      ctx.fillRect(x, 0, 5, 512);
    }

    // Вышитое золотое сердечко по центру
    ctx.fillStyle = '#ffd54f';
    ctx.shadowColor = 'rgba(0, 0, 0, 0.15)';
    ctx.shadowBlur = 6;
    ctx.beginPath();
    ctx.moveTo(256, 240);
    ctx.bezierCurveTo(256, 220, 220, 200, 220, 235);
    ctx.bezierCurveTo(220, 270, 256, 295, 256, 310);
    ctx.bezierCurveTo(256, 295, 292, 270, 292, 235);
    ctx.bezierCurveTo(292, 200, 256, 220, 256, 240);
    ctx.fill();

    const tex = new THREE.CanvasTexture(canvas);
    tex.wrapS = THREE.RepeatWrapping;
    tex.wrapT = THREE.RepeatWrapping;
    return tex;
  },

  // Текстура деревянного паркета
  createParquetTexture() {
    const canvas = this.createCanvas(512, 512);
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#d7a15c';
    ctx.fillRect(0, 0, 512, 512);

    // Доски
    ctx.strokeStyle = '#b88240';
    ctx.lineWidth = 3;
    for (let y = 0; y < 512; y += 64) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(512, y);
      ctx.stroke();

      // Стыки досок вразбежку
      const offset = (y / 64) % 2 === 0 ? 0 : 64;
      for (let x = offset; x < 512; x += 128) {
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x, y + 64);
        ctx.stroke();
      }
    }

    const tex = new THREE.CanvasTexture(canvas);
    tex.wrapS = THREE.RepeatWrapping;
    tex.wrapT = THREE.RepeatWrapping;
    tex.repeat.set(4, 2);
    return tex;
  },

  // Обои в гостиной с деликатным кавайным паттерном (звездочки и полоски)
  createWallpaperTexture(bg = '#fff2f6', stripe = '#ffe3ec') {
    const canvas = this.createCanvas(512, 512);
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, 512, 512);

    // Нежные полосы
    ctx.fillStyle = stripe;
    for (let x = 0; x < 512; x += 48) {
      ctx.fillRect(x, 0, 24, 512);
    }

    // Звездочки
    ctx.fillStyle = 'rgba(255, 175, 195, 0.45)';
    const drawStar = (cx, cy) => {
      ctx.beginPath();
      ctx.arc(cx, cy, 6, 0, Math.PI * 2);
      ctx.fill();
    };
    for (let y = 30; y < 512; y += 64) {
      for (let x = 12; x < 512; x += 48) {
        drawStar(x, y);
      }
    }

    const tex = new THREE.CanvasTexture(canvas);
    tex.wrapS = THREE.RepeatWrapping;
    tex.wrapT = THREE.RepeatWrapping;
    tex.repeat.set(4, 2);
    return tex;
  },

  // Плитка для ванной комнаты
  createTileTexture() {
    const canvas = this.createCanvas(512, 512);
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#e0f7fa';
    ctx.fillRect(0, 0, 512, 512);

    ctx.strokeStyle = '#b2ebf2';
    ctx.lineWidth = 4;
    for (let y = 0; y < 512; y += 48) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(512, y);
      ctx.stroke();
    }
    for (let x = 0; x < 512; x += 48) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, 512);
      ctx.stroke();
    }

    const tex = new THREE.CanvasTexture(canvas);
    tex.wrapS = THREE.RepeatWrapping;
    tex.wrapT = THREE.RepeatWrapping;
    tex.repeat.set(6, 4);
    return tex;
  }
};

// --- 3. ЗВУКОВОЙ ДВИЖОК WEBAUDIO + ГОЛОСОВОЙ ПОВТОРИТЕЛЬ ---
const SoundEngine = {
  ctx: null,
  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) this.ctx = new AudioCtx();
    }
    if (this.ctx && this.ctx.state === 'suspended') this.ctx.resume();
  },
  playTone(freq, type = 'sine', duration = 0.15, gainVal = 0.1) {
    if (!gameState.soundEnabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = type;
      osc.frequency.setValueAtTime(freq, this.ctx.currentTime);
      gain.gain.setValueAtTime(gainVal, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.0001, this.ctx.currentTime + duration);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + duration);
    } catch(e) {}
  },
  purr() {
    if (!gameState.soundEnabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(160, this.ctx.currentTime);
      osc.frequency.linearRampToValueAtTime(240, this.ctx.currentTime + 0.25);
      gain.gain.setValueAtTime(0.08, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.3);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.3);
    } catch(e) {}
  },
  crunch() {
    this.init();
    [420, 340, 260].forEach((freq, idx) => {
      setTimeout(() => this.playTone(freq, 'sawtooth', 0.08, 0.08), idx * 45);
    });
  },
  pop() {
    this.playTone(650 + Math.random() * 200, 'sine', 0.05, 0.08);
  },
  waterSplash() {
    this.init();
    if (!this.ctx) return;
    try {
      const bufferSize = this.ctx.sampleRate * 0.4;
      const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) data[i] = (Math.random() * 2 - 1) * 0.12;
      const noise = this.ctx.createBufferSource();
      noise.buffer = buffer;
      const filter = this.ctx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(900, this.ctx.currentTime);
      noise.connect(filter);
      filter.connect(this.ctx.destination);
      noise.start();
    } catch(e) {}
  },
  lampSwitch() {
    this.playTone(200, 'square', 0.04, 0.09);
    setTimeout(() => this.playTone(130, 'triangle', 0.05, 0.08), 35);
  },
  coin() {
    this.playTone(987.77, 'triangle', 0.09, 0.08);
    setTimeout(() => this.playTone(1318.51, 'triangle', 0.22, 0.08), 70);
  },
  giggle() {
    [520, 680, 820, 680, 820].forEach((freq, idx) => {
      setTimeout(() => this.playTone(freq, 'sine', 0.06, 0.05), idx * 55);
    });
  }
};

const VoiceRepeater = {
  mediaRecorder: null,
  audioChunks: [],
  isRecording: false,
  analyser: null,
  animFrameId: null,

  async startListening() {
    SoundEngine.init();
    if (this.isRecording) return;
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.audioChunks = [];
      this.mediaRecorder = new MediaRecorder(stream);
      this.isRecording = true;

      const micBtn = document.getElementById('btn-mic-repeat');
      if (micBtn) micBtn.classList.add('recording');
      showDialogue('Слушаю тебя! Говори что-нибудь в микрофон... 🎤');

      this.mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) this.audioChunks.push(e.data);
      };

      this.mediaRecorder.onstop = async () => {
        this.isRecording = false;
        if (micBtn) micBtn.classList.remove('recording');
        stream.getTracks().forEach(track => track.stop());
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/ogg; codecs=opus' });
        await this.playCuteVoiceWithLipSync(audioBlob);
      };

      this.mediaRecorder.start();
      setTimeout(() => {
        if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
          this.mediaRecorder.stop();
        }
      }, 3500);

    } catch (err) {
      showDialogue('Разреши микрофон в браузере, чтобы я повторила твои слова! 💕');
    }
  },

  async playCuteVoiceWithLipSync(blob) {
    if (!SoundEngine.ctx) return;
    try {
      const arrayBuffer = await blob.arrayBuffer();
      const audioBuffer = await SoundEngine.ctx.decodeAudioData(arrayBuffer);

      const source = SoundEngine.ctx.createBufferSource();
      source.buffer = audioBuffer;
      source.playbackRate.value = 1.38;

      this.analyser = SoundEngine.ctx.createAnalyser();
      this.analyser.fftSize = 64;
      source.connect(this.analyser);
      this.analyser.connect(SoundEngine.ctx.destination);

      source.start(0);
      showDialogue('Хи-хи, слушай! ✨');

      const dataArray = new Uint8Array(this.analyser.frequencyBinCount);
      const checkLipSync = () => {
        if (!this.analyser) return;
        this.analyser.getByteFrequencyData(dataArray);
        let sum = 0;
        for (let i = 0; i < dataArray.length; i++) sum += dataArray[i];
        const avg = sum / dataArray.length;
        const mouthOpenRatio = Math.min(1.0, avg / 60);

        if (window.yuki3D) {
          window.yuki3D.setMouthOpen(mouthOpenRatio);
          window.yuki3D.head.rotation.y = Math.sin(Date.now() * 0.01) * 0.12;
        }
        this.animFrameId = requestAnimationFrame(checkLipSync);
      };
      checkLipSync();

      source.onended = () => {
        cancelAnimationFrame(this.animFrameId);
        if (window.yuki3D) {
          window.yuki3D.setMouthOpen(0);
          window.yuki3D.head.rotation.y = 0;
        }
        showDialogue('Круто получилось, правда? 💖');
      };
    } catch(e) {}
  }
};

// --- 4. АРХИТЕКТУРА 3D-ПЕРСОНАЖА (YUKI ANIME CHIBI RIG V2) ---
const ROOM_WIDTH = 18;
let scene, camera, renderer;
let targetCameraX = 0;
let raycaster, mouse;
let worldLights = {};

class YukiChibiRigV2 {
  constructor(scene) {
    this.group = new THREE.Group();
    this.scene = scene;
    this.mouthOpenAmount = 0;
    this.chewingTimer = 0;
    this.blinkTimer = 0;
    this.isBlinking = false;
    this.happySquint = false;
    this.lookTarget = new THREE.Vector3(0, 1.8, 10);

    this.buildCharacter();
    scene.add(this.group);
  }

  buildCharacter() {
    // 1. Создаем материалы с текстурами
    this.eyeTexture = TextureStudio.createAnimeEyeTexture();
    this.faceTexture = TextureStudio.createFaceTexture();
    this.sweatTexture = TextureStudio.createSweaterTexture('#ff6384');

    // Материал кожи лица с мягким шейдингом
    this.skinMat = new THREE.MeshStandardMaterial({
      map: this.faceTexture,
      roughness: 0.65,
      metalness: 0.05
    });

    this.skinBodyMat = new THREE.MeshStandardMaterial({
      color: 0xffede4,
      roughness: 0.65,
      metalness: 0.05
    });

    // Материал свитера/худи
    this.sweaterMat = new THREE.MeshStandardMaterial({
      map: this.sweatTexture,
      roughness: 0.8,
      metalness: 0.1
    });

    // Волосы: мягкий пастельно-клубничный блонд со стилизованным бликом
    this.hairMat = new THREE.MeshStandardMaterial({
      color: 0xff9ebb,
      roughness: 0.45,
      metalness: 0.15
    });

    this.darkMat = new THREE.MeshStandardMaterial({
      color: 0x241d28,
      roughness: 0.5
    });

    this.whiteMat = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      roughness: 0.4
    });

    // --- ТЕЛО (ОДЕЖДА И НОЖКИ) ---
    // Уютный оверсайз свитер
    this.torso = new THREE.Mesh(
      new THREE.CylinderGeometry(0.55, 0.85, 1.35, 24),
      this.sweaterMat
    );
    this.torso.position.y = 1.05;
    this.torso.castShadow = true;
    this.torso.receiveShadow = true;
    this.torso.userData = { part: 'belly' };
    this.group.add(this.torso);

    // Воротничок свитера
    const collar = new THREE.Mesh(new THREE.TorusGeometry(0.52, 0.1, 12, 24), this.whiteMat);
    collar.position.y = 1.7;
    collar.rotation.x = Math.PI / 2;
    this.group.add(collar);

    // Ножки в чулочках и ботиночках
    [-0.32, 0.32].forEach(x => {
      // Ножка
      const leg = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.18, 0.65, 16), this.skinBodyMat);
      leg.position.set(x, 0.4, 0);
      leg.castShadow = true;
      this.group.add(leg);

      // Милый сапожок с подошвой
      const boot = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.26, 0.48), this.darkMat);
      boot.position.set(x, 0.13, 0.08);
      boot.castShadow = true;
      this.group.add(boot);

      const bootSole = new THREE.Mesh(new THREE.BoxGeometry(0.34, 0.06, 0.5), this.whiteMat);
      bootSole.position.set(x, 0.03, 0.08);
      this.group.add(bootSole);
    });

    // Ручки в рукавах свитера
    this.armL = new THREE.Mesh(new THREE.CylinderGeometry(0.16, 0.2, 0.75, 16), this.sweaterMat);
    this.armL.position.set(-0.78, 1.25, 0.05);
    this.armL.rotation.z = 0.45;
    this.armL.castShadow = true;
    this.group.add(this.armL);

    this.armR = new THREE.Mesh(new THREE.CylinderGeometry(0.16, 0.2, 0.75, 16), this.sweaterMat);
    this.armR.position.set(0.78, 1.25, 0.05);
    this.armR.rotation.z = -0.45;
    this.armR.castShadow = true;
    this.group.add(this.armR);

    // Ладошки
    const handL = new THREE.Mesh(new THREE.SphereGeometry(0.12, 12, 12), this.skinBodyMat);
    handL.position.set(-1.02, 0.95, 0.1);
    this.group.add(handL);

    const handR = new THREE.Mesh(new THREE.SphereGeometry(0.12, 12, 12), this.skinBodyMat);
    handR.position.set(1.02, 0.95, 0.1);
    this.group.add(handR);

    // --- ГОЛОВА И ВЫРАЗИТЕЛЬНОЕ ЛИЦО ---
    this.head = new THREE.Group();
    this.head.position.y = 2.15;

    // Сфера головы с деликатным овалом и текстурой кожи
    const headMesh = new THREE.Mesh(new THREE.SphereGeometry(0.9, 32, 28), this.skinMat);
    headMesh.scale.set(1.05, 0.96, 0.98);
    headMesh.castShadow = true;
    headMesh.userData = { part: 'head' };
    this.head.add(headMesh);

    // Большие выразительные 3D аниме-глаза с текстурой
    const eyeMat = new THREE.MeshBasicMaterial({ map: this.eyeTexture, transparent: true });

    this.eyeL = new THREE.Mesh(new THREE.CircleGeometry(0.24, 28), eyeMat);
    this.eyeL.position.set(-0.35, 0.02, 0.86);
    this.eyeL.rotation.y = -0.15;
    this.head.add(this.eyeL);

    this.eyeR = new THREE.Mesh(new THREE.CircleGeometry(0.24, 28), eyeMat);
    this.eyeR.position.set(0.35, 0.02, 0.86);
    this.eyeR.rotation.y = 0.15;
    this.head.add(this.eyeR);

    // Верхние веки (для моргания и жмурок)
    this.eyelids = new THREE.Group();
    [-0.35, 0.35].forEach((x, i) => {
      const lid = new THREE.Mesh(
        new THREE.SphereGeometry(0.26, 20, 12, 0, Math.PI * 2, 0, Math.PI / 2),
        this.skinBodyMat
      );
      lid.position.set(x, 0.05, 0.78);
      lid.scale.set(1.0, 1.15, 0.6);
      lid.rotation.x = Math.PI; // Скрыто вверху
      lid.rotation.y = i === 0 ? -0.15 : 0.15;
      this.eyelids.add(lid);
    });
    this.head.add(this.eyelids);

    // Аниме-ротик (открывается при приближении еды и речи)
    const mouthGeom = new THREE.CylinderGeometry(0.12, 0.04, 0.08, 16);
    this.mouth = new THREE.Mesh(mouthGeom, new THREE.MeshBasicMaterial({ color: 0x991b3e }));
    this.mouth.position.set(0, -0.32, 0.88);
    this.mouth.rotation.x = Math.PI / 2;
    this.mouth.scale.set(0.7, 0.2, 0.5);
    this.head.add(this.mouth);

    // --- ПЫШНЫЕ АНИМЕ-ВОЛОСЫ И КОШАЧЬИ УШКИ ---
    // Основная шапка волос
    const hairBase = new THREE.Mesh(new THREE.SphereGeometry(0.96, 28, 20), this.hairMat);
    hairBase.position.set(0, 0.1, -0.08);
    this.head.add(hairBase);

    // Челка с прядями
    const bangs = new THREE.Mesh(new THREE.ConeGeometry(1.0, 0.6, 24), this.hairMat);
    bangs.position.set(0, 0.65, 0.68);
    bangs.rotation.x = -0.6;
    bangs.rotation.z = Math.PI;
    this.head.add(bangs);

    // Пряди по бокам лица (Side Locks)
    [-0.75, 0.75].forEach((x, idx) => {
      const lock = new THREE.Mesh(new THREE.ConeGeometry(0.22, 1.1, 16), this.hairMat);
      lock.position.set(x, -0.2, 0.4);
      lock.rotation.z = idx === 0 ? 0.2 : -0.2;
      this.head.add(lock);
    });

    // Хвостики (Twintails) с пружинной физикой
    this.twintailL = new THREE.Mesh(new THREE.ConeGeometry(0.35, 1.5, 16), this.hairMat);
    this.twintailL.position.set(-1.05, 0.15, -0.25);
    this.twintailL.rotation.z = 0.55;
    this.head.add(this.twintailL);

    this.twintailR = new THREE.Mesh(new THREE.ConeGeometry(0.35, 1.5, 16), this.hairMat);
    this.twintailR.position.set(1.05, 0.15, -0.25);
    this.twintailR.rotation.z = -0.55;
    this.head.add(this.twintailR);

    // Пушистые кошачьи ушки
    [-0.52, 0.52].forEach((x, i) => {
      const ear = new THREE.Mesh(new THREE.ConeGeometry(0.34, 0.65, 12), this.hairMat);
      ear.position.set(x, 1.05, 0.15);
      ear.rotation.z = i === 0 ? 0.35 : -0.35;
      this.head.add(ear);

      const earInner = new THREE.Mesh(new THREE.ConeGeometry(0.2, 0.45, 12), new THREE.MeshBasicMaterial({ color: 0xffccd7 }));
      earInner.position.set(x, 1.05, 0.22);
      earInner.rotation.z = i === 0 ? 0.35 : -0.35;
      this.head.add(earInner);
    });

    this.group.add(this.head);
    this.group.position.set(0, 0, 0);
  }

  setMouthOpen(ratio) {
    const clamped = Math.max(0.15, Math.min(1.5, ratio));
    this.mouth.scale.set(0.6 + clamped * 0.5, clamped * 1.3, 0.5 + clamped * 0.5);
  }

  update(delta, time) {
    // Дыхание (Idle breathing)
    const breath = Math.sin(time * 2.8) * 0.035;
    this.torso.scale.set(1 + breath * 0.3, 1 - breath * 0.2, 1 + breath * 0.3);
    this.head.position.y = 2.15 + breath * 0.4;

    // Пружинящие хвостики
    const sway = Math.sin(time * 2.5) * 0.07;
    this.twintailL.rotation.z = 0.55 + sway;
    this.twintailR.rotation.z = -0.55 + sway;

    // Плавное слежение взглядом (LookAt IK)
    this.head.rotation.y = THREE.MathUtils.lerp(this.head.rotation.y, this.lookTarget.x * 0.25, 0.08);
    this.head.rotation.x = THREE.MathUtils.lerp(this.head.rotation.x, -this.lookTarget.y * 0.18, 0.08);

    // Моргание глаз
    this.blinkTimer += delta;
    if (this.blinkTimer > 3.6) {
      this.isBlinking = true;
      if (this.blinkTimer > 3.8) {
        this.isBlinking = false;
        this.blinkTimer = 0;
      }
    }

    if (gameState.isSleeping) {
      this.eyelids.children.forEach(lid => lid.rotation.x = 0);
      this.head.rotation.x = 0.35;
      this.head.position.y = 1.8;
    } else if (this.happySquint || this.isBlinking) {
      this.eyelids.children.forEach(lid => lid.rotation.x = 0);
    } else {
      this.eyelids.children.forEach(lid => lid.rotation.x = Math.PI);
    }

    // Жевание
    if (this.chewingTimer > 0) {
      this.chewingTimer -= delta;
      const chewCycle = Math.abs(Math.sin(time * 16));
      this.setMouthOpen(chewCycle * 0.9);
      this.head.position.y = 2.15 + chewCycle * 0.06;
    }
  }
}

// --- 5. ДЕТАЛИЗИРОВАННЫЕ 3D-КОМНАТЫ С АРХИТЕКТУРОЙ И МЕБЕЛЬЮ ---
function buildStudioRooms(scene) {
  const parquetTex = TextureStudio.createParquetTexture();
  const wallpaperLivingTex = TextureStudio.createWallpaperTexture('#fff1f5', '#ffe0ea');
  const wallpaperBedTex = TextureStudio.createWallpaperTexture('#f1edfa', '#e3dcfa');
  const tileTex = TextureStudio.createTileTexture();

  const floorMatWood = new THREE.MeshStandardMaterial({ map: parquetTex, roughness: 0.6 });
  const floorMatKitchen = new THREE.MeshStandardMaterial({ map: tileTex, roughness: 0.4 });
  const floorMatBath = new THREE.MeshStandardMaterial({ map: tileTex, roughness: 0.25, metalness: 0.1 });
  const floorMatBed = new THREE.MeshStandardMaterial({ map: parquetTex, roughness: 0.6 });

  const wallMatLiving = new THREE.MeshStandardMaterial({ map: wallpaperLivingTex, roughness: 0.8 });
  const wallMatKitchen = new THREE.MeshStandardMaterial({ color: 0xfffaed, roughness: 0.7 });
  const wallMatBath = new THREE.MeshStandardMaterial({ map: tileTex, roughness: 0.3 });
  const wallMatBed = new THREE.MeshStandardMaterial({ map: wallpaperBedTex, roughness: 0.8 });

  const woodFurniture = new THREE.MeshStandardMaterial({ color: 0x8d5b4c, roughness: 0.5 });
  const whiteMat = new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.3 });
  const sofaPinkMat = new THREE.MeshStandardMaterial({ color: 0xff85a2, roughness: 0.7 });

  const rooms = [
    { id: 0, x: 0 * ROOM_WIDTH, floor: floorMatWood, wall: wallMatLiving },
    { id: 1, x: 1 * ROOM_WIDTH, floor: floorMatKitchen, wall: wallMatKitchen },
    { id: 2, x: 2 * ROOM_WIDTH, floor: floorMatBath, wall: wallMatBath },
    { id: 3, x: 3 * ROOM_WIDTH, floor: floorMatBed, wall: wallMatBed }
  ];

  rooms.forEach(r => {
    // Пол
    const floor = new THREE.Mesh(new THREE.PlaneGeometry(ROOM_WIDTH, 12), r.floor);
    floor.rotation.x = -Math.PI / 2;
    floor.position.set(r.x, 0, 0);
    floor.receiveShadow = true;
    scene.add(floor);

    // Задняя стена
    const wall = new THREE.Mesh(new THREE.PlaneGeometry(ROOM_WIDTH, 12), r.wall);
    wall.position.set(r.x, 5.5, -4.5);
    wall.receiveShadow = true;
    scene.add(wall);

    // Плинтус
    const baseboard = new THREE.Mesh(new THREE.BoxGeometry(ROOM_WIDTH, 0.35, 0.15), whiteMat);
    baseboard.position.set(r.x, 0.17, -4.4);
    scene.add(baseboard);
  });

  // --- ГОСТИНАЯ (X = 0) ---
  // Круглый пушистый коврик
  const rug = new THREE.Mesh(new THREE.CircleGeometry(2.0, 32), new THREE.MeshStandardMaterial({ color: 0xffd1dc, roughness: 0.9 }));
  rug.rotation.x = -Math.PI / 2;
  rug.position.set(0, 0.02, 0.2);
  rug.receiveShadow = true;
  scene.add(rug);

  // Уютный диван
  const sofaGroup = new THREE.Group();
  sofaGroup.position.set(-3.2, 0, -2.2);

  const sofaSeat = new THREE.Mesh(new THREE.BoxGeometry(3.2, 0.65, 1.6), sofaPinkMat);
  sofaSeat.position.y = 0.45;
  sofaSeat.castShadow = true;
  sofaGroup.add(sofaSeat);

  const sofaBack = new THREE.Mesh(new THREE.BoxGeometry(3.2, 1.1, 0.45), sofaPinkMat);
  sofaBack.position.set(0, 1.15, -0.6);
  sofaBack.castShadow = true;
  sofaGroup.add(sofaBack);

  // Подушка на диване
  const pillow = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.7, 0.25), whiteMat);
  pillow.position.set(-0.9, 0.95, -0.3);
  pillow.rotation.z = 0.2;
  sofaGroup.add(pillow);

  scene.add(sofaGroup);

  // Столик с ретро-консолью
  const tableGroup = new THREE.Group();
  tableGroup.position.set(3.2, 0, -1.8);

  const tableTop = new THREE.Mesh(new THREE.CylinderGeometry(1.0, 1.0, 0.1, 24), woodFurniture);
  tableTop.position.y = 1.0;
  tableTop.castShadow = true;
  tableGroup.add(tableTop);

  const tableLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 1.0, 12), woodFurniture);
  tableLeg.position.y = 0.5;
  tableGroup.add(tableLeg);

  // Ретро-консоль на столе
  const consoleMesh = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.25, 0.45), new THREE.MeshStandardMaterial({ color: 0xba68c8, roughness: 0.3 }));
  consoleMesh.position.set(0, 1.15, 0);
  consoleMesh.castShadow = true;
  tableGroup.add(consoleMesh);

  scene.add(tableGroup);

  // Картина на стене
  const frame = new THREE.Mesh(new THREE.BoxGeometry(1.8, 2.2, 0.08), whiteMat);
  frame.position.set(0, 5.2, -4.4);
  scene.add(frame);

  // --- КУХНЯ (X = 18) ---
  const kX = 1 * ROOM_WIDTH;

  // Обеденный столик со скатертью
  const kitchenTable = new THREE.Group();
  kitchenTable.position.set(kX + 2.5, 0, -1.4);

  const kTableTop = new THREE.Mesh(new THREE.CylinderGeometry(1.5, 1.5, 0.15, 28), whiteMat);
  kTableTop.position.y = 1.1;
  kTableTop.castShadow = true;
  kitchenTable.add(kTableTop);

  const kTableLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.18, 0.24, 1.1, 16), woodFurniture);
  kTableLeg.position.y = 0.55;
  kitchenTable.add(kTableLeg);

  // Тарелочка
  const plate = new THREE.Mesh(new THREE.CylinderGeometry(0.75, 0.6, 0.08, 24), whiteMat);
  plate.position.set(0, 1.22, 0);
  plate.castShadow = true;
  kitchenTable.add(plate);

  scene.add(kitchenTable);

  // Холодильник
  const fridge = new THREE.Mesh(new THREE.BoxGeometry(1.8, 4.2, 1.8), whiteMat);
  fridge.position.set(kX - 3.8, 2.1, -2.8);
  fridge.castShadow = true;
  scene.add(fridge);

  // --- ВАННАЯ (X = 36) ---
  const bX = 2 * ROOM_WIDTH;

  // Стильная ванна
  const tubGroup = new THREE.Group();
  tubGroup.position.set(bX, 0, -2.0);

  const tubOuter = new THREE.Mesh(new THREE.BoxGeometry(4.2, 1.4, 2.4), whiteMat);
  tubOuter.position.y = 0.7;
  tubOuter.castShadow = true;
  tubGroup.add(tubOuter);

  // Вода в ванне
  const waterPlane = new THREE.Mesh(new THREE.PlaneGeometry(3.8, 2.0), new THREE.MeshStandardMaterial({ color: 0x4dd0e1, roughness: 0.1, metalness: 0.6 }));
  waterPlane.rotation.x = -Math.PI / 2;
  waterPlane.position.y = 1.2;
  tubGroup.add(waterPlane);

  // Стойка душа
  const showerPipe = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.06, 4.5, 12), new THREE.MeshStandardMaterial({ metalness: 0.85, roughness: 0.2 }));
  showerPipe.position.set(1.8, 2.8, -1.0);
  tubGroup.add(showerPipe);

  const showerHead = new THREE.Mesh(new THREE.ConeGeometry(0.38, 0.3, 16), new THREE.MeshStandardMaterial({ metalness: 0.85, roughness: 0.2 }));
  showerHead.position.set(1.4, 4.8, -0.4);
  showerHead.rotation.x = Math.PI / 3;
  tubGroup.add(showerHead);

  scene.add(tubGroup);

  // --- СПАЛЬНЯ (X = 54) ---
  const sX = 3 * ROOM_WIDTH;

  // Кровать с подушкой и покрывалом
  const bedGroup = new THREE.Group();
  bedGroup.position.set(sX, 0, -2.2);

  const bedFrame = new THREE.Mesh(new THREE.BoxGeometry(3.6, 0.6, 4.2), woodFurniture);
  bedFrame.position.y = 0.3;
  bedFrame.castShadow = true;
  bedGroup.add(bedFrame);

  const mattress = new THREE.Mesh(new THREE.BoxGeometry(3.3, 0.5, 3.9), whiteMat);
  mattress.position.y = 0.75;
  bedGroup.add(mattress);

  const blanket = new THREE.Mesh(new THREE.BoxGeometry(3.35, 0.52, 2.7), sofaPinkMat);
  blanket.position.set(0, 0.78, 0.5);
  bedGroup.add(blanket);

  const bedPillow = new THREE.Mesh(new THREE.BoxGeometry(1.8, 0.3, 0.9), whiteMat);
  bedPillow.position.set(0, 1.1, -1.2);
  bedGroup.add(bedPillow);

  scene.add(bedGroup);

  // Тумбочка и светильник
  const nightstand = new THREE.Mesh(new THREE.BoxGeometry(1.2, 1.1, 1.2), woodFurniture);
  nightstand.position.set(sX + 2.8, 0.55, -2.8);
  nightstand.castShadow = true;
  scene.add(nightstand);

  const lampShade = new THREE.Mesh(new THREE.ConeGeometry(0.5, 0.7, 16), new THREE.MeshStandardMaterial({ color: 0xfff9c4, roughness: 0.2 }));
  lampShade.position.set(sX + 2.8, 1.7, -2.8);
  scene.add(lampShade);

  const lampLight = new THREE.PointLight(0xffeca0, 1.4, 10);
  lampLight.position.set(sX + 2.8, 1.6, -2.4);
  scene.add(lampLight);
  worldLights.bedroomLamp = lampLight;
}

// --- 6. ИНИЦИАЛИЗАЦИЯ И СТУДИЙНЫЙ СВЕТ ---
function init3DWorld() {
  const container = document.getElementById('game-viewport');
  const canvas = document.getElementById('webgl-canvas');

  // Сцена
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0xfbf0f4);

  // Идеальное кадрирование персонажа
  const aspect = container.clientWidth / container.clientHeight;
  camera = new THREE.PerspectiveCamera(40, aspect, 0.1, 100);
  camera.position.set(0, 2.15, 6.2); // Идеальный угол обзора: виден весь персонаж и уютная комната
  camera.lookAt(0, 1.5, 0);

  // Рендерер высокого качества
  renderer = new THREE.WebGLRenderer({ canvas, antialias: true, powerPreference: 'high-performance' });
  renderer.setSize(container.clientWidth, container.clientHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 1.05;

  // --- СТУДИЙНОЕ 3-ТОЧЕЧНОЕ ОСВЕЩЕНИЕ (УБИРАЕТ ПЕРЕСВЕТЫ И ДАЕТ ОБЪЕМ) ---
  // 1. Мягкий базовый эмбиент
  const ambientLight = new THREE.AmbientLight(0xffebee, 0.45);
  scene.add(ambientLight);
  worldLights.ambient = ambientLight;

  // 2. Теплый ключевой солнечный свет с мягкими тенями
  const keyLight = new THREE.DirectionalLight(0xfffdf7, 0.85);
  keyLight.position.set(4, 8, 6);
  keyLight.castShadow = true;
  keyLight.shadow.mapSize.width = 1024;
  keyLight.shadow.mapSize.height = 1024;
  keyLight.shadow.camera.near = 1;
  keyLight.shadow.camera.far = 25;
  keyLight.shadow.bias = -0.0005;
  scene.add(keyLight);

  // 3. Контурный контровой свет (Rim Light для аниме-свечения по краям)
  const rimLight = new THREE.DirectionalLight(0xffcdd2, 0.5);
  rimLight.position.set(-5, 6, -5);
  scene.add(rimLight);

  // Построение студии и персонажа
  buildStudioRooms(scene);
  window.yuki3D = new YukiChibiRigV2(scene);

  raycaster = new THREE.Raycaster();
  mouse = new THREE.Vector2();

  window.addEventListener('resize', onWindowResize);

  let clock = new THREE.Clock();
  function animate() {
    requestAnimationFrame(animate);
    const delta = clock.getDelta();
    const time = clock.getElapsedTime();

    // Плавное следование камеры за комнатой
    camera.position.x = THREE.MathUtils.lerp(camera.position.x, targetCameraX, 0.08);

    // Персонаж перемещается в текущую комнату
    window.yuki3D.group.position.x = THREE.MathUtils.lerp(
      window.yuki3D.group.position.x,
      targetCameraX,
      0.1
    );

    window.yuki3D.update(delta, time);
    renderer.render(scene, camera);
  }
  animate();

  setupTouchControls(container);
}

function onWindowResize() {
  const container = document.getElementById('game-viewport');
  if (!container || !renderer || !camera) return;
  camera.aspect = container.clientWidth / container.clientHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(container.clientWidth, container.clientHeight);
}

// --- 7. ТАКТИЛЬНОЕ УПРАВЛЕНИЕ И СВАЙПЫ ---
function setupTouchControls(container) {
  let touchStartX = 0;
  let touchStartY = 0;
  let isHeadpatting = false;

  function handlePointerDown(e) {
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    touchStartX = clientX;
    touchStartY = clientY;

    const rect = container.getBoundingClientRect();
    mouse.x = ((clientX - rect.left) / container.clientWidth) * 2 - 1;
    mouse.y = -((clientY - rect.top) / container.clientHeight) * 2 + 1;

    // Обновляем точку взгляда
    window.yuki3D.lookTarget.set(mouse.x * 2, mouse.y * 2, 8);

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(window.yuki3D.group.children, true);

    if (intersects.length > 0) {
      let hitPart = null;
      intersects.forEach(hit => {
        if (hit.object.userData && hit.object.userData.part) hitPart = hit.object.userData.part;
      });

      if (hitPart === 'head') {
        isHeadpatting = true;
        triggerHeadpat();
      } else if (hitPart === 'belly') {
        triggerTickle();
      }
    }
  }

  function handlePointerMove(e) {
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;

    const rect = container.getBoundingClientRect();
    const nx = ((clientX - rect.left) / container.clientWidth) * 2 - 1;
    const ny = -((clientY - rect.top) / container.clientHeight) * 2 + 1;
    if (window.yuki3D) {
      window.yuki3D.lookTarget.set(nx * 2.5, ny * 2.5, 8);
    }

    if (isHeadpatting) {
      SoundEngine.purr();
      window.yuki3D.happySquint = true;
    }
  }

  function handlePointerUp(e) {
    if (isHeadpatting) {
      isHeadpatting = false;
      window.yuki3D.happySquint = false;
      return;
    }

    const clientX = e.changedTouches ? e.changedTouches[0].clientX : e.clientX;
    const deltaX = clientX - touchStartX;

    // Свайп между комнатами
    if (Math.abs(deltaX) > 55) {
      if (deltaX < 0 && gameState.currentRoom < 3) {
        switchRoom(gameState.currentRoom + 1);
      } else if (deltaX > 0 && gameState.currentRoom > 0) {
        switchRoom(gameState.currentRoom - 1);
      }
    }
  }

  container.addEventListener('mousedown', handlePointerDown);
  window.addEventListener('mousemove', handlePointerMove);
  window.addEventListener('mouseup', handlePointerUp);

  container.addEventListener('touchstart', handlePointerDown, { passive: true });
  window.addEventListener('touchmove', handlePointerMove, { passive: true });
  window.addEventListener('touchend', handlePointerUp, { passive: true });
}

function triggerHeadpat() {
  SoundEngine.purr();
  window.yuki3D.happySquint = true;
  gameState.mood = Math.min(100, gameState.mood + 6);
  updateStatsHUD();
  showDialogue('Мур-р... Ты так нежно меня гладишь! ✨');
  setTimeout(() => {
    window.yuki3D.happySquint = false;
  }, 1200);
}

function triggerTickle() {
  SoundEngine.giggle();
  showDialogue('Ой, хи-хи-хи! Щекотно же! 🌸');
  window.yuki3D.head.rotation.z = 0.18;
  setTimeout(() => window.yuki3D.head.rotation.z = -0.18, 120);
  setTimeout(() => window.yuki3D.head.rotation.z = 0, 240);
}

function switchRoom(roomIndex) {
  gameState.currentRoom = roomIndex;
  targetCameraX = roomIndex * ROOM_WIDTH;

  document.querySelectorAll('.dock-tab').forEach((tab, idx) => {
    tab.classList.toggle('active', idx === roomIndex);
  });

  document.getElementById('living-controls').classList.toggle('hidden', roomIndex !== 0);
  document.getElementById('kitchen-tray').classList.toggle('hidden', roomIndex !== 1);
  document.getElementById('bathroom-controls').classList.toggle('hidden', roomIndex !== 2);
  document.getElementById('bedroom-controls').classList.toggle('hidden', roomIndex !== 3);

  const roomNames = ['Гостиная', 'Кухня', 'Ванная', 'Спальня'];
  showDialogue(`Локация: ${roomNames[roomIndex]}! ✨`);
}

// --- 8. ИНТЕРАКТИВНЫЕ ДЕЙСТВИЯ (ЕДА, ВАННА, СОН) ---
function setupRoomActions() {
  // Кормление
  const foodItems = document.querySelectorAll('.food-item-drag');
  foodItems.forEach(item => {
    item.addEventListener('pointerdown', () => {
      const foodName = item.getAttribute('data-name');
      const hungerGain = parseInt(item.getAttribute('data-gain'));

      window.yuki3D.setMouthOpen(1.2);
      showDialogue(`М-м-м, угостишь меня ${foodName}? 🍙`);

      function onPointerUp() {
        window.removeEventListener('pointerup', onPointerUp);
        SoundEngine.crunch();
        window.yuki3D.chewingTimer = 1.6;
        gameState.hunger = Math.min(100, gameState.hunger + hungerGain);
        gameState.gold += 5;
        updateStatsHUD();
        showDialogue(`Очень вкусно! Спасибо большое! (+${hungerGain}% сытости) 💖`);
      }
      window.addEventListener('pointerup', onPointerUp);
    });
  });

  // Ванная
  const btnSponge = document.getElementById('btn-tool-sponge');
  const btnShower = document.getElementById('btn-tool-shower');
  const hintText = document.getElementById('bath-hint-text');

  btnSponge.onclick = () => {
    btnSponge.classList.toggle('active');
    if (btnSponge.classList.contains('active')) {
      hintText.textContent = 'Погладь Юки, чтобы покрыть её мыльными пузырями! 🧼';
      showDialogue('Ой, сколько нежной пены! 🫧');
      SoundEngine.pop();
    }
  };

  btnShower.onclick = () => {
    SoundEngine.waterSplash();
    gameState.hygiene = 100;
    updateStatsHUD();
    btnSponge.classList.remove('active');
    hintText.textContent = 'Юки сияет чистотой и свежестью! ✨';
    showDialogue('Ах, как тепло и приятно! Спасибо за заботу! 🚿');
  };

  // Спальня
  const btnSleep = document.getElementById('btn-toggle-sleep');
  const sleepIcon = document.getElementById('sleep-btn-icon');
  const sleepLabel = document.getElementById('sleep-btn-label');

  btnSleep.onclick = () => {
    SoundEngine.lampSwitch();
    gameState.isSleeping = !gameState.isSleeping;

    if (gameState.isSleeping) {
      if (worldLights.bedroomLamp) worldLights.bedroomLamp.intensity = 0.15;
      if (worldLights.ambient) worldLights.ambient.color.setHex(0x1a162b);
      sleepIcon.textContent = '☀️';
      sleepLabel.textContent = 'Включить свет и разбудить';
      showDialogue('Сладких и волшебных снов... Zzz... 🌙');
    } else {
      if (worldLights.bedroomLamp) worldLights.bedroomLamp.intensity = 1.4;
      if (worldLights.ambient) worldLights.ambient.color.setHex(0xffebee);
      sleepIcon.textContent = '💡';
      sleepLabel.textContent = 'Погасить свет и уложить спать';
      gameState.energy = 100;
      updateStatsHUD();
      showDialogue('Доброе утро! Я выспалась и полна сил! ☀️');
    }
  };

  // Микрофон
  document.getElementById('btn-mic-repeat').onclick = () => VoiceRepeater.startListening();

  // Док
  document.querySelectorAll('.dock-tab').forEach(tab => {
    tab.onclick = () => switchRoom(parseInt(tab.getAttribute('data-room')));
  });

  // Звук
  document.getElementById('btn-toggle-sound').onclick = (e) => {
    gameState.soundEnabled = !gameState.soundEnabled;
    e.target.textContent = gameState.soundEnabled ? '🔊' : '🔇';
  };
}

let dialogueTimer = null;
function showDialogue(text) {
  const bubble = document.getElementById('dialogue-bubble');
  const textEl = document.getElementById('dialogue-text');
  if (!bubble || !textEl) return;

  textEl.textContent = text;
  bubble.classList.remove('hidden');

  clearTimeout(dialogueTimer);
  dialogueTimer = setTimeout(() => {
    bubble.classList.add('hidden');
  }, 4000);
}

function updateStatsHUD() {
  document.getElementById('num-hunger').textContent = `${Math.round(gameState.hunger)}%`;
  document.getElementById('fill-hunger').style.width = `${gameState.hunger}%`;

  document.getElementById('num-hygiene').textContent = `${Math.round(gameState.hygiene)}%`;
  document.getElementById('fill-hygiene').style.width = `${gameState.hygiene}%`;

  document.getElementById('num-energy').textContent = `${Math.round(gameState.energy)}%`;
  document.getElementById('fill-energy').style.width = `${gameState.energy}%`;

  document.getElementById('num-mood').textContent = `${Math.round(gameState.mood)}%`;
  document.getElementById('fill-mood').style.width = `${gameState.mood}%`;

  document.getElementById('gold-counter').textContent = gameState.gold;
  document.getElementById('crystal-counter').textContent = gameState.crystals;
}

// Аркада и гардероб
function initArcadeAndWardrobe() {
  const modalArcade = document.getElementById('modal-arcade');
  const modalWardrobe = document.getElementById('modal-wardrobe');

  document.getElementById('btn-open-arcade').onclick = () => modalArcade.classList.remove('hidden');
  document.getElementById('btn-open-wardrobe').onclick = () => modalWardrobe.classList.remove('hidden');

  document.querySelectorAll('.btn-close-modal').forEach(b => {
    b.onclick = () => {
      document.getElementById(b.getAttribute('data-modal')).classList.add('hidden');
    };
  });

  // Гардероб с обновлением текстуры свитера
  document.querySelectorAll('.wardrobe-card').forEach(card => {
    card.onclick = () => {
      document.querySelectorAll('.wardrobe-card').forEach(c => c.classList.remove('active'));
      card.classList.add('active');
      const outfit = card.getAttribute('data-outfit');
      let color = '#ff6384';
      if (outfit === 'sailor') color = '#1976d2';
      else if (outfit === 'maid') color = '#212121';
      else if (outfit === 'pajamas') color = '#ba68c8';

      window.yuki3D.sweatTexture = TextureStudio.createSweaterTexture(color);
      window.yuki3D.sweaterMat.map = window.yuki3D.sweatTexture;
      window.yuki3D.sweaterMat.needsUpdate = true;
      showDialogue('Вау! Мне безумно идет этот новый цвет! ✨');
    };
  });

  // Мини-игра на Canvas
  const canvas = document.getElementById('arcade-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  let basketX = 180;
  let items = [];
  let score = 0;
  let timer = 25;
  let loopActive = false;

  canvas.addEventListener('pointermove', (e) => {
    const rect = canvas.getBoundingClientRect();
    basketX = Math.max(30, Math.min(330, (e.clientX - rect.left) * (360 / rect.width)));
  });

  document.getElementById('btn-start-arcade').onclick = () => {
    loopActive = true;
    score = 0;
    timer = 25;
    items = [];
    document.getElementById('arcade-score').textContent = '0';

    const tInterval = setInterval(() => {
      if (!loopActive) { clearInterval(tInterval); return; }
      timer--;
      document.getElementById('arcade-timer').textContent = timer;
      if (timer <= 0) {
        clearInterval(tInterval);
        loopActive = false;
        const reward = score * 5;
        gameState.gold += reward;
        updateStatsHUD();
        SoundEngine.coin();
        alert(`Отличная игра! Набрано ${score} очков (+${reward} 🪙 золота)!`);
      }
    }, 1000);

    let lastSpawn = 0;
    function loop(now) {
      if (!loopActive) return;
      ctx.clearRect(0, 0, 360, 420);

      if (now - lastSpawn > 500) {
        items.push({
          x: Math.random() * 300 + 30,
          y: -20,
          emoji: ['🍓', '🍙', '🍰', '🍎', '⭐'][Math.floor(Math.random() * 5)],
          speed: 4 + Math.random() * 2
        });
        lastSpawn = now;
      }

      ctx.font = '36px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('🧺', basketX, 395);

      for (let i = items.length - 1; i >= 0; i--) {
        const item = items[i];
        item.y += item.speed;
        ctx.fillText(item.emoji, item.x, item.y);

        if (item.y > 360 && item.y < 400 && Math.abs(item.x - basketX) < 35) {
          score++;
          document.getElementById('arcade-score').textContent = score;
          SoundEngine.coin();
          items.splice(i, 1);
        } else if (item.y > 430) {
          items.splice(i, 1);
        }
      }
      requestAnimationFrame(loop);
    }
    requestAnimationFrame(loop);
  };
}

document.addEventListener('DOMContentLoaded', () => {
  init3DWorld();
  setupRoomActions();
  initArcadeAndWardrobe();
  updateStatsHUD();
  showDialogue('Привет, хозяин! Я твоя 3D-спутница Юки! Погладь меня! 🌸');
});
