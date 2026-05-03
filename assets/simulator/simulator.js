/**
 * Custom Origami Simulator
 * Advanced 3D origami folding simulation with realistic physics
 * @fileoverview Origami simulation with Three.js
 */

// @ts-nocheck

// Global variables
let scene, camera, renderer, controls;
let origamiModel, currentGeometry;
let foldPercent = 60;
let viewMode = 'material';
let controlMode = 'rotate';
let isSimulationPaused = false;
let animationSpeed = 1.0;
let showAdvanced = false;

// Origami models data
const ORIGAMI_MODELS = {
    crane: {
        name: 'Paper Crane',
        vertices: [
            // Base square vertices
            [-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0],
            // Folded vertices for crane shape
            [0, 0, 0.8], [0, 1.5, 0.2], [0, -1.5, 0.2],
            [-1.2, 0, 0.4], [1.2, 0, 0.4]
        ],
        faces: [
            [0, 1, 4], [1, 2, 4], [2, 3, 4], [3, 0, 4],
            [4, 5, 2], [4, 6, 1], [4, 7, 3], [4, 8, 2]
        ],
        creases: [
            { from: [0, 0, 0], to: [2, 2, 0], type: 'mountain' },
            { from: [1, 0, 0], to: [1, 2, 0], type: 'valley' },
            { from: [0, 1, 0], to: [2, 1, 0], type: 'valley' }
        ],
        color: 0xe91e63
    },
    waterbomb: {
        name: 'Water Bomb Base',
        vertices: [
            [0, 1, 0], [0.866, -0.5, 0], [-0.866, -0.5, 0],
            [0, 0, 1], [0, 0, -1]
        ],
        faces: [
            [0, 1, 3], [1, 2, 3], [2, 0, 3],
            [0, 2, 4], [2, 1, 4], [1, 0, 4]
        ],
        creases: [
            { from: [0, 1, 0], to: [0, 0, 0], type: 'mountain' },
            { from: [0.866, -0.5, 0], to: [0, 0, 0], type: 'valley' },
            { from: [-0.866, -0.5, 0], to: [0, 0, 0], type: 'valley' }
        ],
        color: 0x2196f3
    },
    lotus: {
        name: 'Lotus Flower',
        vertices: [
            // Center
            [0, 0, 0],
            // Inner petals
            [0.5, 0, 0.3], [-0.5, 0, 0.3], [0, 0.5, 0.3], [0, -0.5, 0.3],
            // Outer petals
            [1, 0, 0.1], [-1, 0, 0.1], [0, 1, 0.1], [0, -1, 0.1],
            // Tips
            [0.8, 0, 0.8], [-0.8, 0, 0.8], [0, 0.8, 0.8], [0, -0.8, 0.8]
        ],
        faces: [
            [0, 1, 3], [0, 3, 2], [0, 2, 4], [0, 4, 1],
            [1, 5, 9], [2, 6, 10], [3, 7, 11], [4, 8, 12],
            [5, 9, 7], [6, 10, 8], [7, 11, 5], [8, 12, 6]
        ],
        creases: [
            { from: [0, 0, 0], to: [1, 0, 0], type: 'mountain' },
            { from: [0, 0, 0], to: [0, 1, 0], type: 'valley' }
        ],
        color: 0xff5722
    }
};

// Initialize the simulator
function initSimulator() {
    const container = document.getElementById('canvasContainer');
    if (!container) {
        console.error('Canvas container not found');
        return;
    }

    try {
        // Create scene
        scene = new THREE.Scene();
        scene.background = new THREE.Color(0x2c3e50);

        // Create camera
        const aspect = container.clientWidth / container.clientHeight;
        camera = new THREE.PerspectiveCamera(75, aspect, 0.1, 1000);
        camera.position.set(0, 0, 5);

        // Create renderer
        const canvas = document.getElementById('canvas');
        renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true });
        renderer.setSize(container.clientWidth, container.clientHeight);

        // Add lights
        const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
        scene.add(ambientLight);

        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(10, 10, 5);
        scene.add(directionalLight);

        // Add basic mouse controls
        setupMouseControls();

        // Load default model
        loadModel('crane');

        // Hide loading indicator
        const loading = document.getElementById('loading');
        if (loading) {
            loading.style.display = 'none';
        }

        // Start animation loop
        animate();

        // Handle window resize
        window.addEventListener('resize', onWindowResize);
        
        hideLoadingMessage();
        console.log('Origami simulator initialized successfully');
    } catch (error) {
        console.error('Error initializing simulator:', error);
        showErrorMessage('Failed to initialize 3D simulator');
    }
}

