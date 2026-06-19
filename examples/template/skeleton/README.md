# ${{ values.name }}

${{ values.description }}

A minimal Node.js API service scaffolded by the AWS IDP Backstage portal.

## Run locally

Install dependencies and start the server:

    npm install
    npm start

The server listens on port 8080 and returns a small JSON health payload.

## Files

- src/index.js is the HTTP server entry point.
- catalog-info.yaml registers this service in the Backstage catalog.
- package.json defines the start script and metadata.

## Coming later, handled by the platform and not by hand

The IDP will add Terraform for ECS Fargate behind an ALB, a GitHub Actions
pipeline using OIDC federation into AWS, and CloudWatch plus Grafana wiring.
None of that exists in this starter yet.
