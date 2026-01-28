const sound = document.getElementById('starSound');
const transformBtn = document.getElementById('transformations-btn');

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

// Gestione click pulsante trasformazioni
if (transformBtn) {
    transformBtn.addEventListener('click', () => {
        console.log('Fantasy Status: Trasformazioni button clicked');
        // Chiudi fantasy status
        fetch(`https://fantasy_status/close`, {
            method: 'POST'
        }).then(() => {
            // Apri menu trasformazioni
            fetch(`https://fantasy_status/openTransformations`, {
                method: 'POST'
            });
        });
    });
}

window.addEventListener('message', (e) => {
    console.log('Fantasy Status: Received message', e.data);
    if (e.data.action === 'show') {
        document.body.classList.remove('hidden');
        playSound();
        // avvio canvas ecc...
    }

    if (e.data.action === 'hide') {
        document.body.classList.add('hidden');
        stopSound();
    }
});