// Load origami model
function loadModel(modelName) {
    if (!ORIGAMI_MODELS[modelName]) {
        console.error('Model not found:', modelName);
        return;
    }

    const model = ORIGAMI_MODELS[modelName];
    
    // Remove existing model
    if (origamiModel) {
        scene.remove(origamiModel);
    }

    // Create geometry from model data
    const geometry = new THREE.BufferGeometry();
    const vertices = new Float32Array(model.vertices.flat());
    const indices = new Uint16Array(model.faces.flat());
    
    geometry.setIndex(indices);
    geometry.setAttribute('position', new THREE.BufferAttribute(vertices, 3));
    geometry.computeVertexNormals();

    // Create material
    const material = new THREE.MeshLambertMaterial({ 
        color: model.color || 0xffffff,
        side: THREE.DoubleSide
    });

    // Create mesh
    origamiModel = new THREE.Mesh(geometry, material);
    scene.add(origamiModel);
    
    currentGeometry = geometry;
    console.log('Loaded model:', modelName);
}

// Setup mouse controls
function setupMouseControls() {
    const canvas = document.getElementById('canvas');
    if (!canvas) return;

    let isMouseDown = false;
    let mouseX = 0;
    let mouseY = 0;

    canvas.addEventListener('mousedown', (event) => {
        isMouseDown = true;
        mouseX = event.clientX;
        mouseY = event.clientY;
        event.preventDefault();
    });

    canvas.addEventListener('mouseup', () => {
        isMouseDown = false;
    });

    canvas.addEventListener('mousemove', (event) => {
        if (!isMouseDown || !origamiModel) return;
        
        const deltaX = event.clientX - mouseX;
        const deltaY = event.clientY - mouseY;
        
        if (controlMode === 'rotate') {
            origamiModel.rotation.y += deltaX * 0.01;
            origamiModel.rotation.x += deltaY * 0.01;
        }
        
        mouseX = event.clientX;
        mouseY = event.clientY;
        event.preventDefault();
    });

    // Touch events for mobile
    canvas.addEventListener('touchstart', (event) => {
        if (event.touches.length === 1) {
            isMouseDown = true;
            mouseX = event.touches[0].clientX;
            mouseY = event.touches[0].clientY;
        }
        event.preventDefault();
    });

    canvas.addEventListener('touchend', () => {
        isMouseDown = false;
    });

    canvas.addEventListener('touchmove', (event) => {
        if (!isMouseDown || !origamiModel || event.touches.length !== 1) return;
        
        const deltaX = event.touches[0].clientX - mouseX;
        const deltaY = event.touches[0].clientY - mouseY;
        
        if (controlMode === 'rotate') {
            origamiModel.rotation.y += deltaX * 0.01;
            origamiModel.rotation.x += deltaY * 0.01;
        }
        
        mouseX = event.touches[0].clientX;
        mouseY = event.touches[0].clientY;
        event.preventDefault();
    });
}

// Handle window resize
function onWindowResize() {
    const container = document.getElementById('canvasContainer');
    if (!container || !camera || !renderer) return;

    const aspect = container.clientWidth / container.clientHeight;
    camera.aspect = aspect;
    camera.updateProjectionMatrix();
    renderer.setSize(container.clientWidth, container.clientHeight);
}

// Hide loading message
function hideLoadingMessage() {
    const loading = document.getElementById('loading');
    if (loading) {
        loading.style.display = 'none';
    }
}

// Show error message
function showErrorMessage(message) {
    const loading = document.getElementById('loading');
    if (loading) {
        loading.innerHTML = `<div style="color: #ff6b6b; text-align: center;">
            <div style="font-size: 24px; margin-bottom: 8px;">⚠️</div>
            <div>${message}</div>
        </div>`;
    }
}

// Control functions called from HTML
function setViewMode(mode) {
    viewMode = mode;
    updateViewMode();
}

