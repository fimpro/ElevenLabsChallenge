const playBtn = document.querySelector('.play-btn');
const playImg = document.querySelector('.play-img');
const pauseImg = document.querySelector('.pause-img');
const points = [...document.querySelectorAll('.point')];
const iframe = document.querySelector('.app-iframe');
const appParent = document.querySelector('.app-parent');

playBtn.addEventListener('click', () => {
    console.log('play click');
    iframe.contentWindow.postMessage({
        'type': 'play'
    }, new URL(iframe.src).origin);
});

window.addEventListener('message', ({ data: { type, data } }) => {
    console.log('js got message', type, data);

    if (type === 'setControlsVisible') {
        console.log('controlsvisible');
        setControlsVisible(data);
    } else if (type === 'setIsPlaying') {
        setPlayState(data);
    } else if (type === 'setIndex') {
        setIndex(data);
    }
});

function setControlsVisible(isVisible) {
    if (isVisible) {
        appParent.classList.add('visible-controls');
    } else {
        appParent.classList.remove('visible-controls');
    }
}

function setPlayState(isPlaying) {
    if (isPlaying) {
        playImg.classList.add('hidden');
        pauseImg.classList.remove('hidden');
    } else {
        playImg.classList.remove('hidden');
        pauseImg.classList.add('hidden');
    }
}

function setIndex(index) {
    points.forEach((point, i) => {
        if (i === Math.floor(index / 3)) {
            point.classList.add('bg-white');
        } else {
            point.classList.remove('bg-white');
        }
    });
}

setIndex(0);
setPlayState(false);