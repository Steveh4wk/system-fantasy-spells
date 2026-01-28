// ============================================
// RUNA SYSTEM SCRIPT - SOLO CRAFTING
// ============================================

let timerInterval;
let timerSeconds = 0;
let isTimerRunning = false;

// Timer elements
const timerElement = document.getElementById('timer');
const participantsCounter = document.getElementById('participants-counter');
const playersSection = document.querySelector('#players-section');

// Crafting elements
const craftingMenu = document.getElementById('crafting-menu');
const selectedRuneDiv = document.getElementById('selected-rune');
const selectedName = document.getElementById('selected-name');
const confirmButton = document.getElementById('confirm-button');
const closebutton = document.getElementById('close-button');
let runeSquares = document.querySelectorAll('.rune-square');
const upgradeResultMessage = document.getElementById('upgrade-result');
const upgradeBanner = document.getElementById('upgrade-banner');

// Variables
let selectedRune = null;
let runes = [];

// Audio elements
const musicPlayer1 = new Audio();
musicPlayer1.volume = 0.3;
const tickTockAudio = new Audio('./ticktock.mp3');
tickTockAudio.volume = 0.5;
tickTockAudio.loop = true;

// Timer functions
function startFunc(m, s) {
  if (isTimerRunning) return;
  
  isTimerRunning = true;
  timerSeconds = m * 60 + s;
  
  clearInterval(timerInterval);
  timerInterval = setInterval(() => {
    if (timerSeconds <= 0) {
      stopFunc();
      return;
    }
    
    timerSeconds--;
    const minutes = Math.floor(timerSeconds / 60);
    const seconds = timerSeconds % 60;
    timerElement.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    
    // Play tick tock sound in last 10 seconds
    if (timerSeconds <= 10 && timerSeconds > 0) {
      playTickTockSound();
    }
  }, 1000);
}

function stopFunc() {
  clearInterval(timerInterval);
  isTimerRunning = false;
  stopTickTockSound();
  timerElement.textContent = '00:00';
}

function resetFunc() {
  stopFunc();
  timerSeconds = 0;
}

// Audio functions
function playTickTockSound() {
  if (tickTockAudio.paused) {
    tickTockAudio.play().catch(e => console.log('Tick tock audio failed:', e));
  }
}

function stopTickTockSound() {
  tickTockAudio.pause();
  tickTockAudio.currentTime = 0;
}

function playSong(songName) {
  musicPlayer1.pause();
  musicPlayer1.currentTime = 0;
  musicPlayer1.src = songName;
  musicPlayer1.load();
  musicPlayer1.play();
}

function stopSong() {
  musicPlayer1.pause();
  musicPlayer1.currentTime = 0;
}

function show() {
  document.querySelector("body").style = "display: flex";
}

function setParticipantsCounter(val) {
  playersSection.style = 'display: block';
  participantsCounter.textContent = val.toString();
}

// Crafting functions
function showCraftingMenu() {
  craftingMenu.style.display = 'block';
}

function hideCraftingMenu() {
  craftingMenu.style.display = 'none';
}

function showUpgradePhase2(selectedRune) {
  const phase2Div = document.getElementById('upgrade-phase2');
  const stoneImage = document.getElementById('stone-image');
  const stoneName = document.getElementById('stone-name');
  const stoneLevel = document.getElementById('stone-level');
  const nextLevelInfo = document.getElementById('next-level-info');
  const successChance = document.getElementById('success-chance');
  
  phase2Div.style.display = 'block';
  
  const runeConfig = {
    'runa_hp': { name: 'Vita', color: '#ff6b6b', image: 'nui://ox_inventory/web/images/runa_hp.png' },
    'runa_danno': { name: 'Danno', color: '#ffa500', image: 'nui://ox_inventory/web/images/runa_danno.png' },
    'runa_mp': { name: 'Mana', color: '#0066ff', image: 'nui://ox_inventory/web/images/runa_mp.png' },
    'runa_cdr': { name: 'Cooldown', color: '#00ff66', image: 'nui://ox_inventory/web/images/runa_cdr.png' },
    'runa_speed': { name: 'Velocità', color: '#ffff00', image: 'nui://ox_inventory/web/images/runa_speed.png' }
  };
  
  const baseType = selectedRune.key.replace(/_divina$/, '').replace(/_(\d+)$/, '');
  const runeInfo = runeConfig[baseType];
  const currentLevel = parseInt(selectedRune.key.match(/_(\d+)$/)?.[1] || '0');
  const levelText = currentLevel === 5 ? ' (Divina)' : currentLevel === 0 ? '' : ' (+' + currentLevel + ')';
  
  stoneImage.innerHTML = `<img src="${runeInfo.image}" style="width: 60px; height: 60px; border-radius: 50%; box-shadow: 0 0 10px ${runeInfo.color};">`;
  stoneName.textContent = runeInfo.name + levelText;
  stoneLevel.textContent = 'Livello Attuale: ' + (currentLevel === 5 ? 'Divina' : currentLevel);
  
  const nextLevel = currentLevel + 1;
  const nextLevelText = nextLevel === 5 ? 'Divina' : '+' + nextLevel;
  nextLevelInfo.textContent = 'Prossimo Livello: ' + nextLevelText;
  
  const chances = { 0: 100, 1: 80, 2: 60, 3: 40, 4: 20 };
  const chance = chances[currentLevel] || 0;
  successChance.textContent = 'Probabilità di Successo: ' + chance + '%';
}