function setControlMode(mode) {
    controlMode = mode;
    updateControlMode();
}

function pauseSimulation() {
    isSimulationPaused = !isSimulationPaused;
    const btn = document.getElementById('pauseBtn');
    if (btn) {
        btn.textContent = isSimulationPaused ? '▶️ Play' : '⏸️ Pause';
    }
}

function resetSimulation() {
    if (origamiModel) {
        origamiModel.rotation.set(0, 0, 0);
        origamiModel.position.set(0, 0, 0);
    }
    foldPercent = 60;
    const slider = document.getElementById('foldSlider');
    const value = document.getElementById('foldValue');
    if (slider) slider.value = foldPercent;
    if (value) value.textContent = foldPercent + '%';
}

function toggleAdvanced() {
    showAdvanced = !showAdvanced;
    const panel = document.getElementById('advancedPanel');
    if (panel) {
        panel.classList.toggle('show', showAdvanced);
    }
}

function showExamples() {
    // Cycle through available models
    const modelNames = Object.keys(ORIGAMI_MODELS);
    const currentIndex = modelNames.indexOf('crane');
    const nextIndex = (currentIndex + 1) % modelNames.length;
    loadModel(modelNames[nextIndex]);
}

// Setup fold slider event listener
document.addEventListener('DOMContentLoaded', () => {
    const foldSlider = document.getElementById('foldSlider');
    const foldValue = document.getElementById('foldValue');
    
    if (foldSlider && foldValue) {
        foldSlider.addEventListener('input', (event) => {
            foldPercent = parseInt(event.target.value);
            foldValue.textContent = foldPercent + '%';
            updateFoldGeometry();
        });
    }
});

// Update fold geometry based on slider
function updateFoldGeometry() {
    if (!origamiModel || !currentGeometry) return;
    
    // Simple fold animation by scaling Y axis
    const foldFactor = foldPercent / 100;
    origamiModel.scale.y = 0.5 + (foldFactor * 0.5);
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, initializing simulator...');
    initSimulator();
});
function animate() {
    requestAnimationFrame(animate);
    
    if (!isSimulationPaused && origamiModel) {
        // Auto-rotate if enabled
        origamiModel.rotation.y += 0.005;
    }
    
    // Limit camera zoom
    const distance = camera.position.length();
    if (distance < 2) camera.position.normalize().multiplyScalar(2);
    if (distance > 20) camera.position.normalize().multiplyScalar(20);
    
    renderer.render(scene, camera);
}

// Window resize handler
function onWindowResize() {
    const container = document.getElementById('canvas-container');
    if (!container) return;
    
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    renderer.setSize(width, height);
}

// Utility functions
function showLoadingMessage() {
    const loading = document.getElementById('loading-message');
    if (loading) loading.style.display = 'flex';
}

function hideLoadingMessage() {
    const loading = document.getElementById('loading-message');
    if (loading) loading.style.display = 'none';
}

function showError(message) {
    hideLoadingMessage();
    const container = document.getElementById('canvas-container');
    if (container) {
        container.innerHTML = `<div style="color: red; text-align: center; padding: 20px;">${message}</div>`;
    }
}

// Setup event listeners
function setupEventListeners() {
    // Fold slider
    const foldSlider = document.getElementById('foldSlider');
    if (foldSlider) {
        foldSlider.addEventListener('input', (event) => {
            foldPercent = parseFloat(event.target.value);
            updateFoldGeometry();
        });
    }
    
    // View mode buttons
    const materialBtn = document.getElementById('materialBtn');
    const strainBtn = document.getElementById('strainBtn');
    
    if (materialBtn) {
        materialBtn.addEventListener('click', () => {
            viewMode = 'material';
            updateViewMode();
        });
    }
    
    if (strainBtn) {
        strainBtn.addEventListener('click', () => {
            viewMode = 'strain';
            updateViewMode();
        });
    }
    
    // Control mode buttons
    const rotateBtn = document.getElementById('rotateBtn');
    const grabBtn = document.getElementById('grabBtn');
    
    if (rotateBtn) {
        rotateBtn.addEventListener('click', () => {
            controlMode = 'rotate';
            updateControlMode();
        });
    }
    
    if (grabBtn) {
        grabBtn.addEventListener('click', () => {
            controlMode = 'grab';
            updateControlMode();
        });
    }
    
    // Examples dropdown
    const exampleItems = document.querySelectorAll('.example-item');
    exampleItems.forEach(item => {
        item.addEventListener('click', (event) => {
            const modelName = event.target.dataset.model;
            if (modelName) {
                loadModel(modelName);
            }
        });
    });
    
    // Control buttons
    const pauseBtn = document.getElementById('pauseBtn');
    const resetBtn = document.getElementById('resetBtn');
    const advancedBtn = document.getElementById('advancedBtn');
    
    if (pauseBtn) {
        pauseBtn.addEventListener('click', togglePause);
    }
    
    if (resetBtn) {
        resetBtn.addEventListener('click', resetSimulation);
    }
    
    if (advancedBtn) {
        advancedBtn.addEventListener('click', toggleAdvanced);
    }
}

