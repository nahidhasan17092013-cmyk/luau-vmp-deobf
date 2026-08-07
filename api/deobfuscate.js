import { exec } from 'child_process';
import path from 'path';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, error: 'Method not allowed' });
  }

  const { code } = req.body || {};
  if (!code) {
    return res.status(400).json({ success: false, error: 'No code provided' });
  }

  const scriptPath = path.join(process.cwd(), 'luauvmp', 'cli.py');
  
  exec(`python3 "${scriptPath}"`, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ success: false, error: stderr || error.message });
    }
    return res.status(200).json({ success: true, deobfuscated: stdout });
  });
}
