# gigbag
GUSTAVO AQUI, O MELHORBAIXISTA DO MUNDO
Repositório do projeto **Gigbag**.

## gigbag_app (Flutter)

O app está em `gigbag_app/`.

### Rodar localmente

```bash
cd gigbag_app
flutter pub get
flutter run
```

### Deploy público (GitHub Actions)

**GitHub Pages (`*.github.io/gigbag/`)**  
O workflow **Deploy Gigbag Web** publica o Flutter na branch **`gh-pages`** (raiz). Em **Settings → Pages**: escolha fonte **Deploy from a branch**, branch **`gh-pages`**, pasta **`/(root)`**.  
Não use **branch `developer`** + pasta **`/docs`** — o GitHub tenta compilar com **Jekyll** e falha (pasta `docs` antiga / projeto Flutter).

**Firebase (`gigbag-app.web.app`)**  
O workflow **Deploy Firebase Hosting** precisa do secret **`FIREBASE_SERVICE_ACCOUNT_GIGBAG_APP`** (JSON da conta de serviço em Firebase Console → Project settings → Service accounts → Generate new private key).

Publicação local Firebase (sem CI): `powershell -File .\scripts\publicar-gigbag-firebase.ps1`

