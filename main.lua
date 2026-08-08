<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Overdrive Hub | Roblox Script Hub</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-dark: #0a0c10;
      --card-bg: #12161f;
      --card-border: #1e2638;
      --accent-blue: #0088ff;
      --accent-purple: #7b2cbf;
      --text-main: #f0f4f8;
      --text-muted: #8a99ad;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      font-family: 'Inter', sans-serif;
    }

    body {
      background-color: var(--bg-dark);
      color: var(--text-main);
      line-height: 1.6;
      overflow-x: hidden;
    }

    .glow-top {
      position: absolute;
      top: -100px;
      left: 50%;
      transform: translateX(-50%);
      width: 600px;
      height: 300px;
      background: radial-gradient(circle, rgba(0, 136, 255, 0.25) 0%, rgba(123, 44, 191, 0.15) 50%, rgba(0,0,0,0) 80%);
      filter: blur(80px);
      z-index: -1;
    }

    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1.5rem 10%;
      border-bottom: 1px solid var(--card-border);
      background: rgba(10, 12, 16, 0.8);
      backdrop-filter: blur(10px);
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .logo {
      font-weight: 800;
      font-size: 1.5rem;
      background: linear-gradient(135deg, var(--accent-blue), var(--accent-purple));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      letter-spacing: 1px;
    }

    nav a {
      color: var(--text-muted);
      text-decoration: none;
      margin-left: 2rem;
      font-weight: 600;
      transition: color 0.3s;
    }

    nav a:hover {
      color: var(--text-main);
    }

    .hero {
      text-align: center;
      padding: 6rem 1rem 4rem;
      max-width: 900px;
      margin: 0 auto;
    }

    .hero h1 {
      font-size: 3.5rem;
      font-weight: 800;
      line-height: 1.2;
      margin-bottom: 1.5rem;
    }

    .hero h1 span {
      background: linear-gradient(135deg, #00d2ff, #0088ff);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .hero p {
      color: var(--text-muted);
      font-size: 1.2rem;
      margin-bottom: 2.5rem;
    }

    .btn-group {
      display: flex;
      gap: 1rem;
      justify-content: center;
      flex-wrap: wrap;
    }

    .btn {
      padding: 0.8rem 2rem;
      border-radius: 8px;
      font-weight: 600;
      text-decoration: none;
      transition: transform 0.2s, box-shadow 0.2s;
      cursor: pointer;
      border: none;
    }

    .btn-primary {
      background: linear-gradient(135deg, var(--accent-blue), var(--accent-purple));
      color: #fff;
      box-shadow: 0 4px 20px rgba(0, 136, 255, 0.3);
    }

    .btn-secondary {
      background: var(--card-bg);
      color: var(--text-main);
      border: 1px solid var(--card-border);
    }

    .btn:hover {
      transform: translateY(-2px);
    }

    .script-section {
      max-width: 800px;
      margin: 2rem auto;
      padding: 0 1rem;
    }

    .code-box {
      background-color: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 1.5rem;
      position: relative;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }

    .code-box-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1rem;
      padding-bottom: 0.5rem;
      border-bottom: 1px solid var(--card-border);
    }

    .code-box-title {
      font-size: 0.9rem;
      color: var(--text-muted);
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 1px;
    }

    pre {
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.95rem;
      color: #00d2ff;
      overflow-x: auto;
      white-space: pre-wrap;
      word-break: break-all;
    }

    .copy-btn {
      background: var(--card-border);
      color: var(--text-main);
      border: none;
      padding: 0.4rem 1rem;
      border-radius: 6px;
      font-size: 0.85rem;
      cursor: pointer;
      transition: background 0.2s;
    }

    .copy-btn:hover {
      background: var(--accent-blue);
    }

    .features {
      max-width: 1100px;
      margin: 6rem auto;
      padding: 0 1rem;
    }

    .features-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 1.5rem;
      margin-top: 2rem;
    }

    .feature-card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 2rem;
      transition: border-color 0.3s;
    }

    .feature-card:hover {
      border-color: var(--accent-blue);
    }

    .feature-icon {
      font-size: 2rem;
      margin-bottom: 1rem;
    }

    .feature-card h3 {
      font-size: 1.25rem;
      margin-bottom: 0.5rem;
    }

    .feature-card p {
      color: var(--text-muted);
      font-size: 0.95rem;
    }

    footer {
      text-align: center;
      padding: 3rem 1rem;
      border-top: 1px solid var(--card-border);
      color: var(--text-muted);
      font-size: 0.9rem;
    }
  </style>
</head>
<body>

  <div class="glow-top"></div>

  <header>
    <div class="logo">OVERDRIVE</div>
    <nav>
      <a href="#home">Home</a>
      <a href="#script">Script</a>
      <a href="#features">Features</a>
      <a href="https://discord.gg/ux2fjm2rt8" target="_blank">Discord</a>
    </nav>
  </header>

  <main>
    <section class="hero" id="home">
      <h1>Elevate Your Gameplay with <span>Overdrive Hub</span></h1>
      <p>Fast, reliable, and feature-rich execution designed for seamless performance across supported titles.</p>
      <div class="btn-group">
        <a href="#script" class="btn btn-primary">Get Script</a>
        <a href="https://discord.gg/ux2fjm2rt8" target="_blank" class="btn btn-secondary">Join Discord</a>
      </div>
    </section>

    <section class="script-section" id="script">
      <div class="code-box">
        <div class="code-box-header">
          <span class="code-box-title">Loadstring Loader</span>
          <button class="copy-btn" id="copyBtn" onclick="copyScript()">Copy Code</button>
        </div>
        <pre><code id="scriptCode">loadstring(game:HttpGet("https://applewareh.vercel.app/full.lua"))()</code></pre>
      </div>
    </section>

    <section class="features" id="features">
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">⚡</div>
          <h3>Fast Execution</h3>
          <p>Optimized for low-latency performance with instant feature loading and minimal FPS impact.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🛡️</div>
          <h3>Undetected & Safe</h3>
          <p>Built with modern execution protections and frequent updates following game patches.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🎨</div>
          <h3>Clean UI Interface</h3>
          <p>An intuitive user interface equipped with custom keybinds, dark mode, and saved configurations.</p>
        </div>
      </div>
    </section>
  </main>

  <footer>
    <p>&copy; 2026 Overdrive Hub. All rights reserved.</p>
  </footer>

  <script>
    function copyScript() {
      const codeText = document.getElementById("scriptCode").innerText;
      navigator.clipboard.writeText(codeText).then(() => {
        const btn = document.getElementById("copyBtn");
        btn.innerText = "Copied!";
        btn.style.background = "#00c853";
        setTimeout(() => {
          btn.innerText = "Copy Code";
          btn.style.background = "";
        }, 2000);
      });
    }
  </script>
</body>
</html>
