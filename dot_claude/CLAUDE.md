# Git Commits

Always use Conventional Commits format: https://www.conventionalcommits.org/en/v1.0.0/

Structure: `<type>[optional scope]: <description>`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

- Breaking changes: append `!` after type/scope, or add `BREAKING CHANGE:` footer
- Body and footers are optional but use them when the why is non-obvious
- Description is lowercase, imperative mood, no period at end

Examples:
```
feat(auth): add OAuth2 login support
fix: prevent race condition in user creation
refactor!: drop support for Node 12
```

# gstack

Use the `/browse` skill from gstack for all web browsing. Never use `mcp__claude-in-chrome__*` tools.

Available gstack skills:
`/office-hours`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/design-consultation`, `/design-shotgun`, `/design-html`, `/review`, `/ship`, `/land-and-deploy`, `/canary`, `/benchmark`, `/browse`, `/connect-chrome`, `/qa`, `/qa-only`, `/design-review`, `/setup-browser-cookies`, `/setup-deploy`, `/retro`, `/investigate`, `/document-release`, `/codex`, `/cso`, `/autoplan`, `/plan-devex-review`, `/devex-review`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, `/gstack-upgrade`, `/learn`
