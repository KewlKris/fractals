import initWasm from "fractal-renderer";

let WASM = undefined;

(async () => {
    WASM = await initWasm();
    await WASM.run();
    window.addEventListener('resize', () => {
        updateSize();
    });
    updateSize();
})();

function updateSize() {
    let canvas = document.querySelector('#fractal-div>canvas');
    let ratio = window.devicePixelRatio;
    WASM.set_size(window.innerWidth * ratio, window.innerHeight * ratio);
    canvas.style.width = `${window.innerWidth}px`;
    canvas.style.height = `${window.innerHeight}px`;
}