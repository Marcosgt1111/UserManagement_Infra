# UserManagement · Infra

Infraestrutura para rodar o projeto inteiro em containers com **Docker Compose**:

| Serviço | Imagem / Build | Porta | Função |
|---|---|---|---|
| `db` | `postgres:17-alpine` | interna (5432) | Banco de dados, com volume `pgdata` |
| `api` | [UserManagementAPI](https://github.com/Marcosgt1111/UsermanagementAPI) | interna (8080) | API .NET (login JWT + CRUD de pessoas) |
| `front` | [UserManagement_Frontend](https://github.com/Marcosgt1111/UserManagement_Frontend) | **8080** | React servido por Nginx, que repassa `/api` para a API |

```
Navegador ──► localhost:8080 ──► [front: Nginx] ──/api──► [api :8080] ──► [db :5432]
```

Só o `front` é exposto. O banco e a API ficam acessíveis apenas dentro da rede do Docker.

## Pré-requisitos

- Docker Desktop rodando
- Os três repositórios clonados **lado a lado** na mesma pasta:

```
DevOps/
├── UserManagementAPI/
├── UserManagement_Frontend/
└── UserManagement_Infra/      ← você está aqui
```

## Como subir

1. Crie o arquivo de variáveis a partir do exemplo e preencha os valores:

   ```bash
   cp .env.example .env
   ```

2. Faça o build das imagens e suba tudo:

   ```bash
   docker compose up --build
   ```

3. Abra http://localhost:8080 e entre com `admin` / `123456`.

Na primeira subida o banco começa vazio; a API aplica as migrations e cria as tabelas sozinha.

## Comandos úteis

| Comando | O que faz |
|---|---|
| `docker compose up --build -d` | Sobe em segundo plano (`-d` = detached) |
| `docker compose ps` | Mostra o estado dos containers |
| `docker compose logs -f api` | Acompanha os logs da API |
| `docker compose down` | Para e remove os containers (os **dados ficam** no volume) |
| `docker compose down -v` | Para tudo **e apaga o banco** (volume `pgdata`) |

## Variáveis de ambiente

| Variável | Uso |
|---|---|
| `POSTGRES_USER` / `POSTGRES_PASSWORD` | Usuário e senha do Postgres (também usados na connection string da API) |
| `JWT_KEY` | Chave de assinatura dos tokens JWT (mínimo de 32 caracteres) |

Se alguma estiver faltando, o `docker compose` para com uma mensagem dizendo qual.
