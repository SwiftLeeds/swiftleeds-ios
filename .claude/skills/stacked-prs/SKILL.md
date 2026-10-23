---
name: stacked-prs
description: "Use before merging any PR in this repo, or rebasing a PR chain. GitHub's stacked-PR beta routes merges by the stack trunk, not the PR base; this records the safe procedures and the incidents behind them."
---
# Stacked PRs in this repo

The SwiftLeeds repo uses GitHub's stacked-PR beta. On 2026-08-14 it was operated on as if it
were ordinary PRs, which caused a closed PR and two misrouted merges. Read this before touching a PR
chain.

## The one fact that matters

**A stack has a trunk, and the trunk governs where a merge lands. The PR's `baseRefName` does
not.** The REST API happily reports `base: main` for PRs whose merges go to the stack's trunk
branch. Never infer the merge destination from `gh pr view --json baseRefName`.

To see the real trunk: the PR page says "Rebase this stack onto the latest version of `<trunk>`",
or use `gh stack view`.

## Tooling

`gh stack` is an official extension; install it if absent:

```bash
gh extension install github/gh-stack
```

Commands: `gh stack view` (branches, order, PR links), `gh stack merge` (all-or-nothing, cannot
bypass merge requirements), `gh stack sync` (fetch, fast-forward trunk, cascading rebase, push),
`gh stack rebase`, `gh stack unstack`. `gh stack modify`'s drop preserves the local branch and
its PR. Merged, merging or queued PRs cannot be removed from a stack.

## Merging without the extension

Both normal routes refuse (`gh pr merge` and the plain merge REST endpoint). The async endpoint
works but **merges to the stack trunk**:

```bash
gh api -X PUT repos/{o}/{r}/pulls/{n}/merge-async \
  -f merge_method=merge -f merge_action=direct_merge -f sha=<exact headRefOid>
gh api repos/{o}/{r}/pulls/{n}/merge-async/{uuid}   # pending | merged | enqueued | failed
```

Read `sha` from `gh pr view --json headRefOid`. Never reconstruct a full SHA from a short one;
the "head branch was modified" guard is the only thing that stops the wrong commit merging.

## Never delete the trunk branch

`gh pr merge --delete-branch` on a trunk deleted it, **closed the child PR unmerged** three
seconds later, and broke the stack (`"Base branch not found"`). The exact fix: the deleted tip is
the second parent of its merge commit on `main` (`git log -1 --format='%p'`); restore with
`git push origin <sha>:refs/heads/<branch>`. Restoring gives the stack its base back, but the
next merge then routes into the restored trunk, not `main`.

**Delete branches only after the entire stack has landed, never as merge-time tidy-up.** The root
cause of the incident: acting on an inferred model (a plain linear chain) instead of verifying
the mechanism, then routing around the system's own correction ("must be merged using the
asynchronous merge REST API" was a model correction, not a detour).

## Rebasing a stacked chain

From rebasing the nine-branch chain on 2026-08-13:

1. **Back up first, always:** `git update-ref refs/backup/<branch> origin/<branch>` for every
   branch before touching anything. Without the parent's backup you cannot compute what to
   replay.
2. **The verification bar:** after every single rebase,
   `git diff --stat refs/backup/<branch> <branch>` must show only the files you intended to
   change. This objective check caught a resolution that merged cleanly but was wrong.
3. **GitHub's PR commit count is wrong after a parent rebase** (reported 32, real 5): the
   parent's pre-rebase commits look unique to the child. Never derive `HEAD~N` from it.
4. **Recovering a lost old-parent tip:** find the commit in the child's history whose subject
   matches the new parent's tip subject, then `git rebase --onto <new-parent> <that-commit>`.
5. **A branch that merged its parent cannot be rebased cleanly** once the parent is rewritten:
   every file the parent introduced becomes an add/add conflict. Plain rebase, `--rebase-merges`
   and a fresh merge all fail.
6. **`git merge -X ours` merges cleanly and lies.** It resolves conflicting hunks in our favour
   but still takes non-conflicting changes from the other side; here it resurrected four deleted
   files. It passed "no conflicts" and failed the tree check.

The resolution that worked for a merged branch (keep the branch's own tree, take one file):

```bash
git checkout -B <branch> refs/backup/<branch>
git merge --no-commit --no-ff <new-parent>        # will conflict; ignore
git read-tree --reset -u refs/backup/<branch>      # tree back to the branch's own content
git checkout <new-parent> -- <the-one-file-you-want>
git commit --no-edit                               # MERGE_HEAD survives, so this is a real merge
```

The PR then shows a correct diff but a noisy commit list; review the Files changed tab.

## Pushing and CI

- Push with `git push --force-with-lease=<branch>:<expected-sha> origin <branch>:<branch>`,
  passing the backup SHA explicitly. Bare `--force-with-lease` trusts the local tracking ref,
  which is weaker.
- **CI does not follow `main`.** A `pull_request` workflow runs from the merge of head into base,
  so fixing a workflow on `main` does nothing for a stacked PR until the branches contain the
  fix. Rebasing is what propagates it.
