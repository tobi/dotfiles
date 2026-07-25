# Dotfiles development principles

These are Tobi's bespoke dotfiles. Optimize for his machines and workflow rather than building a general-purpose dotfiles framework.

## Public repository boundary

- This repository is public. Treat every tracked file and every commit as permanently public.
- Refuse to add secrets, credentials, tokens, private or public keys, proprietary material, internal hostnames, or private infrastructure details.
- Encryption is not permission to commit sensitive material. Encrypted secrets and recipient lists do not belong here.
- Keep machine-local and sensitive configuration outside the checkout, under an appropriate user config or data directory.
- When a requested change would cross this boundary, stop and ask for a public-safe alternative.

## Goals

- Keep the dotfiles simple, legible, and easy to change.
- A single install script should set up a new server or laptop.
- Support Debian, Ubuntu, Arch Linux, and macOS.
- Work in both Bash and Zsh without fuss.
- Launch interactive shells extremely quickly.
- Prefer powerful tools that reduce custom machinery, especially mise.

## Installation

- The supported installation command is always:
  `curl https://raw.githubusercontent.com/tobi/dotfiles/main/install.sh | bash`
- Dotfiles always live at `~/.local/share/dotfiles`; do not introduce another checkout location.
- `install.sh` is the thin entry point for a fresh machine and migrates the legacy `~/dotfiles` location.
- `apply` (`bin/apply`) is the idempotent reconciler for existing machines. It fetches Git updates, updates native packages and Mise tools, and reapplies configuration.
- Shell startup may cheaply detect drift and tell Tobi to run `apply`; it must not perform package or network updates itself.
- Installation, apply, and shell setup must be idempotent.
- Never change the user's login shell automatically.
- Never require Zsh for basic operation; Bash and Zsh must both remain fully supported.
- Put `~/.local/bin` on `PATH` early and exactly once.
- Install mise itself when needed and provide a reliable path to its binary.
- Use mise as the preferred source for runtimes and portable developer tools, including Node, Ruby, and uv.
- Prefer prebuilt Ruby binaries through mise rather than compiling Ruby.
- Use the native package manager for foundational system utilities and tools mise cannot provide cleanly.

## Shell performance

- Treat startup latency as a feature and a regression surface.
- Avoid network, package-manager, filesystem, and subprocess checks during ordinary shell startup whenever possible.
- Do not repeat expensive detection. Detect once, cache or export the result, and reuse it.
- Prefer environment information over probing I/O. If the environment already establishes the OS, shell, host, path, or capability, trust it.
- Keep non-interactive shells silent and cheap.
- Defer optional integrations until they are actually needed when practical.

## Configuration design

- Develop a very small declarative DSL describing the desired system, such as `add_package` and `add_package_mise`.
- Keep DSL operations predictable, idempotent, and easy to inspect.
- Separate declaration from installation: shell startup may report missing tools, while `apply` performs installation and updates.
- Prefer one canonical declaration for each tool and one preferred installation source.
- Avoid abstractions until they remove real repetition or complexity.
- Favor short shell scripts and conventional files over frameworks.

## Portability

- Every shell change should be checked in both Bash and Zsh syntax and behavior.
- Keep OS-specific behavior isolated in vendor files or package backends.
- Do not assume GNU and BSD utilities have identical flags.
- Avoid machine-local paths except for deliberate conventions under `$HOME`.
- Local overrides belong outside tracked shared configuration. Secrets and key material must never enter the repository.

## Change discipline

- Preserve existing user configuration unless replacement is an explicit part of installation.
- Do not add dependencies casually.
- Keep setup recoverable: failures should identify the command or package that needs attention.
- Verify shell syntax after edits and test installation changes for idempotency.
- Choose the simplest implementation that serves Tobi's actual workflow.
