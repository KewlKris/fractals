mod utils;
mod graphics;
use graphics::Graphics;
use graphics::GraphicsController;
use std::cell::RefCell;
use std::sync::RwLock;

use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern "C" {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet() {
    alert("Hello, fractal-renderer! Sup!");
}

static mut GRAPHICS: Option<GraphicsController> = None;

#[wasm_bindgen]
pub async fn run() {
    let graphics = Graphics::new().await;
    let controller = graphics.get_controller();
    unsafe { GRAPHICS = Some(controller) }
    graphics.start();
}

#[wasm_bindgen]
pub fn set_size(width: u32, height: u32) {
    unsafe {
        let gfx = GRAPHICS.take().unwrap();
        gfx.set_size(width, height);
        GRAPHICS = Some(gfx);
    }
}