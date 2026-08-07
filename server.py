import os
import subprocess
import tempfile
from flask import Flask, request, jsonify, send_from_directory

app = Flask(__name__, static_folder='public', static_url_path='')

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/api/deobfuscate', methods=['POST'])
def deobfuscate():
    data = request.get_json() or {}
    code = data.get('code', '')
    
    if not code:
        return jsonify({'success': False, 'error': 'No code provided'}), 400

    # Write input code to a temporary file
    with tempfile.NamedTemporaryFile(mode='w+', suffix='.lua', delete=False) as temp_in:
        temp_in.write(code)
        temp_in_path = temp_name = temp_in.name

    temp_out_path = temp_in_path + ".out.lua"

    try:
        # Execute the luauvmp CLI command
        result = subprocess.run(
            ['python3', '-m', 'luauvmp.cli', 'deobf', temp_in_path, '-o', temp_out_path],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if os.path.exists(temp_out_path):
            with open(temp_out_path, 'r') as f:
                output = f.read()
            os.remove(temp_out_path)
            os.remove(temp_in_path)
            return jsonify({'success': True, 'deobfuscated': output})
        else:
            if os.path.exists(temp_in_path):
                os.remove(temp_in_path)
            return jsonify({'success': False, 'error': result.stderr or result.stdout or 'Deobfuscation failed'}), 500

    except Exception as e:
        if os.path.exists(temp_in_path):
            os.remove(temp_in_path)
        return jsonify({'success': False, 'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
