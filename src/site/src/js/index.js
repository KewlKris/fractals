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

window.julia = (complex, constant) => {
    let real = (complex[0] * complex[0]) - (complex[1] * complex[1]);
    let imaginary = 2 * complex[0] * complex[1];
    return [real + constant[0], imaginary + constant[1]];
};

window.jlen = (complex) => {
    return Math.sqrt((complex[0] * complex[0]) + (complex[1] * complex[1]));
};