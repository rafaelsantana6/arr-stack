# Media Server Setup

Este repositório contém a configuração de um servidor de mídia automatizado usando vários containers Docker. Abaixo, está a explicação de cada serviço e as configurações correspondentes.

## Requisitos

- Docker e Docker Compose instalados
- Crie um arquivo `.env` com as variáveis de ambiente:

  ```env
  PUID=1000
  PGID=1000
  TIMEZONE=America/Rio_Branco #GMT -5, para GMT -3, America/Sao_Paulo
  CONFIG_FOLDER=/path/to/config
  TORRENTS_FOLDER=/path/to/torrents
  MEDIA_FOLDER=/path/to/media
  DATA_FOLDER=/path/to/data
  ```

## Serviços

### 1. qBittorrent

Um cliente de torrent com interface web.

- **Image**: `lscr.io/linuxserver/qbittorrent:latest`
- **Portas**:
  - 8080: Interface web do qBittorrent
  - 6881: Porta de torrent (TCP e UDP)
- **Volumes**:
  - `${CONFIG_FOLDER}/qbittorrent:/config`: Onde as configurações do qBittorrent são armazenadas.
  - `${TORRENTS_FOLDER}:/downloads`: Diretório para downloads.
  - `${MEDIA_FOLDER}:/media`: Diretório para arquivos de mídia.
- **Rede**: Conectado à rede `media-network`.

### 2. Jackett

Jackett permite a integração com diversos indexadores de torrents.

- **Image**: `lscr.io/linuxserver/jackett:latest`
- **Porta**:
  - 9117: Interface web do Jackett.
- **Volumes**:
  - `${CONFIG_FOLDER}/jackett:/config`: Armazena as configurações.
  - `${TORRENTS_FOLDER}:/downloads`: Diretório para armazenar torrents temporários.
- **Rede**: Conectado à rede `media-network`.

### 3. Bazarr

Aplicativo de gerenciamento de legendas que se integra com Radarr e Sonarr.

- **Image**: `lscr.io/linuxserver/bazarr:latest`
- **Porta**:
  - 6767: Interface web do Bazarr.
- **Volumes**:
  - `${CONFIG_FOLDER}/bazarr:/config`: Armazena as configurações.
  - `${MEDIA_FOLDER}/movies:/movies`: Diretório para filmes.
  - `${MEDIA_FOLDER}/tv:/tv`: Diretório para séries.
- **Rede**: Conectado à rede `media-network`.

### 4. FlareSolverr

Um proxy que resolve captchas de sites de torrent.

- **Image**: `ghcr.io/flaresolverr/flaresolverr:latest`
- **Porta**:
  - `${PORT:-8191}:8191`: Porta para acesso ao serviço.
- **Volumes**: Não especificado.
- **Rede**: Conectado à rede `media-network`.

### 5. Homarr

Dashboard para monitoramento de todos os serviços.

- **Image**: `ghcr.io/ajnart/homarr:latest`
- **Porta**:
  - 7575: Interface do Homarr.
- **Volumes**:
  - `/var/run/docker.sock:/var/run/docker.sock`: Permite que o Homarr interaja com o Docker.
  - `${CONFIG_FOLDER}/homarr/configs:/app/data/configs`: Armazena as configurações.
  - `${DATA_FOLDER}/homarr/icons:/app/public/icons`: Armazena os ícones personalizados.
  - `${DATA_FOLDER}/homarr/data:/data`: Diretório de dados gerais.
- **Rede**: Conectado à rede `media-network`.

### 6. Overseerr

Aplicativo para gerenciamento de requisições de mídia.

- **Image**: `lscr.io/linuxserver/overseerr:latest`
- **Porta**:
  - 5055: Interface do Overseerr.
- **Volumes**:
  - `${CONFIG_FOLDER}/overseerr:/config`: Armazena as configurações.
- **Rede**: Conectado à rede `media-network`.

### 7. Prowlarr

Um agregador de indexadores de torrents.

- **Image**: `lscr.io/linuxserver/prowlarr:latest`
- **Porta**:
  - 9696: Interface web do Prowlarr.
- **Volumes**:
  - `${CONFIG_FOLDER}/prowlarr:/config`: Armazena as configurações.
- **Rede**: Conectado à rede `media-network`.

### 8. Radarr

Aplicativo para gerenciamento e organização de filmes.

- **Image**: `lscr.io/linuxserver/radarr:latest`
- **Porta**:
  - 7878: Interface web do Radarr.
- **Volumes**:
  - `${CONFIG_FOLDER}/radarr:/config`: Armazena as configurações.
  - `${MEDIA_FOLDER}/movies:/movies`: Diretório para filmes.
  - `${TORRENTS_FOLDER}:/downloads`: Diretório para downloads temporários.
- **Rede**: Conectado à rede `media-network`.

### 9. Sonarr

Aplicativo para gerenciamento e organização de séries de TV.

- **Image**: `lscr.io/linuxserver/sonarr:latest`
- **Porta**:
  - 8989: Interface web do Sonarr.
- **Volumes**:
  - `${CONFIG_FOLDER}/sonarr:/config`: Armazena as configurações.
  - `${MEDIA_FOLDER}/tv:/tv`: Diretório para séries de TV.
  - `${TORRENTS_FOLDER}:/downloads`: Diretório para downloads temporários.
- **Rede**: Conectado à rede `media-network`.

### 10. Watchtower

Ferramenta para atualização automática de containers Docker.

- **Image**: `containrrr/watchtower`
- **Volumes**:
  - `/var/run/docker.sock:/var/run/docker.sock`: Permite que o Watchtower gerencie os containers Docker.
- **Rede**: Conectado à rede `media-network`.
- **Configurações Adicionais**: O Watchtower verificará atualizações a cada 300 segundos e removerá containers antigos automaticamente.

## Rede

- **media-network**: Rede externa criada para comunicação entre todos os containers.

## Como Usar

1. Clone este repositório.
2. Crie o arquivo `.env` conforme o exemplo acima.
3. Execute o script para criar a rede:

   ```bash
   ./create-network.sh
   ```

4. Suba os containers usando o comando:

   ```bash
   docker-compose up -d
   ```

5. Acesse os serviços em seus respectivos endereços de porta, como `http://localhost:8080` para o qBittorrent.
