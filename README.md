![Github card](https://github.com/user-attachments/assets/50fc3276-d641-4931-b12a-e303cabf31ba)
_[Star us on Github](https://github.com/contextco/chat)_

# SideKick 🥾 By Context.ai
SideKick 🥾 is open source LLM chat and AI search that runs over your team's data.

- Connect your team's data sources, today supporting Google Docs and GMail with more available soon.
- Perform semantic searches all your team's data and create generative AI summaries.
- Integrate directly with frontier models over API and switch between them to get the best of each model's strengths 

## Get Started

### Localhost

```
git clone https://github.com/contextco/chat
cd chat

docker-compose up -d
```

### Self-host (Single Image)

1. Generate encryption credentials for your deployment.

```
docker run contextco/chat bin/generate_keys
```

Copy these keys into your .env file (or otherwise into the environment where you will deploy this Docker image).

```
ENCRYPTION_KEY=xxx
ENCRYPTION_DETERMINISTIC_KEY=xxx
ENCRYPTION_KEY_DERIVATION_SALT=xxx
```

2. Create a new Google OAuth application that can be used to authenticate your team and allow their Google data to be integrated into Sidekick.

- Visit 



## Feedback?
We would love to hear it! Open an issue and let us know, or email us at henry@context.ai
