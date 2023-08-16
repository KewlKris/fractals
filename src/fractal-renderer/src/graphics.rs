mod state;
use state::State;

use winit::{
    event::*,
    event_loop::{ControlFlow, EventLoop, EventLoopProxy, EventLoopBuilder},
    window::WindowBuilder,
    window::Window, dpi::PhysicalPosition,
};

pub struct Graphics {
    state: State,
    event_loop: Option<EventLoop<CustomEvent>>,
}

impl Graphics {
    pub async fn new() -> Self {
        std::panic::set_hook(Box::new(console_error_panic_hook::hook));
        console_log::init_with_level(log::Level::Warn).expect("Couldn't initialize logger");
    
        let event_loop = EventLoopBuilder::<CustomEvent>::with_user_event().build();
        let window = WindowBuilder::new().build(&event_loop).unwrap();
    
        // Winit prevents sizing with CSS, so we have to set
        // the size manually when on web.
        use winit::dpi::PhysicalSize;
        window.set_inner_size(PhysicalSize::new(3200, 1800));
        
        use winit::platform::web::WindowExtWebSys;
        web_sys::window()
            .and_then(|win| win.document())
            .and_then(|doc| {
                let dst = doc.get_element_by_id("fractal-div")?;
                let canvas = web_sys::Element::from(window.canvas());
                dst.append_child(&canvas).ok()?;
                Some(())
            })
            .expect("Couldn't append canvas to document body.");
    
        let state = State::new(window).await;

        Self {
            state,
            event_loop: Some(event_loop),
        }
    }

    pub fn get_controller(&self) -> GraphicsController {
        GraphicsController {
            proxy: self.event_loop.as_ref().unwrap().create_proxy(),
        }
    }

    pub fn start(mut self) {
        let event_loop = self.event_loop.take().unwrap();
        event_loop.run(move |event, _, control_flow| {
            match event {
                Event::WindowEvent {
                    ref event,
                    window_id,
                } if window_id == self.state.window().id() => if !self.state.input(event) { // UPDATED!
                    match event {
                        WindowEvent::CloseRequested
                        | WindowEvent::KeyboardInput {
                            input:
                                KeyboardInput {
                                    state: ElementState::Pressed,
                                    virtual_keycode: Some(VirtualKeyCode::Escape),
                                    ..
                                },
                            ..
                        } => *control_flow = ControlFlow::Exit,
                        WindowEvent::Resized(physical_size) => {
                            self.state.resize(*physical_size);
                        }
                        WindowEvent::ScaleFactorChanged { new_inner_size, .. } => {
                            self.state.resize(**new_inner_size);
                        }
                        _ => {}
                    }
                },
                Event::RedrawRequested(window_id) if window_id == self.state.window().id() => {
                    self.state.update();
                    match self.state.render() {
                        Ok(_) => {}
                        // Reconfigure the surface if lost
                        Err(wgpu::SurfaceError::Lost) => self.state.resize(self.state.get_size()),
                        // The system is out of memory, we should probably quit
                        Err(wgpu::SurfaceError::OutOfMemory) => *control_flow = ControlFlow::Exit,
                        // All other errors (Outdated, Timeout) should be resolved by the next frame
                        Err(e) => eprintln!("{:?}", e),
                    }
                }
                Event::MainEventsCleared => {
                    // RedrawRequested will only trigger once, unless we manually
                    // request it.
                    self.state.window().request_redraw();
                },
                Event::UserEvent(e) => {
                    match e {
                        CustomEvent::SetSize(width, height) => {
                            self.state.resize(winit::dpi::PhysicalSize::new(width, height));
                        }
                    }
                },
                _ => {},
            }
        });
    }
}

pub struct GraphicsController {
    proxy: EventLoopProxy<CustomEvent>,
}

impl GraphicsController {
    pub fn set_size(&self, width: u32, height: u32) {
        self.proxy.send_event(CustomEvent::SetSize(width, height));
    }
}

#[derive(Clone, Copy)]
enum CustomEvent {
    SetSize(u32, u32),
}