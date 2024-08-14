![Github card](https://github.com/user-attachments/assets/50fc3276-d641-4931-b12a-e303cabf31ba)

# SideKick 🥾 By Context.ai
SideKick 🥾 is open source LLM chat and AI search that runs over your team's data.

- Connect your team's data sources, today supporting Google Docs and GMail with more available soon.
- Perform semantic searches all your team's data and create generative AI summaries.
- Integrate directly with frontier models over API and switch between them to get the best of each model's strengths 

## Get Started

Sidekick is fully self-hosted and can be deployed on most cloud infrastructure that supports Docker images.

### Self Host

1. Create a new Google OAuth application that can be used to authenticate your team and allow their Google data to be integrated into Sidekick.
    1. Visit ![alt text](image.png)

1. Generate encryption credentials for your deployment.

    ```
    $ docker run contextco/chat bin/generate_keys

    ENCRYPTION_KEY=xxx
    ENCRYPTION_DETERMINISTIC_KEY=xxx
    ENCRYPTION_KEY_DERIVATION_SALT=xxx
    ```

    Copy the keys into your .env file (or otherwise into the environment where you will deploy this Docker image).


2. Create a new Google OAuth application that can be used to authenticate your team and allow their Google data to be integrated into Sidekick. Creating an OAuth app is free and does not require that you host the application on GCP. 
    1. [Create a new project](https://console.cloud.google.com/projectcreate) in your Google Cloud account.
    1. Once initialized, configure the consent screen for users that sign up to your Sidekick instance.
       ![image](https://github.com/user-attachments/assets/f131660d-d664-40d6-af2a-eeb4581019e7)
    1. In the next screen, configure the OAuth application according to how you want it to be displayed to your users.
    1. Ensure that 'Authorized Domains' is setup to point at the URL where your Sidekick instance will be deployed. For example, if you want your application to be available at `https://search.acmeco.com`, add "acmeco.com" URL as an authorized domain.
        > ℹ️ If you see the error "Must be a top level domain" when adding your authorized domain, you may need to authenticate your domain with Google. To do so, add your domain as a property with Google Search Console.
        > 
        > ![image](https://github.com/user-attachments/assets/b1303e62-0552-42c8-8c1d-5fedb4e6fa97)

    1. Enable all of the default scopes for your application. In addition, add scopes that will allow Sidekick to ingest Gmail and Google Drive data.
       - https://www.googleapis.com/auth/drive.readonly
       - https://www.googleapis.com/auth/gmail.readonly
      
       Once your scopes have been added, the add/remove scopes table should look like this:

       ![image](https://github.com/user-attachments/assets/79bc7ef8-67e9-4044-975d-34979e739a0a)

3. Create credentials for the Google OAuth application. On the [OAuth credentials screen](https://console.cloud.google.com/apis/credentials), click 'Create Credentials' and then 'Client OAuth ID'.

  ![image](https://github.com/user-attachments/assets/1ffb67f5-3128-41e3-b5f4-7aa15ef3a780)
     
  1. Select 'Web Application' and fill in the "Authorized Javascript Origin" and "Authorized Redirect URIs" fields.

      1. In "Authorized Javascript Origin", add the URL where you will host this application. Eg: "https://search.acmeco.com"
      2. In "Authorized Redirect URIs" add the following paths with your URL prefixed:
           - `/auth/google_oauth2`
           - `/_/permissions/google_with_google_drive`
           - `/_/permissions/google_with_gmail`
          
          For example, for `/auth/google_oauth2`, add `https://search.acmeco.com/auth/google_oauth2`

  1. Create the credentials and copy the Client ID and Secret. Add these as environment variables to your deployment under `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.

     ![image](https://github.com/user-attachments/assets/14eaf5c9-f2cd-4a0a-8fb6-515868dc255a)

1. Add your OpenAI and Anthropic (optional) API keys as environment variables:

   ```
   OPENAI_KEY=xxx
   ANTHROPIC_API_KEY=xxx
   ```

## Feedback?
We would love to hear it! Open an issue and let us know, or email us at henry@context.ai
