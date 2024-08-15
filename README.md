![Github card](https://github.com/user-attachments/assets/6350c4e0-2985-4919-9d61-30fab0baeb4e)


# Raggle By Context.ai
Raggle is an open source, self-hosted alternative to **Glean** and **ChatGPT**: an employee LLM assistant with enterprise RAG search that can be deployed in your private cloud, without sharing data. 

- Perform RAG over all your team's data, today supporting Google Docs and Gmail, with more integrations coming soon
- Chat with many frontier LLMs, with all the features you’d expect - like conversation history and document upload
- Coming soon: support for self-hosted LLMs, and more search integrations 

## Get Started

Raggle is designed to be fully self-hosted and can be deployed on most cloud infrastructure that supports Docker images.

### Configuration

1. Generate encryption credentials for your deployment.

    ```
    $ docker run ghcr.io/contextco/chat:latest bin/generate-keys

    ENCRYPTION_KEY=xxx
    ENCRYPTION_DETERMINISTIC_KEY=xxx
    ENCRYPTION_KEY_DERIVATION_SALT=xxx
    SECRET_KEY_BASE=xxx
    ```

    Copy the keys into your .env file (or otherwise into the environment where you will deploy this Docker image).


1. Create a new Google OAuth application that can be used to authenticate your team and allow their Google Workspace data to be indexed. Follow the instructions [in the wiki](https://github.com/contextco/chat/wiki/Setup-Google-OAuth) to setup this integration.

1. Add your OpenAI and Anthropic (optional) API keys as environment variables:

   ```
   OPENAI_KEY=xxx
   ANTHROPIC_API_KEY=xxx
   ```

### Deployment

A Raggle instance can be run in one of two ways:

- **Monolithic** This version runs all dependencies within a single Docker image and is the simplest to setup.

    **Pros**:
    - All dependencies are included within a single Docker image, so no additional external services are required.
    - Easiest to deploy and get started with.

    **Cons**:
    - Requires provisioning and mounting of a persistent disk to maintain database state across restarts.
    - Harder to manage backups and versioning of persisted data.

- **Server Only** Allows you to run the server and workers as independent services.

    **Pros**:
    - Can reuse existing database server resources.
    - Requires slightly less resources to deploy.

    **Cons**:
    - Requires maintaining additional external Redis and Postgres dependencies, which may be overhead if you don't already maintain these.
    - Some additional setup required to point the server instance at your external dependencies.


#### Monolithic Deployment

```
 # Assuming your environment variables are configured in .env

 docker run --env-file=.env \
   -p 3000:3000 \
   -v sidekick-data:/var/lib/postgresql/15/main \
   ghcr.io/contextco/chat:latest bin/monolith
```

#### Server-Only Deployment

For a server-only deployment you will need to configure two additional environment variables:
- `DATABASE_URL` pointing to an accessible Postgres server (eg: postgresql://user:password@host:5432/my_database)
- `REDIS_URL` pointing to an accessible Redis server (eg: redis://username:password@host:6379)

```
 # Assuming your environment variables are configured in .env

 docker run --env-file=.env ghcr.io/contextco/chat:latest -p 3000:3000 bin/server-only
```

## Feedback?
We would love to hear it! Open an issue and let us know, or email us at henry@context.ai
