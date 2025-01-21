import os
import configparser
from flask import Flask, request, redirect, url_for, session, render_template
import mysql.connector
import hashlib

app = Flask(__name__)
app.secret_key = 'seu-segredo-super-seguro'  # Troque por uma chave secreta real


# Função para ler as configurações do sistem.conf
def load_config():
    config = configparser.ConfigParser()
    config.read('sistem.conf')
    db_config = config['database']
    return {
        'host': db_config.get('host'),
        'port': db_config.getint('port'),
        'dbname': db_config.get('dbname'),
        'user': db_config.get('user'),
        'password': db_config.get('password'),
    }

# Conectar ao banco de dados MySQL
def connect_to_database():
    db_config = load_config()
    return mysql.connector.connect(
        host=db_config['host'],
        port=db_config['port'],
        database=db_config['dbname'],
        user=db_config['user'],
        password=db_config['password'],
    )

@app.route('/')
def index():
    if 'user_id' in session:  # Se a sessão estiver ativa, redireciona para menu
        return redirect(url_for('menu'))
    return render_template('index.html')

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']

    # Cria o hash MD5 da senha fornecida
    hashed_password = hashlib.md5(password.encode()).hexdigest()

    # Conecta ao banco de dados e verifica as credenciais
    connection = connect_to_database()
    cursor = connection.cursor()
    query = "SELECT USU_COD FROM USUARIO WHERE USU_USUARIO = %s AND USU_SENHA_HASH = %s"
    cursor.execute(query, (username, hashed_password))
    user = cursor.fetchone()
    connection.close()

    if user:  # Se o usuário for encontrado
        session['user_id'] = user[0]  # Salva o ID do usuário na sessão
        return redirect(url_for('menu'))
    else:
        return render_template('index.html', error='Usuário ou senha inválidos')

@app.route('/menu')
def menu():
    if 'user_id' not in session:  # Bloqueia o acesso se a sessão não estiver ativa
        return redirect(url_for('index'))
    return render_template('menu.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)  # Remove o usuário da sessão
    return redirect(url_for('index'))

if __name__ == "__main__":
    app.run(debug=True)
