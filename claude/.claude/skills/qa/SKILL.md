---
name: qa
description: "Run agent-browser QA verification on a URL or app - checks console errors, takes snapshot and screenshot"
argument-hint: "<url-or-app> [page-path] [auth-token]"
allowed-tools: "Bash, Read"
allowed-prompts:
  - tool: Bash
    prompt: "agent-browser"
disable-model-invocation: true
---

Arguments:

- URL or app name: $1 (e.g., "http://localhost:3002", "www", "clerk", "attorney")
- Page path (optional): $2 (e.g., "/pricing", "/dashboard")
- Auth token (optional): $3 (for apps behind login, navigates to /t/<token>?targetUrl=<page> first)

## QA Verification Flow

### 1. Determine Target URL

If `$1` is a full URL (starts with http):

- Use it directly

If `$1` is an app name:

- Check for running dev server on common ports:
  ```bash
  lsof -i :3000 -i :3001 -i :3002 -i :3003 -i :5173 2>/dev/null | grep LISTEN
  ```
- Common app ports:
  - www: 3000
  - attorney: 3000
  - clerk: 3003
  - customer-hub: 5173
- If not running, start it and track PID:
  ```bash
  pnpm dev:<app> > /tmp/<app>-dev.log 2>&1 &
  DEV_SERVER_PID=$!
  sleep 10
  ```
- Construct URL: `http://localhost:<port>$2`

### 2. Authenticate (if token provided)

If `$3` (auth token) is provided:

```bash
# Navigate to token login page with target URL
agent-browser open "<base-url>/t/$3?targetUrl=$2"

# Wait for redirect to complete (login + redirect takes a moment)
agent-browser wait 3000
```

The `/t/<token>` endpoint validates the token, saves it to cookie, and redirects to `targetUrl`.

### 3. Open Page and Check Health

If auth token was NOT provided:

```bash
agent-browser open <url>
```

If auth token WAS provided:

- The page should already be loaded from the redirect
- Verify with `agent-browser get url` that we're on the expected page

### 4. Check Console Errors (CRITICAL)

```bash
agent-browser errors
agent-browser console
```

**Report findings:**

- If errors exist: List them clearly, note if they may be related to recent changes
- If warnings exist: List significant ones (ignore common dev warnings like React DevTools)
- If clean: Confirm "No console errors or warnings"

### 5. Take Accessibility Snapshot

```bash
agent-browser snapshot -i -c
```

Report key interactive elements found.

### 6. Take Screenshot

```bash
agent-browser screenshot /tmp/qa-<app>-<timestamp>.png
```

Read and display the screenshot.

### 7. Summary Report

Provide a brief QA report:

```
## QA Report: <url>

**Console:** ✓ Clean / ⚠ Warnings / ✗ Errors
**Page Load:** ✓ Success / ✗ Failed
**Interactive Elements:** <count> found
**Screenshot:** /tmp/qa-<app>-<timestamp>.png

### Issues Found
- [List any errors/warnings]

### Elements Verified
- [Key interactive elements]
```

### 8. Cleanup

**If you started a dev server** (DEV_SERVER_PID is set), stop it:

```bash
kill $DEV_SERVER_PID 2>/dev/null && echo "Stopped dev server (PID: $DEV_SERVER_PID)"
```

**Rules:**

- Only stop servers YOU started in this session
- Never kill pre-existing servers
