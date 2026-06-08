from flask import Flask

app = Flask(__name__)

@app.route("/")
def inicio():
    return {
        "mensaje": "Hola desde una API Flask dockerizada"
    }

@app.route("/saludo/<nombre>")
def saludo(nombre):
    return {
        "mensaje": f"Hola {nombre}, estás usando Docker"
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)