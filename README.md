# autoSDLC Templates

Reusable CI/CD templates for integrating autoSDLC into your GitLab, GitHub, or Azure DevOps projects.

## What is autoSDLC?

autoSDLC is an autonomous software development lifecycle platform that integrates with your SCM (GitLab, GitHub, Azure DevOps) to automate the entire development process - from requirements to deployment. Think Lovable/v0, but integrated directly into your existing workflow using your issue tracking and git repositories.

## How It Works

1. **Bootstrap** - Initialize your project with a "coming soon" page and full CI/CD pipeline
2. **Plan** - AI researches best practices and creates requirements
3. **Spec** - AI generates design specs and technical specifications  
4. **Task** - AI creates user stories and tasks in your SCM issue tracker
5. **Develop** - AI agents work on tasks, create PRs, and iterate until MVP

All powered by JWT/OIDC authentication - no manual token management required!

## Quick Start

### GitLab

Add to your `.gitlab-ci.yml`:

```yaml
include:
  - project: 'autosdlc/templates'
    ref: main
    file: 
      - '/.gitlab/autosdlc-init.yml'
      - '/.gitlab/autosdlc-analyze.yml'
```

### GitHub

Add to `.github/workflows/autosdlc.yml`:

```yaml
jobs:
  init:
    uses: autosdlc/templates/.github/workflows/autosdlc-init.yml@main
  
  analyze:
    uses: autosdlc/templates/.github/workflows/autosdlc-analyze.yml@main
```

### Azure DevOps

Add to `azure-pipelines.yml`:

```yaml
resources:
  repositories:
    - repository: templates
      type: git
      name: autosdlc/templates

stages:
  - template: .azuredevops/pipelines/autosdlc-init.yml@templates
  - template: .azuredevops/pipelines/autosdlc-analyze.yml@templates
```

That's it! See the `examples/` directory for complete working examples.

## Branch-Based Workflows

autoSDLC uses branches to trigger different workflows:

- **`main`/`master`** - Run `init` to bootstrap new projects (manual trigger)
- **`plan`** - Research best practices, create requirements
- **`spec`** - Generate design specifications and code specs
- **`task`** - Create user stories and tasks in your SCM
- **`develop`** - Work on tasks, create PRs, iterate to completion

## Authentication

All templates use JWT/OIDC tokens automatically:

- **GitLab**: `id_tokens` with audience `https://autosdlc.io`
- **GitHub**: OIDC token via `ACTIONS_ID_TOKEN_REQUEST_TOKEN`
- **Azure DevOps**: `System.AccessToken`

The JWT contains:
- **Instance** - Your SCM instance URL (gitlab.com, github.com, etc.)
- **Owner/Project** - Repository path (org/repo)
- **Branch** - Current branch name
- **User** - Who triggered the pipeline

Combined with the `pipeline-id`, your backend has everything it needs!

## Project Configuration

Create a `.ai/project.json` in your repository:

```json
{
  "name": "My Awesome App",
  "slug": "my-awesome-app",
  "description": "A next-gen application",
  "frontend": "next.js",
  "backend": "golang",
  "app_domain": "myapp.com",
  "state": "init",
  "active": true
}
```

The `init` command will use this to bootstrap your project.

## Templates Structure

```
.gitlab/
  autosdlc-init.yml       # GitLab init template
  autosdlc-analyze.yml    # GitLab analyze template
  includes/
    init.yml              # Legacy include format
    analyze.yml           # Legacy include format

.github/workflows/
  autosdlc-init.yml       # GitHub init workflow
  autosdlc-analyze.yml    # GitHub analyze workflow

.azuredevops/pipelines/
  autosdlc-init.yml       # Azure DevOps init template
  autosdlc-analyze.yml    # Azure DevOps analyze template

examples/
  gitlab/                 # Complete GitLab example
  github/                 # Complete GitHub example
  azuredevops/            # Complete Azure DevOps example
```

## CLI Reference

The templates use the autoSDLC CLI: `ghcr.io/autosdlc/cli:latest`

### Commands

#### `init`
Initialize a new project (main/master branch only)

```bash
autosdlc init \
  --token "$OIDC_TOKEN" \
  --pipeline-id "12345"
```

#### `analyze`
Trigger analysis workflow (plan/spec/task/develop branches)

```bash
autosdlc analyze \
  --token "$OIDC_TOKEN" \
  --pipeline-id "12345"
```

#### `health`
Check API connectivity (no auth required)

```bash
autosdlc health
```

### Global Flags

- `--api` - API endpoint (default: `https://autosdlc.io`)
- `--token` - JWT token from CI/CD platform
- `--verbose` / `-v` - Enable verbose output
- `--json` - Output in JSON format

## Platform-Specific Notes

### GitLab
- Uses `id_tokens` feature (GitLab 15.7+)
- Audience set to `https://autosdlc.io`
- Token available in `$GITLAB_OIDC_TOKEN`
- Pipeline ID in `$CI_PIPELINE_ID`

### GitHub
- Requires `id-token: write` permission
- Token fetched via API call
- Pipeline ID is `${{ github.run_id }}`

### Azure DevOps
- Uses `System.AccessToken`
- No additional setup required
- Pipeline ID is `$(Build.BuildId)`

## Advanced Usage

### Custom API Endpoint

Override the API URL:

```yaml
# GitLab
variables:
  AUTOSDLC_API: "https://api.mycompany.com"

# GitHub
env:
  AUTOSDLC_API: "https://api.mycompany.com"

# Azure DevOps
variables:
  AUTOSDLC_API: 'https://api.mycompany.com'
```

Then pass it to the CLI with `--api`.

### Verbose Output

Enable verbose mode for debugging:

```bash
autosdlc analyze \
  --token "$TOKEN" \
  --pipeline-id "$ID" \
  --verbose
```

## Troubleshooting

### GitLab: Token not available
- Ensure GitLab version is 15.7+
- Check `id_tokens` configuration is correct
- Verify audience matches your API

### GitHub: Token generation fails
- Ensure `id-token: write` permission is set
- Check Actions are enabled in repo settings
- Verify `ACTIONS_ID_TOKEN_REQUEST_TOKEN` is available

### Azure DevOps: Token issues
- Ensure `System.AccessToken` is enabled (default)
- Check build service permissions
- Verify the pool has Docker support

### API Connection Issues
Use the `health` command to test:

```bash
docker run --rm ghcr.io/autosdlc/cli:latest health --api https://autosdlc.io
```

## Documentation

- [autoSDLC Documentation](https://docs.autosdlc.io)
- [CLI Repository](https://github.com/autosdlc/cli)
- [API Documentation](https://api.autosdlc.io/docs)

## Support

- Issues: [github.com/autosdlc/templates/issues](https://github.com/autosdlc/templates/issues)
- Discussions: [github.com/autosdlc/templates/discussions](https://github.com/autosdlc/templates/discussions)

## License

MIT
