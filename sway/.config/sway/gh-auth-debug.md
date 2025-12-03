# GitHub Auth Debug Log

## Problem Summary
- `gh auth status` shows logged in as blue-az
- `git push` fails with "Write access to repository not granted" (403)
- Token exists but lacks write permissions

## Current State (2025-12-02)
```
gh auth status shows:
- Logged in to github.com account blue-az
- Git operations protocol: https
- Token: github_pat_11AHUQCKQ0HYWxCeV7AlkS_***
```

## History
- Previously had issues with web access, used token instead
- Token hasn't expired
- Token was created with insufficient scopes (missing repo write)

## Attempted Fixes

### Session 1 (2025-12-02)
1. `gh auth setup-git` - didn't help
2. `gh auth refresh -s repo` - needs interactive terminal

## To Fix
Run in terminal:
```
gh auth refresh -h github.com -s repo
```
This will add the `repo` scope which includes write access.

Alternative: Create new token at https://github.com/settings/tokens with `repo` scope, then:
```
gh auth login --with-token < token-file
```

## Notes
- The original token was likely created with read-only or limited scopes
- gh auth status doesn't show which scopes the token has
- 403 "Write access not granted" specifically means missing repo write scope

## ACTUAL ISSUE FOUND (2025-12-02)

~~The `blue-az/dotfiles` repo DOES NOT EXIST on GitHub!~~ WRONG

The repo is **PRIVATE**. The token lacks `repo` scope so it can't see private repos.

```
gh repo list blue-az  # only shows PUBLIC repos (25), dotfiles is private
gh api repos/blue-az/dotfiles  # returns 404 because token can't see private
```

### The loop:
1. Token created with limited scope
2. Works for public repos
3. Fails for private repos
4. User told to refresh token
5. Something happens, maybe works once
6. Repeat

### To actually fix:
Token needs `repo` scope. Run in terminal:
```
gh auth refresh -h github.com -s repo
```

Or edit the token at https://github.com/settings/tokens and add `repo` scope.

## Session 1 - Possible Corruption (2025-12-02 ~19:50)

**Pattern reported by user:**
- Token works initially after creation
- Stops working hours later
- Never happens on desktop, only this laptop
- Has created 3 tokens already

**What agent did that may have corrupted:**
1. User pasted token in chat
2. Agent ran: `echo "<token>" | gh auth login --with-token`

**Hypothesis:**
Running `gh auth login --with-token` or exposing token in commands may invalidate it somehow. Or agent actions trigger rate limiting / security lockout.

**TODO:**
- Next time, don't ask user to paste token
- Don't run gh auth login with the token
- Test if token works on desktop but not laptop at same time
