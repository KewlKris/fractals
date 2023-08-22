import initWasm from "fractal-renderer";

let WASM = undefined;

(async () => {
    WASM = await initWasm();
    await WASM.run();
    window.addEventListener('resize', () => {
        updateSize();
    });
    updateSize();
    //testMandelbrot();
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

function testMandelbrot() {
    /** @type {HTMLCanvasElement} */
    let canvas = document.querySelector('#test-canvas');
    let ctx = canvas.getContext('2d');

    // Define size
    let width = 500;
    let height = 500;
    canvas.width = width;
    canvas.height = height;
    
    // Make background white
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, width, height);
    ctx.fillStyle = 'black';

    let px = (x, y) => {
        // Draw a raw pixel
        ctx.fillRect(x, y, 1, 1);
    };
    let pt = (x, y) => {
        // Draw a parametric point (canvas domain: -2..2)
        x *= width / 4;
        y *= height / 4;
        x += width / 2;
        y += height / 2;
        px(x, y);
    };

    // Bring functions into scope
    const sin = Math.sin;
    const cos = Math.cos;
    const pow = Math.pow;
    const sqr = x => pow(x,2);

    // Attempt to draw mandelbrot orbit
    let depth = 1;
    let r = 2;
    for (let theta = 0; theta < Math.PI*2; theta += 0.001) {
        let x = r * cos(theta);
        let y = r * sin(theta);
        for (let i=0; i<depth; i++) {
            let newX = (sqr(x) - sqr(y)) + (r * cos(theta));
            let newY = (2 * x * y) + (r * sin(theta));

            x = newX;
            y = newY;
        }

        // cos^2 + sin^2 = 4
        // (𝑥2−𝑦2+𝑥)2+(2𝑥𝑦+𝑦)2=4
        



        pt(x, y);
    }
}