from fastapi import FastAPI, HTTPException, status
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI()

# Configuration CORS pour permettre aux navigateurs de requêter l'API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Liste de simulation des tokens éphémères valides
VALID_TOKENS = ["token_cyber_2026", "acces_autorise_99"]

@app.get("/key")
def get_key(token: str = None):
    # Logique Zero-Trust : Pas de token valide = Accès instantanément bloqué
    if not token or token not in VALID_TOKENS:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Accès refusé : Token manquant, invalide ou expiré."
        )
    
    key_path = "/app/secrets/enc.key"
    if os.path.exists(key_path):
        return FileResponse(key_path, media_type="application/octet-stream")
    
    raise HTTPException(status_code=500, detail="Fichier de clé introuvable sur le serveur.")