// Update view mode
function updateViewMode() {
    if (!origamiModel) return;
    
    const materialBtn = document.getElementById('materialBtn');
    const strainBtn = document.getElementById('strainBtn');
    
    if (viewMode === 'material') {
        if (materialBtn) materialBtn.classList.add('active');
        if (strainBtn) strainBtn.classList.remove('active');
        
        // Update material to show normal colors
        if (origamiModel.material) {
            origamiModel.material.wireframe = false;
        }
    } else if (viewMode === 'strain') {
        if (materialBtn) materialBtn.classList.remove('active');
        if (strainBtn) strainBtn.classList.add('active');
        
        // Update material to show strain visualization
        if (origamiModel.material) {
            origamiModel.material.wireframe = true;
        }
    }
}

// Update control mode
function updateControlMode() {
    const rotateBtn = document.getElementById('rotateBtn');
    const grabBtn = document.getElementById('grabBtn');
    
    if (controlMode === 'rotate') {
        if (rotateBtn) rotateBtn.classList.add('active');
        if (grabBtn) grabBtn.classList.remove('active');
    } else if (controlMode === 'grab') {
        if (rotateBtn) rotateBtn.classList.remove('active');
        if (grabBtn) grabBtn.classList.add('active');
    }
}

// Toggle pause
function togglePause() {
    isSimulationPaused = !isSimulationPaused;
    const pauseBtn = document.getElementById('pauseBtn');
    if (pauseBtn) {
        pauseBtn.textContent = isSimulationPaused ? '▶ Play' : '⏸ Pause';
    }
}

// Reset simulation
function resetSimulation() {
    foldPercent = 60;
    updateFoldGeometry();
    
    if (origamiModel) {
        origamiModel.rotation.set(0, 0, 0);
        camera.position.set(3, 3, 5);
        camera.lookAt(0, 0, 0);
        updateFoldPercent(60);
    }
}

function setViewMode(mode) {
    viewMode = mode;
    
    // Update button states
    document.getElementById('materialBtn').classList.toggle('active', mode === 'material');
    document.getElementById('strainBtn').classList.toggle('active', mode === 'strain');
    
    // Update material
    if (origamiModel) {
        const modelData = ORIGAMI_MODELS.crane; // Default color
        origamiModel.material = createMaterial(modelData.color);
    }
}

function setControlMode(mode) {
    controlMode = mode;
    
    // Update button states
    document.getElementById('rotateBtn').classList.toggle('active', mode === 'rotate');
    document.getElementById('grabBtn').classList.toggle('active', mode === 'grab');
}

// Handle window resize
function onWindowResize() {
    const container = document.getElementById('canvasContainer');
    const aspect = container.clientWidth / container.clientHeight;
    
    camera.aspect = aspect;
    camera.updateProjectionMatrix();
    renderer.setSize(container.clientWidth, container.clientHeight);
}

// Animation loop
function animate() {
    requestAnimationFrame(animate);
    
    if (isSimulationPaused) return;
    
    // Auto-rotate if enabled
    const autoRotateCheckbox = document.getElementById('autoRotate');
    if (autoRotateCheckbox && autoRotateCheckbox.checked && origamiModel) {
        origamiModel.rotation.y += 0.005 * animationSpeed;
    }
    
    // Render scene
    renderer.render(scene, camera);
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, initializing simulator...');
    initSimulator();
});
