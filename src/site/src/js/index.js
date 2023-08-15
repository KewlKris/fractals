import initWasm from "fractal-renderer";

(async () => {
    let wasm = await initWasm();
    await wasm.run();
    setTimeout(() => {
        let canvas = document.querySelector('#fractal-div>canvas');
        //canvas.width = window.innerWidth;
        //canvas.height = window.innerHeight;
        //canvas.setAttribute('width', window.innerWidth);
        //canvas.setAttribute('height', window.innerHeight);
    }, 50);
})();