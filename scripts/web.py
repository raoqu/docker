from flask import Flask, render_template, jsonify
from flask_socketio import SocketIO, emit
import subprocess
import threading

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

# 存储命令输出的变量
output_content = ""

def execute_long_running_command(cmd):
    global output_content
    process = subprocess.Popen(cmd.split(' '), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in iter(process.stdout.readline, ""):
        output_content += line
        socketio.emit('command_output', {'data': line}, namespace='/test')  # 发送数据到客户端
    process.stdout.close()
    process.wait()
    socketio.emit('command_output', {'data': 'COMPLETE_OUTPUT!!'}, namespace='/test')

def read_options(filename='options.txt'):
    with open(filename, 'r') as file:
        options = file.read().splitlines()
    return options

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/get_options', methods=['GET'])
def get_options():
    data_list = read_options()
    return jsonify(data_list)

@socketio.on('run_command', namespace='/test')
def handle_command(data):
    cmd = data['cmd']
    thread = threading.Thread(target=execute_long_running_command, args=(cmd,))
    thread.daemon = True
    thread.start()
    emit('response', {'data': 'Command is running...'})

if __name__ == '__main__':
    @socketio.on_error(namespace='/test')
    def test_error_handler(e):
        print(e)
    socketio.run(app, host='0.0.0.0', port=5000, allow_unsafe_werkzeug=True)