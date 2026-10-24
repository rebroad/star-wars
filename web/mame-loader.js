(async () => {
  const status = document.querySelector('#status');
  const scriptName = './starwars-web.js';
  const romUrl = './roms/starwars.zip';

  try {
    const [bundle, rom] = await Promise.all([
      fetch(scriptName, { method: 'HEAD' }),
      fetch(romUrl)
    ]);
    if (!bundle.ok) throw new Error(`${scriptName} is not deployed`);
    if (!rom.ok) throw new Error(`ROM package unavailable: ${romUrl}`);
    window.romBytes = new Uint8Array(await rom.arrayBuffer());
  } catch (error) {
    status.textContent = `Bundle not ready: ${error.message}`;
    return;
  }

  window.Module.arguments = ['starwars1', '-rompath', '/roms'];
  window.Module.locateFile = name => name.endsWith('.wasm') ? './starwars-web.wasm' : name;
  window.Module.onRuntimeInitialized = () => {
    window.mameRuntimeReady = true;
    status.textContent = 'MAME runtime initialized';
  };
  window.Module.onAbort = reason => {
    window.mameStartupError = `MAME aborted: ${reason}`;
    status.textContent = window.mameStartupError;
  };
  window.Module.preRun = [() => {
    console.log('MAME preRun reached');
    FS.mkdir('/roms');
    FS.writeFile('/roms/starwars.zip', window.romBytes);
  }];

  const script = document.createElement('script');
  script.src = scriptName;
  script.onerror = () => {
    window.mameStartupError = 'Unable to load the MAME WebAssembly bundle.';
    status.textContent = window.mameStartupError;
  };
  document.body.appendChild(script);
})();
