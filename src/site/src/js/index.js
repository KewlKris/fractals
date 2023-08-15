import initWasm from "fractal-renderer";

(async () => {
    let wasm = await initWasm();
    wasm.greet();
})();