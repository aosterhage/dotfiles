# dotfiles
dotfiles is a colleciton of my dotfiles which are intended to be used from a bare git repository.

## What is a "bare" git repo?
From [the Git manual](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server):

> a repository that doesn’t contain a working directory.

This means that there is no *requirement* to `git clone` into `$HOME`; the `.git` directory can live anywhere while the actual repository files can exist in `$HOME`.
For example, if its desired that the `.git` directory live in `$HOME/.dotfiles` then this becomes the `git` command when interacting with the bare repository:

```
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME
```

In order to clone this repo:

```
git clone --bare <URL> $HOME/.dotfiles/
```

and then the repo files can be checked-out via the above mentioned `git` options:

```
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull
```
