Dotfiles
========

Personal zsh / dotfiles setup, bootstrappable on a fresh Linux node **without
root access**. Built on top of [Dotbot][dotbot].

Bootstrap a fresh node
----------------------

Prerequisites: `git`, `gcc`, `make`, `tar` (almost always present on a Linux
server). The pipeline is **idempotent** — re-run it on partial failures and
finished steps are skipped.

```sh
# 1. Clone (the path is up to you; ~/.dotfiles is convention).
git clone <this-repo-url> ~/.dotfiles

# 2. One command does everything: installs zsh, links configs, installs
#    plugins and CLI tools.
bash ~/.dotfiles/setup.sh

# 3. Open a new terminal — bashrc auto-execs into zsh.
#    Or in the current shell:
exec zsh -l
```

That's it. No `scp` from another host, no manual edits required for the
common case.

What `setup.sh` does (all idempotent)
-------------------------------------

| Step | Script | Behaviour |
|---|---|---|
| 1 | `zsh/install_zsh.sh` | If zsh is missing: tries `sudo apt install zsh`; otherwise builds zsh 5.8 from source into `$HOME/.local` (also builds ncurses if dev headers aren't present). Skipped if a zsh is already in `PATH` or at `$PREFIX/bin/zsh`. |
| 2 | `zsh/activate_zsh.sh` | Makes zsh your interactive shell. Tries `chsh` first; without root, falls back to writing an idempotent auto-exec block to `~/.bashrc` between markers. |
| 3 | `./install` (Dotbot) | Symlinks `~/.zshrc → zshrc`, `~/.zsh → zsh/`, `~/.p10k.zsh → p10k.zsh`. Existing symlinks are relinked; existing real files cause Dotbot to error so you don't lose data. |
| 4 | `zsh/install_plugins.sh` | Clones oh-my-zsh, powerlevel10k, zsh-completions/-autosuggestions/-syntax-highlighting/-history-substring-search into `~/.zsh/plugins/`. Skips already-cloned dirs. |
| 5 | `x-cmd/install_x.sh` | Installs the `x-cmd` user-mode package manager and uses it to install `bat`, `eza`, `yazi`, `zoxide` (the CLIs `zsh/aliases.sh` aliases against). Best-effort; failure does not block setup. |

Bashrc → zsh inheritance
------------------------

You don't need a separate config layer for zsh. Your existing `~/.bashrc`
remains the source of truth on each node:

| What's in `~/.bashrc` | How it reaches zsh on the same node |
|---|---|
| `export FOO=bar` (cluster vars, tokens, `NVM_DIR`, ...) | Auto-inherited: bash → `exec zsh` keeps every exported variable. |
| `alias ll='ls -alF'`, `alias cdd='...'`, ... | Replayed by `zshrc` — it greps `^alias` lines from `~/.bashrc` and `eval`s them. |
| NVM init (`source $NVM_DIR/nvm.sh`) | Re-sourced by `zshrc` when `NVM_DIR` is set. |
| Dotfiles auto-launch block (`exec zsh -l`) | Inserted (idempotently) by `zsh/activate_zsh.sh`. |

`~/.zshrc.local` is **optional**: it's only for zsh-only aliases /
functions / overrides that don't make sense in `~/.bashrc`. See
`local.zshrc.template`.

Things you may want to edit
---------------------------

For the common case (clone → bootstrap → use), you don't need to edit
anything in this repo. The list below is for "you want to customise":

| File | When to edit |
|---|---|
| `x-cmd/apps.txt` | Change the user-mode CLI tools installed by `x-cmd`. |
| `brew/brew-linux.txt`, `brew/brew-mac.txt` | Change the apps installed by `brew/install_app.sh` (only if you have root or are on macOS — `setup.sh` does NOT call this by default). |
| `install.conf.yaml` | Add more dotfiles to the symlink list. |
| `zshrc`, `p10k.zsh`, `zsh/aliases.sh` | Tune zsh / prompt / aliases. |
| `~/.zshrc.local` (outside this repo) | Per-host overrides that don't belong in the public repo. |

The dotfiles do **not** hard-code any username or host path: the scripts use
`$HOME` and `$(dirname "$0")`. You can clone the repo to any location, not
just `~/.dotfiles`.

Layout
------

| Path | Role |
|---|---|
| `setup.sh` | Top-level bootstrap, runs all steps below. |
| `install`, `install.conf.yaml`, `dotbot/` | Dotbot driver + link config. |
| `zshrc`, `p10k.zsh`, `zsh/` | Symlinked into `$HOME` by Dotbot. |
| `zsh/install_zsh.sh` | Installs zsh (apt with sudo, or source build into `$HOME/.local`). |
| `zsh/activate_zsh.sh` | Makes zsh the login shell (chsh → bashrc auto-exec fallback). |
| `zsh/install_plugins.sh` | Clones zsh plugins under `~/.zsh/plugins/`. |
| `zsh/aliases.sh` | Sourced by `zshrc`. Aliases that use the CLIs from `x-cmd/apps.txt`. |
| `local.zshrc.template` | Copy to `~/.zshrc.local` for zsh-only overrides. |
| `brew/` | Optional installer for apt / brew apps (needs root on Linux). |
| `x-cmd/` | User-mode CLI installer (no root). |


About this template
-------------------

This is a template repository for bootstrapping your dotfiles with [Dotbot][dotbot].

To get started, you can [create a new repository from this template][template]
(or you can [fork][fork] this repository, if you prefer). You can probably
delete this README and rename your version to something like just `dotfiles`.

In general, you should be using symbolic links for everything, and using git
submodules whenever possible.

To keep submodules at their proper versions, you could include something like
`git submodule update --init --recursive` in your `install.conf.yaml`.

To upgrade your submodules to their latest versions, you could periodically run
`git submodule update --init --remote`.

Inspiration
-----------

If you're looking for inspiration for how to structure your dotfiles or what
kinds of things you can include, you could take a look at some repos using
Dotbot.

* [anishathalye's dotfiles][anishathalye_dotfiles]
* [csivanich's dotfiles][csivanich_dotfiles]
* [m45t3r's dotfiles][m45t3r_dotfiles]
* [alexwh's dotfiles][alexwh_dotfiles]
* [azd325's dotfiles][azd325_dotfiles]
* [wazery's dotfiles][wazery_dotfiles]
* [thirtythreeforty's dotfiles][thirtythreeforty_dotfiles]

And there are about [700 more here][dotbot-users].

If you're using Dotbot and you'd like to include a link to your dotfiles here
as an inspiration to others, please submit a pull request.

License
-------

This software is hereby released into the public domain. That means you can do
whatever you want with it without restriction. See `LICENSE.md` for details.

That being said, I would appreciate it if you could maintain a link back to
Dotbot (or this repository) to help other people discover Dotbot.

[dotbot]: https://github.com/anishathalye/dotbot
[fork]: https://github.com/anishathalye/dotfiles_template/fork
[template]: https://github.com/anishathalye/dotfiles_template/generate
[anishathalye_dotfiles]: https://github.com/anishathalye/dotfiles
[csivanich_dotfiles]: https://github.com/csivanich/dotfiles
[m45t3r_dotfiles]: https://github.com/m45t3r/dotfiles
[alexwh_dotfiles]: https://github.com/alexwh/dotfiles
[azd325_dotfiles]: https://github.com/Azd325/dotfiles
[wazery_dotfiles]: https://github.com/wazery/dotfiles
[thirtythreeforty_dotfiles]: https://github.com/thirtythreeforty/dotfiles
[dotbot-users]: https://github.com/anishathalye/dotbot/wiki/Users