function hideUpgradePhase2() {
  document.getElementById('upgrade-phase2').style.display = 'none';
}

function hideUpgradeNotification() {
  document.getElementById('upgrade-notification').style.display = 'none';
}

function closeUpgradeProgress() {
  hideUpgradePhase2();
}

// Event listeners
closebutton.addEventListener('click', hideCraftingMenu);

confirmButton.addEventListener('click', () => {
  if (selectedRune) {
    // Send upgrade request to server
    fetch(`https://Runa_System/upgradeRune`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify({
        rune: selectedRune.key
      })
    });
  }
});

// Message handler
window.addEventListener('message', function(event) {
  let item = event.data;
  console.log('JavaScript: Received message:', item);

  if (item.show === true) {
    show();
  }

  if (item.show === false) {
    document.querySelector("body").style = "display: none";
  }
  
  if (item.start) {
    startFunc(item.m, item.s);
  }

  if (item.reset) {
    resetFunc();
  }

  if (item.hideTimer) {
    stopFunc();
  }

  if (item.playSong) {
    playSong(item.playSong);
  }

  if (item.stopSong) {
    stopSong();
  }

  if (item.setParticipantsCounter !== undefined) {
    setParticipantsCounter(item.setParticipantsCounter);
  }

  if (item.playTickTockSound) {
    playTickTockSound();
  }

  if (item.stopTickTockSound) {
    stopTickTockSound();
  }

  if (item.playHammerSound) {
    playTickTockSound();
  }

  if (item.hideParticipantsCounter) {
    const playersSection = document.querySelector('#players-section');
    if (playersSection) {
      playersSection.style = "display: none";
    }
  }

  if (item.showLoading) {
    console.log('JavaScript: Loading indicator request ignored');
  }

  if (item.showCrafting) {
    console.log('JavaScript: showCrafting received');
    showCraftingMenu();
  }

  if (item.showCrafting === false) {
    console.log('JavaScript: hideCrafting received');
    hideCraftingMenu();
  }

  if (item.showPhase2) {
    console.log('JavaScript: showPhase2 received with rune:', item.selectedRune);
    showUpgradePhase2(item.selectedRune);
  }

  if (item.hideNotification) {
    hideUpgradeNotification();
  }

  if (item.upgradeResult) {
    const result = item.upgradeResult;
    console.log('JavaScript: Received upgradeResult:', result);

    setTimeout(() => {
      upgradeResultMessage.style.display = 'block';
      upgradeResultMessage.textContent = result.message;
      upgradeResultMessage.style.color = result.success ? '#00ff00' : '#ff0000';
      upgradeResultMessage.style.background = result.success ? 'rgba(0, 255, 0, 0.1)' : 'rgba(255, 0, 0, 0.1)';
      upgradeResultMessage.style.border = result.success ? '2px solid #00ff00' : '2px solid #ff0000';

      if (result.noGaleoni) {
        setTimeout(() => {
          hideUpgradePhase2();
        }, 2000);
        return;
      }

      if (result.newRune) {
        const runeConfig = {
          'runa_hp': { name: 'Vita', color: '#ff6b6b', image: 'nui://ox_inventory/web/images/runa_hp.png' },
          'runa_danno': { name: 'Danno', color: '#ffa500', image: 'nui://ox_inventory/web/images/runa_danno.png' },
          'runa_mp': { name: 'Mana', color: '#0066ff', image: 'nui://ox_inventory/web/images/runa_mp.png' },
          'runa_cdr': { name: 'Cooldown', color: '#00ff66', image: 'nui://ox_inventory/web/images/runa_cdr.png' },
          'runa_speed': { name: 'Velocità', color: '#ffff00', image: 'nui://ox_inventory/web/images/runa_speed.png' }
        };

        const baseType = result.newRune.type.replace(/_divina$/, '').replace(/_(\d+)$/, '');
        const runeInfo = runeConfig[baseType];
        const currentLevel = result.newRune.level || 0;
        const levelText = currentLevel === 5 ? ' (Divina)' : currentLevel === 0 ? '' : ' (+' + currentLevel + ')';

        document.getElementById('stone-image').innerHTML = `<img src="${runeInfo.image}" style="width: 60px; height: 60px; border-radius: 50%; box-shadow: 0 0 10px ${runeInfo.color};">`;
        document.getElementById('stone-name').textContent = runeInfo.name + levelText;
        document.getElementById('stone-level').textContent = 'Livello Attuale: ' + (currentLevel === 5 ? 'Divina' : currentLevel);

        const nextLevel = currentLevel + 1;
        const nextLevelText = nextLevel === 5 ? 'Divina' : '+' + nextLevel;
        document.getElementById('next-level-info').textContent = 'Prossimo Livello: ' + nextLevelText;

        const chances = { 0: 100, 1: 80, 2: 60, 3: 40, 4: 20 };
        const chance = chances[currentLevel] || 0;
        document.getElementById('success-chance').textContent = 'Probabilità di Successo: ' + chance + '%';

        selectedRune = { key: result.newRune.type, name: result.newRune.name };
      }

      setTimeout(() => {
        upgradeResultMessage.style.display = 'none';
      }, 3000);
    }, 2000);
  }

  if (item.hideUpgradeProgress) {
    closeUpgradeProgress();
  }

  if (item.galeoniInfo) {
    const galeoniInfo = item.galeoniInfo;
    console.log('JavaScript: Galeoni info received:', galeoniInfo);
    
    const selectedRuneDiv = document.querySelector('#selected-rune');
    if (selectedRuneDiv) {
      let galeoniDisplay = selectedRuneDiv.querySelector('.galeoni-info');
      if (!galeoniDisplay) {
        galeoniDisplay = document.createElement('div');
        galeoniDisplay.className = 'galeoni-info';
        selectedRuneDiv.insertBefore(galeoniDisplay, selectedRuneDiv.firstChild);
      }
      
      const hasEnough = galeoniInfo.hasEnough;
      const galeoniCount = galeoniInfo.count;
      
      galeoniDisplay.innerHTML = `
        <p style="font-size: 18px; color: ${hasEnough ? '#ffd700' : '#ff6b6b'}; text-shadow: 2px 2px 4px #000;">
          Costo Incantesimo: 200 Galeoni
        </p>
        <p style="font-size: 14px; color: ${hasEnough ? '#f4e4bc' : '#ffaaaa'}; margin: 5px 0;">
          I tuoi Galeoni: ${galeoniCount}
        </p>
        ${!hasEnough ? '<p style="font-size: 12px; color: #ff6b6b; font-weight: bold;">⚠️ Non hai abbastanza galeoni!</p>' : ''}
      `;
      
      const confirmButton = document.querySelector('#confirm-button');
      if (confirmButton) {
        confirmButton.disabled = !hasEnough;
        confirmButton.style.opacity = hasEnough ? '1' : '0.5';
        confirmButton.style.cursor = hasEnough ? 'pointer' : 'not-allowed';
        confirmButton.style.background = hasEnough ? 
          'linear-gradient(45deg, #daa520, #ffd700)' : 
          'linear-gradient(45deg, #666666, #888888)';
      }
    }
  }

  if (item.updateRunes) {
    console.log('JavaScript: Received updateRunes message');
    console.log('JavaScript: HTML content length:', item.updateRunes.length);
    document.getElementById('rune-selection').innerHTML = item.updateRunes;
    runeSquares = document.querySelectorAll('.rune-square');
    console.log('JavaScript: Found', runeSquares.length, 'rune squares');
    
    runes = [];
    runeSquares.forEach(square => {
      const runeKey = square.getAttribute('data-rune');
      const runeName = square.querySelector('p')?.textContent?.split(' (')[0];
      const isDisabled = square.classList.contains('disabled');
      
      console.log('JavaScript: Processing rune - key:', runeKey, 'name:', runeName, 'disabled:', isDisabled);
      
      if (runeKey && runeName && !isDisabled) {
        runes.push({ name: runeName, key: runeKey });
      }
    });
    
    console.log('JavaScript: Populated runes array:', runes);
    
    runeSquares.forEach(square => {
      square.addEventListener('click', () => {
        console.log('JavaScript: Rune square clicked:', square.getAttribute('data-rune'));
        
        if (square.classList.contains('disabled')) {
          console.log('JavaScript: Rune is disabled, cannot upgrade');
          const tempMessage = document.createElement('div');
          tempMessage.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: rgba(255, 107, 107, 0.9); color: white; padding: 10px 20px; border-radius: 5px; z-index: 9999; font-size: 14px; font-weight: bold;';
          tempMessage.textContent = '⚠️ Questa runa ha già raggiunto il livello massimo!';
          document.body.appendChild(tempMessage);
          
          setTimeout(() => {
            document.body.removeChild(tempMessage);
          }, 2000);
          return;
        }
        
        const runeKey = square.getAttribute('data-rune');
        const rune = runes.find(r => r.key === runeKey);
        if (rune) {
          selectedRune = rune;
          selectedName.textContent = rune.name;
          selectedRuneDiv.style.display = 'block';
          confirmButton.style.display = 'inline-block';
          runeSquares.forEach(s => s.classList.remove('selected'));
          square.classList.add('selected');
          console.log('JavaScript: Selected rune:', rune);
        } else {
          console.log('JavaScript: Rune not found in array for key:', runeKey);
        }
      });
    });
  }
});

console.log('Runa System Crafting UI loaded');
