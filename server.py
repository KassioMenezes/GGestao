import os
import configparser
from flask import Flask, request, redirect, url_for, session, render_template
import mysql.connector
import hashlib


app = Flask(__name__)
app.secret_key = '$2a$12$JEgjBbujv4t9dMfxZkocbO5V93mjUMMMMXsTvzzY0uqG5KzVQGucy'


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
    if 'user_id' in session:
        return redirect(url_for('menu'))
    return render_template('index.html')

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']

    hashed_password = hashlib.md5(password.encode()).hexdigest()

    connection = connect_to_database()
    cursor = connection.cursor()
    query = "SELECT USU_COD FROM USUARIO WHERE USU_USUARIO = %s AND USU_SENHA_HASH = %s"
    cursor.execute(query, (username, hashed_password))
    user = cursor.fetchone()
    connection.close()

    if user:  
        session['user_id'] = user[0] 
        return redirect(url_for('menu'))
    else:
        return render_template('index.html', error='Usuário ou senha inválidos')

@app.route('/menu')
def menu():
    if 'user_id' not in session: 
        return redirect(url_for('index'))
    return render_template('menu.html')

@app.route('/novaSenha')
def novaSenha():
    return render_template('novaSenha.html')

@app.route('/novoUsuarioSistema')
def novoUsuarioSistema():
    return render_template('addUsuario.html')


@app.route('/addUsuario', methods=['GET', 'POST'])
def add_usuario():
    if 'user_id' not in session:  # Bloqueia o acesso se a sessão não estiver ativa
        return redirect(url_for('index'))
    
    mensagem = ''  # Inicializa a variável de mensagem

    if request.method == 'POST':
        # Coleta os dados do formulário
        nome = request.form['nome']
        usuario = request.form['usuario']
        senha = request.form['senha']
        status = request.form.get('status', 'Pendente')  # Define o status como 'Pendente' por padrão

        try:
            # Criptografa a senha com MD5
            hashed_password = hashlib.md5(senha.encode('utf-8')).hexdigest()  # Gera o hash MD5 da senha

            # Conecta ao banco de dados
            connection = connect_to_database()
            cursor = connection.cursor()

            # Insere o novo usuário no banco de dados
            query = """
                INSERT INTO USUARIO (USU_USUARIO, USU_SENHA_HASH, USU_STATU)
                VALUES (%s, %s, %s)
            """
            cursor.execute(query, (usuario, hashed_password, status))
            connection.commit()

            # Fecha a conexão
            connection.close()

            # Define a mensagem de sucesso
            mensagem = 'Usuário cadastrado com sucesso!'
        except Exception as e:
            # Em caso de erro, define uma mensagem de erro
            mensagem = f'Ocorreu um erro: {str(e)}'

    # Retorna o template e inclui a mensagem no contexto
    return render_template('addUsuario.html', mensagem=mensagem)


@app.route('/sair')
def logout():
    session.pop('user_id', None)  # Remove o usuário da sessão
    return redirect(url_for('index'))

if __name__ == "__main__":
    app.run(debug=True)
