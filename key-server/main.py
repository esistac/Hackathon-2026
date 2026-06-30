from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import os

app = FastAPI()

# Autoriser les requêtes depuis les lecteurs vidéo (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simulation du token valide pour le Hackathon
VALID_TOKEN = "token_cyber_2026"
KEY_FILE_PATH = "/app/enc.key"

@app.get("/key")
def get_key(token: str = None):
    # Logique Zero-Trust : Pas de token ou token invalide = Accès refusé
    if not token or token != VALID_TOKEN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Accès refusé : Token manquant ou invalide."
        )
    
    # Si le token est bon, on vérifie que le fichier de clé existe bien sur le conteneur
    if not os.path.exists(KEY_FILE_PATH):
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Clé introuvable sur le serveur."
        )
        
    return FileResponse(KEY_FILE_PATH, media_type="application/octet-stream")