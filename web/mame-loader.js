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

  window.Module.arguments = ['starwars', '-rompath', '/roms'];
  window.Module.locateFile = name => name.endsWith('.wasm') ? `./${name}` : name;
  window.Module.preRun = [() => {
    FS.mkdir('/roms');
    FS.writeFile('/roms/starwars.zip', window.romBytes);
  }];

  const script = document.createElement('script');
  script.src = scriptName;
  script.onerror = () => { status.textContent = 'Unable to load the MAME WebAssembly bundle.'; };
  document.body.appendChild(script);
})();
