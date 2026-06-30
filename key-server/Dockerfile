FROM python:3.11-slim

WORKDIR /app

# Installation des dépendances requises
RUN pip install --no-cache-dir fastapi uvicorn

# Copie du script principal
COPY main.py /app/main.py

# Exposition du port interne de l'application
EXPOSE 8080

# Commande de lancement d'Uvicorn
CMD ["uvicorn", "main.py:app", "--host", "0.0.0.0", "--port", "8080"]