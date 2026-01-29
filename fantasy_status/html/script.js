const sound = document.getElementById('starSound');

// State management
let currentCreature = null; // 'vampire', 'lycan', 'human'
let statusData = {
    health: 100,
    armor: 0,
    hunger: 100,
    thirst: 100,
    stress: 0,
    creaturePower: 0
};

function playSound() {
    sound.pause();
    sound.currentTime = 0;
    sound.volume = 0.5;
    sound.muted = false;

    const playPromise = sound.play();
    if (playPromise !== undefined) {
        playPromise.catch(() => {
            console.log('Audio blocked, retrying...');
            setTimeout(() => {
                sound.play();
            }, 100);
        });
    }
}

function stopSound() {
    sound.pause();
    sound.currentTime = 0;
}

// Update status bar
function updateStatusBar(id, value, max = 100) {
    const fill = document.getElementById(id);
    const valueElement = document.getElementById(id.replace('-fill', '-value'));
    
    if (fill) {
        let percentage = 0;
        percentage = Math.max(0, Math.min(100, (value / max) * 100));
        fill.style.width = percentage + '%';
        
        // Add warning classes
        const statusItem = fill.closest('.status-item');
        if (statusItem) {
            statusItem.classList.remove('warning', 'danger');
            if (percentage <= 20) {
                statusItem.classList.add('danger');
            } else if (percentage <= 40) {
                statusItem.classList.add('warning');
            }
        }
    }
    
    if (valueElement) {
        let percentage = 0;
        percentage = Math.max(0, Math.min(100, (value / max) * 100));
        valueElement.textContent = Math.round(percentage) + '%';
    }
}

// Update creature appearance
function updateCreatureAppearance(creature) {
    currentCreature = creature;
    
    const badge = document.getElementById('creature-badge');
    const creatureType = document.getElementById('creature-type');
    const creatureStatus = document.getElementById('creature-status');
    const hungerItem = document.getElementById('hunger-item');
    const thirstItem = document.getElementById('thirst-item');
    const hungerIcon = document.getElementById('hunger-icon');
    const thirstIcon = document.getElementById('thirst-icon');
    const hungerLabel = document.getElementById('hunger-label');
    const thirstLabel = document.getElementById('thirst-label');
    const hungerFill = document.getElementById('hunger-fill');
    const thirstFill = document.getElementById('thirst-fill');
    
    // Reset all classes
    hungerIcon.classList.remove('vampire', 'lycan');
    thirstIcon.classList.remove('vampire', 'lycan');
    hungerFill.classList.remove('vampire', 'lycan');
    thirstFill.classList.remove('vampire', 'lycan');
    
    if (creature === 'vampire') {
        // Show vampire badge
        badge.style.display = 'flex';
        creatureType.textContent = 'Vampire';
        
        // Update hunger/thirst for vampire
        hungerIcon.className = 'fas fa-tint vampire';
        thirstIcon.className = 'fas fa-wine-glass vampire';
        hungerLabel.textContent = 'Blood Thirst';
        thirstLabel.textContent = 'Vitality';
        hungerFill.classList.add('vampire');
        thirstFill.classList.add('vampire');
        
        // Show creature power
        creatureStatus.style.display = 'flex';
        document.getElementById('creature-icon').className = 'fas fa-moon vampire';
        document.getElementById('creature-status-label').textContent = 'Blood Power';
        document.getElementById('creature-fill').className = 'status-fill creature-fill vampire';
        
    } else if (creature === 'lycan') {
        // Show lycan badge
        badge.style.display = 'flex';
        creatureType.textContent = 'Lycan';
        
        // Update hunger/thirst for lycan
        hungerIcon.className = 'fas fa-drumstick-bite lycan';
        thirstIcon.className = 'fas fa-tint lycan';
        hungerLabel.textContent = 'Hunger';
        thirstLabel.textContent = 'Thirst';
        hungerFill.classList.add('lycan');
        thirstFill.classList.add('lycan');
        
        // Show creature power
        creatureStatus.style.display = 'flex';
        document.getElementById('creature-icon').className = 'fas fa-moon lycan';
        document.getElementById('creature-status-label').textContent = 'Rage Power';
        document.getElementById('creature-fill').className = 'status-fill creature-fill lycan';
        
    } else {
        // Human - hide creature elements
        badge.style.display = 'none';
        creatureStatus.style.display = 'none';
        
        // Reset hunger/thirst to normal
        hungerIcon.className = 'fas fa-drumstick-bite';
        thirstIcon.className = 'fas fa-tint';
        hungerLabel.textContent = 'Hunger';
        thirstLabel.textContent = 'Thirst';
    }
}

// Update time
function updateTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: false 
    });
    const timeElement = document.getElementById('status-time');
    if (timeElement) {
        timeElement.textContent = timeString;
    }
}

// Update all status
function updateAllStatus(data) {
    statusData = { ...statusData, ...data };
    
    updateStatusBar('hp-fill', statusData.health);
    updateStatusBar('armor-fill', statusData.armor);
    updateStatusBar('hunger-fill', statusData.hunger);
    updateStatusBar('thirst-fill', statusData.thirst);
    updateStatusBar('stress-fill', statusData.stress);
    
    if (currentCreature && currentCreature !== 'human') {
        updateStatusBar('creature-fill', statusData.creaturePower);
    }
}

// Message handler
window.addEventListener('message', (e) => {
    console.log('Fantasy Status: Received message', e.data);
    
    switch (e.data.action) {
        case 'show':
            document.body.classList.remove('hidden');
            playSound();
            break;
            
        case 'hide':
            document.body.classList.add('hidden');
            stopSound();
            break;
            
        case 'updateStatus':
            updateAllStatus(e.data.status);
            break;
            
        case 'updateCreature':
            updateCreatureAppearance(e.data.creature);
            break;
            
        case 'updatePlayerName':
            const nameElement = document.getElementById('player-name');
            if (nameElement) {
                nameElement.textContent = e.data.name || 'Player';
            }
            break;
    }
});

// Initialize time updates
setInterval(updateTime, 1000);
updateTime();

// Initial setup
updateCreatureAppearance('human');
updateAllStatus({
    health: 100,
    armor: 0,
    hunger: 100,
    thirst: 100,
    stress: 0,
    creaturePower: 0
});

// NUI Callbacks
window.addEventListener('load', () => {
    // Notify that NUI is ready
    if (typeof fetch !== 'undefined') {
        fetch(`https://localhost/ready`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).catch(() => {
            // Silently fail if fetch is not available
        });
    }
});