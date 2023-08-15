mod utils;
mod graphics;

use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern "C" {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet() {
    alert("Hello, fractal-renderer! Sup!");
}

#[wasm_bindgen]
pub async fn run() {
    graphics::run().await;
}