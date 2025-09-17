# Task Master AI - Claude Code Integration Guide

## Essential Commands

### Core Workflow Commands

```bash
# Project Setup
task-master init                                    # Initialize Task Master in current project
task-master parse-prd .taskmaster/docs/prd.txt      # Generate tasks from PRD document
task-master models --setup                        # Configure AI models interactively

# Daily Development Workflow
task-master list                                   # Show all tasks with status
task-master next                                   # Get next available task to work on
task-master show <id>                             # View detailed task information (e.g., task-master show 1.2)
task-master set-status --id=<id> --status=done    # Mark task complete

# Task Management
task-master add-task --prompt="description" --research        # Add new task with AI assistance
task-master expand --id=<id> --research --force              # Break task into subtasks
task-master update-task --id=<id> --prompt="changes"         # Update specific task
task-master update --from=<id> --prompt="changes"            # Update multiple tasks from ID onwards
task-master update-subtask --id=<id> --prompt="notes"        # Add implementation notes to subtask

# Analysis & Planning
task-master analyze-complexity --research          # Analyze task complexity
task-master complexity-report                      # View complexity analysis
task-master expand --all --research               # Expand all eligible tasks

# Dependencies & Organization
task-master add-dependency --id=<id> --depends-on=<id>       # Add task dependency
task-master move --from=<id> --to=<id>                       # Reorganize task hierarchy
task-master validate-dependencies                            # Check for dependency issues
task-master generate                                         # Update task markdown files (usually auto-called)
```

## Key Files & Project Structure

### Core Files

- `.taskmaster/tasks/tasks.json` - Main task data file (auto-managed)
- `.taskmaster/config.json` - AI model configuration (use `task-master models` to modify)
- `.taskmaster/docs/prd.txt` - Product Requirements Document for parsing
- `.taskmaster/tasks/*.txt` - Individual task files (auto-generated from tasks.json)
- `.env` - API keys for CLI usage

### Claude Code Integration Files

- `CLAUDE.md` - Auto-loaded context for Claude Code (this file)
- `.claude/settings.json` - Claude Code tool allowlist and preferences
- `.claude/commands/` - Custom slash commands for repeated workflows
- `.mcp.json` - MCP server configuration (project-specific)

### Directory Structure

```
project/
├── .taskmaster/
│   ├── tasks/              # Task files directory
│   │   ├── tasks.json      # Main task database
│   │   ├── task-1.md      # Individual task files
│   │   └── task-2.md
│   ├── docs/              # Documentation directory
│   │   ├── prd.txt        # Product requirements
│   ├── reports/           # Analysis reports directory
│   │   └── task-complexity-report.json
│   ├── templates/         # Template files
│   │   └── example_prd.txt  # Example PRD template
│   └── config.json        # AI models & settings
├── .claude/
│   ├── settings.json      # Claude Code configuration
│   └── commands/         # Custom slash commands
├── .env                  # API keys
├── .mcp.json            # MCP configuration
└── CLAUDE.md            # This file - auto-loaded by Claude Code
```

## MCP Integration

Task Master provides an MCP server that Claude Code can connect to. Configure in `.mcp.json`:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "your_key_here",
        "PERPLEXITY_API_KEY": "your_key_here",
        "OPENAI_API_KEY": "OPENAI_API_KEY_HERE",
        "GOOGLE_API_KEY": "GOOGLE_API_KEY_HERE",
        "XAI_API_KEY": "XAI_API_KEY_HERE",
        "OPENROUTER_API_KEY": "OPENROUTER_API_KEY_HERE",
        "MISTRAL_API_KEY": "MISTRAL_API_KEY_HERE",
        "AZURE_OPENAI_API_KEY": "AZURE_OPENAI_API_KEY_HERE",
        "OLLAMA_API_KEY": "OLLAMA_API_KEY_HERE"
      }
    }
  }
}
```

### Essential MCP Tools

```javascript
help; // = shows available taskmaster commands
// Project setup
initialize_project; // = task-master init
parse_prd; // = task-master parse-prd

// Daily workflow
get_tasks; // = task-master list
next_task; // = task-master next
get_task; // = task-master show <id>
set_task_status; // = task-master set-status

// Task management
add_task; // = task-master add-task
expand_task; // = task-master expand
update_task; // = task-master update-task
update_subtask; // = task-master update-subtask
update; // = task-master update

// Analysis
analyze_project_complexity; // = task-master analyze-complexity
complexity_report; // = task-master complexity-report
```

## Claude Code Workflow Integration

### Standard Development Workflow

#### 1. Project Initialization

```bash
# Initialize Task Master
task-master init

# Create or obtain PRD, then parse it
task-master parse-prd .taskmaster/docs/prd.txt

# Analyze complexity and expand tasks
task-master analyze-complexity --research
task-master expand --all --research
```

If tasks already exist, another PRD can be parsed (with new information only!) using parse-prd with --append flag. This will add the generated tasks to the existing list of tasks..

#### 2. Daily Development Loop

```bash
# Start each session
task-master next                           # Find next available task
task-master show <id>                     # Review task details

# During implementation, check in code context into the tasks and subtasks
task-master update-subtask --id=<id> --prompt="implementation notes..."

# Complete tasks
task-master set-status --id=<id> --status=done
```

#### 3. Multi-Claude Workflows

For complex projects, use multiple Claude Code sessions:

```bash
# Terminal 1: Main implementation
cd project && claude

# Terminal 2: Testing and validation
cd project-test-worktree && claude

# Terminal 3: Documentation updates
cd project-docs-worktree && claude
```

### Custom Slash Commands

Create `.claude/commands/taskmaster-next.md`:

```markdown
Find the next available Task Master task and show its details.

Steps:

1. Run `task-master next` to get the next task
2. If a task is available, run `task-master show <id>` for full details
3. Provide a summary of what needs to be implemented
4. Suggest the first implementation step
```

Create `.claude/commands/taskmaster-complete.md`:

```markdown
Complete a Task Master task: $ARGUMENTS

Steps:

1. Review the current task with `task-master show $ARGUMENTS`
2. Verify all implementation is complete
3. Run any tests related to this task
4. Mark as complete: `task-master set-status --id=$ARGUMENTS --status=done`
5. Show the next available task with `task-master next`
```

## Tool Allowlist Recommendations

Add to `.claude/settings.json`:

```json
{
  "allowedTools": [
    "Edit",
    "Bash(task-master *)",
    "Bash(git commit:*)",
    "Bash(git add:*)",
    "Bash(npm run *)",
    "mcp__task_master_ai__*"
  ]
}
```

## Configuration & Setup

### API Keys Required

At least **one** of these API keys must be configured:

- `ANTHROPIC_API_KEY` (Claude models) - **Recommended**
- `PERPLEXITY_API_KEY` (Research features) - **Highly recommended**
- `OPENAI_API_KEY` (GPT models)
- `GOOGLE_API_KEY` (Gemini models)
- `MISTRAL_API_KEY` (Mistral models)
- `OPENROUTER_API_KEY` (Multiple models)
- `XAI_API_KEY` (Grok models)

An API key is required for any provider used across any of the 3 roles defined in the `models` command.

### Model Configuration

```bash
# Interactive setup (recommended)
task-master models --setup

# Set specific models
task-master models --set-main claude-3-5-sonnet-20241022
task-master models --set-research perplexity-llama-3.1-sonar-large-128k-online
task-master models --set-fallback gpt-4o-mini
```

## Task Structure & IDs

### Task ID Format

- Main tasks: `1`, `2`, `3`, etc.
- Subtasks: `1.1`, `1.2`, `2.1`, etc.
- Sub-subtasks: `1.1.1`, `1.1.2`, etc.

### Task Status Values

- `pending` - Ready to work on
- `in-progress` - Currently being worked on
- `done` - Completed and verified
- `deferred` - Postponed
- `cancelled` - No longer needed
- `blocked` - Waiting on external factors

### Task Fields

```json
{
  "id": "1.2",
  "title": "Implement user authentication",
  "description": "Set up JWT-based auth system",
  "status": "pending",
  "priority": "high",
  "dependencies": ["1.1"],
  "details": "Use bcrypt for hashing, JWT for tokens...",
  "testStrategy": "Unit tests for auth functions, integration tests for login flow",
  "subtasks": []
}
```

## Claude Code Best Practices with Task Master

### Context Management

- Use `/clear` between different tasks to maintain focus
- This CLAUDE.md file is automatically loaded for context
- Use `task-master show <id>` to pull specific task context when needed

### Iterative Implementation

1. `task-master show <subtask-id>` - Understand requirements
2. Explore codebase and plan implementation
3. `task-master update-subtask --id=<id> --prompt="detailed plan"` - Log plan
4. `task-master set-status --id=<id> --status=in-progress` - Start work
5. Implement code following logged plan
6. `task-master update-subtask --id=<id> --prompt="what worked/didn't work"` - Log progress
7. `task-master set-status --id=<id> --status=done` - Complete task

### Complex Workflows with Checklists

For large migrations or multi-step processes:

1. Create a markdown PRD file describing the new changes: `touch task-migration-checklist.md` (prds can be .txt or .md)
2. Use Taskmaster to parse the new prd with `task-master parse-prd --append` (also available in MCP)
3. Use Taskmaster to expand the newly generated tasks into subtasks. Consdier using `analyze-complexity` with the correct --to and --from IDs (the new ids) to identify the ideal subtask amounts for each task. Then expand them.
4. Work through items systematically, checking them off as completed
5. Use `task-master update-subtask` to log progress on each task/subtask and/or updating/researching them before/during implementation if getting stuck

### Git Integration

Task Master works well with `gh` CLI:

```bash
# Create PR for completed task
gh pr create --title "Complete task 1.2: User authentication" --body "Implements JWT auth system as specified in task 1.2"

# Reference task in commits
git commit -m "feat: implement JWT auth (task 1.2)"
```

### Parallel Development with Git Worktrees

```bash
# Create worktrees for parallel task development
git worktree add ../project-auth feature/auth-system
git worktree add ../project-api feature/api-refactor

# Run Claude Code in each worktree
cd ../project-auth && claude    # Terminal 1: Auth work
cd ../project-api && claude     # Terminal 2: API work
```

## Troubleshooting

### AI Commands Failing

```bash
# Check API keys are configured
cat .env                           # For CLI usage

# Verify model configuration
task-master models

# Test with different model
task-master models --set-fallback gpt-4o-mini
```

### MCP Connection Issues

- Check `.mcp.json` configuration
- Verify Node.js installation
- Use `--mcp-debug` flag when starting Claude Code
- Use CLI as fallback if MCP unavailable

### Task File Sync Issues

```bash
# Regenerate task files from tasks.json
task-master generate

# Fix dependency issues
task-master fix-dependencies
```

DO NOT RE-INITIALIZE. That will not do anything beyond re-adding the same Taskmaster core files.

## Important Notes

### AI-Powered Operations

These commands make AI calls and may take up to a minute:

- `parse_prd` / `task-master parse-prd`
- `analyze_project_complexity` / `task-master analyze-complexity`
- `expand_task` / `task-master expand`
- `expand_all` / `task-master expand --all`
- `add_task` / `task-master add-task`
- `update` / `task-master update`
- `update_task` / `task-master update-task`
- `update_subtask` / `task-master update-subtask`

### File Management

- Never manually edit `tasks.json` - use commands instead
- Never manually edit `.taskmaster/config.json` - use `task-master models`
- Task markdown files in `tasks/` are auto-generated
- Run `task-master generate` after manual changes to tasks.json

### Claude Code Session Management

- Use `/clear` frequently to maintain focused context
- Create custom slash commands for repeated Task Master workflows
- Configure tool allowlist to streamline permissions
- Use headless mode for automation: `claude -p "task-master next"`

### Multi-Task Updates

- Use `update --from=<id>` to update multiple future tasks
- Use `update-task --id=<id>` for single task updates
- Use `update-subtask --id=<id>` for implementation logging

### Research Mode

- Add `--research` flag for research-based AI enhancement
- Requires a research model API key like Perplexity (`PERPLEXITY_API_KEY`) in environment
- Provides more informed task creation and updates
- Recommended for complex technical tasks

---

_This guide ensures Claude Code has immediate access to Task Master's essential functionality for agentic development workflows._

## Recent Session Work (August 25, 2025)

### Venue-Based Content Filtering & Localization

#### Completed Features:
1. **Welcome Popup with Venue Selection**
   - Added venue selection popup that appears on first visit
   - Options: Malaysia, Singapore, Korea, or All Events
   - Language selection integrated with existing LocaleProvider
   - URL persistence with query parameters (e.g., `?ln=ko&venue=sg`)

2. **Venue-Based Content Filtering**
   - Event tickets filter based on selected venue
   - Location/directions section shows only selected venue
   - Journey section displays all venues but highlights selected ones
   - Bookmark navigation only enables selected venues
   - Banking section hidden for Singapore/Malaysia venues

3. **Complete Localization of Location Section**
   - Fixed hardcoded Korean text in navigation app names
   - Made location titles dynamic based on selected language
   - Translated venue names and addresses
   - Added localization keys for:
     - `navigationApps`: Navigation app section title
     - `kakaoNavi`, `naverMap`, `tmap`: Navigation app names

#### Key Files Modified:
- `lib/presentation/widgets/welcome_selection_popup.dart` - Bilingual venue selection
- `lib/providers/venue_provider.dart` - Venue state management
- `lib/presentation/screens/home/home_screen.dart` - Venue filtering logic
- `lib/l10n/*.arb` - Localization files for all supported languages

#### TaskMaster Updates:
- Task #20: Welcome Popup Implementation (✓ done)
- Task #21: Banking Account Update (✓ done)
- Task #22: Venue Content Filtering (✓ done)
- Task #23: Hide Banking for SG/MY (✓ done)
- Task #24: Bilingual Welcome Popup (✓ done)
- Task #25: Fix Location Section Localization (✓ done)

---

# Vercel Deployment Guide for Flutter Wedding Invitation

## Environment Variables Configuration

### Required Environment Variables
The following environment variables must be configured in Vercel for proper functionality:

```bash
SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w
NAVER_MAPS_CLIENT_ID=judjrcgb97
GOOGLE_MAPS_API_KEY=AIzaSyDYtu2Bu-VPXsA3z5sWaENXOqa-B-m8vxM
```

### Vercel Environment Variables Management

```bash
# Add environment variables to production
vercel env add SUPABASE_URL production <<< "https://otksynthwanpqpkdttzv.supabase.co"
vercel env add SUPABASE_ANON_KEY production <<< "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w"
vercel env add NAVER_MAPS_CLIENT_ID production <<< "judjrcgb97"
vercel env add GOOGLE_MAPS_API_KEY production <<< "AIzaSyDYtu2Bu-VPXsA3z5sWaENXOqa-B-m8vxM"

# Remove environment variables (if needed)
echo "y" | vercel env rm SUPABASE_URL production
echo "y" | vercel env rm SUPABASE_ANON_KEY production

# List current environment variables
vercel env ls
```

## Flutter Web Build Process

### Standard Build Command
**CRITICAL**: Always use dart-define parameters when building for web deployment to ensure Supabase integration works:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w
```

### Clean Build Process
When experiencing deployment issues:

```bash
# Clean Flutter cache
flutter clean

# Rebuild with environment variables
flutter build web --release \
  --dart-define=SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w
```

## Application Features

### URL Parameters
- **Language**: `?ln=ko` (Korean), `?ln=en` (English), `?ln=ms` (Malay), `?ln=zh` (Chinese)
- **Venue**: `?venue=my|sg|ko|all` (Malaysia, Singapore, Korea, All Events)
- **Parents Mode**: `?parents=true` (Larger fonts, Malaysia focus)

### Test URLs
```
Normal Mode: https://www.daegyu.dev/invitation/#/?ln=ko&venue=all
Parents Mode: https://www.daegyu.dev/invitation/#/?ln=ko&venue=all&parents=true
```

### Social Media Preview
- **Open Graph Image**: `M04.04_sky_field_portrait.webp` - Sky field portrait for social sharing
- **Image Dimensions**: 1200x1800 (portrait orientation)
- **Location**: `/web/M04.04_sky_field_portrait.webp`

### Parents Mode Features
- **Font Size**: All text increased by 30% for better readability
- **Venue Focus**: Forces Malaysia venue selection
- **Implementation**: Controlled by `VenueProvider.isParentsMode` flag
- **Theme Override**: Applied in `main.dart` using `Consumer2<LocaleProvider, VenueProvider>`

## Complete Deployment Workflow

```bash
# 1. Clean and rebuild
flutter clean
flutter build web --release \
  --dart-define=SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w

# 2. Verify environment variables in Vercel
vercel env ls

# 3. Deploy to production
vercel --prod

# 4. Test deployment
# Open: https://www.daegyu.dev/invitation/#/?ln=ko&venue=all&parents=true
```

---

# CRITICAL: Flutter Web Optimization for Emoji & Bundle Size

## Problem: After `flutter clean`, emoji and bundle size issues occur

### Issues That Happen After `flutter clean`:
1. **Emoji rendering**: Color emojis become black and white
2. **Bundle size explosion**: From ~8.8MB to 27MB (18MB+ unnecessary canvaskit files)
3. **Service worker bloat**: From 12KB to 19.8MB
4. **Upload inefficiency**: Vercel uploads grow from <1MB to 45MB

## MANDATORY Solution Steps

### Step 1: Always Use HTML Renderer
**CRITICAL**: Use `--web-renderer html` (NOT canvaskit) for proper emoji support

### Step 2: Remove Canvaskit Files After Build
**CRITICAL**: Always run `rm -rf build/web/canvaskit/` after building with HTML renderer

### Step 3: Use Deployment Script
**ALWAYS use**: `./scripts/build-for-deployment.sh` - this script has the optimizations built-in

## Correct Build Process

```bash
# 1. Clean build with optimization script
./scripts/build-for-deployment.sh

# 2. Verify optimization worked
du -sh build/web                           # Should show ~8.8M (not 27M)
ls -lh build/web/flutter_service_worker.js # Should show ~12K (not 19.8M)

# 3. Deploy optimized build
npx vercel --prod
```

## Build Script Requirements

The `scripts/build-for-deployment.sh` MUST contain:

```bash
# Build with HTML renderer (for emoji support)
flutter build web --release \
  --dart-define=SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w \
  --web-renderer html

# Remove canvaskit files to reduce size from 27MB to 8.8MB
rm -rf build/web/canvaskit/
```

## Expected Results After Optimization:
- ✅ **Bundle size**: 8.8MB (67% reduction from 27MB)
- ✅ **Service worker**: 12KB (99.94% reduction from 19.8MB)
- ✅ **Upload size**: <1MB (98% reduction from 45MB)
- ✅ **Emoji**: Full color support (fixed from black/white)

## Quick Fix Verification:
```bash
# After running build script, verify:
echo "Bundle size: $(du -sh build/web | cut -f1)"
echo "Service worker: $(ls -lh build/web/flutter_service_worker.js | awk '{print $5}')"
echo "Canvaskit removed: $([ ! -d build/web/canvaskit ] && echo 'YES' || echo 'NO')"
```

**Reference**: See `FLUTTER_WEB_OPTIMIZATION_GUIDE.md` for detailed explanation.

---

# CRITICAL: Flutter Web Cache Reset Guide

## Problem: Users See Old Version After Deployment

When users (especially on mobile) see old cached versions after deployment, follow this guide.

## Quick Fix Process

### 1. Update Version in index.html (BOTH places!)

```bash
# Generate new timestamp
date +%s  # e.g., 1757589083
```

Update in `web/index.html`:
```html
<!-- Meta tag version -->
<meta name="version" content="v2.4.0-cache-buster-1757589083">

<!-- JavaScript version (MUST MATCH!) -->
<script>
  const currentVersion = 'v2.4.0-cache-buster-1757589083';
</script>
```

### 2. Build and Deploy

```bash
# Clean build with optimization
./scripts/build-for-deployment.sh

# Deploy to production
npx vercel --prod
```

### 3. User Instructions for Cache Clear

**Automatic Update**: Wait 1 minute (service worker auto-updates)

**Quick Fix**: Add `?v=2` to URL:
```
https://www.daegyu.dev/invitation/?v=2
```

**Manual Clear (Mobile)**:
- **iOS Safari**: Settings → Safari → Clear History and Website Data
- **Android Chrome**: Settings → Privacy → Clear browsing data → Cached images

## Key Implementation Details

### Version Check Script (in index.html)
```javascript
(function() {
  const currentVersion = 'v2.4.0-cache-buster-1757589083';
  const lastVersion = localStorage.getItem('app-version');
  
  if (lastVersion && lastVersion !== currentVersion) {
    // Clear caches and reload
    caches.keys().then(names => 
      Promise.all(names.map(name => caches.delete(name)))
    ).then(() => {
      localStorage.setItem('app-version', currentVersion);
      window.location.reload(true);
    });
  }
})();
```

### Service Worker Force Update (in index.html)
```javascript
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.ready.then(registration => {
    registration.update();
  });
  
  // Check every minute
  setInterval(() => {
    navigator.serviceWorker.controller?.postMessage('skipWaiting');
  }, 60000);
}
```

## IMPORTANT REMINDERS

1. **ALWAYS UPDATE BOTH VERSION STRINGS** (meta tag AND JavaScript)
2. **Version format**: `v{major}.{minor}.{patch}-cache-buster-{timestamp}`
3. **Test in incognito first** before telling users to clear cache
4. **Mobile browsers cache more aggressively** than desktop

**Full Guide**: See `CACHE_RESET_GUIDE.md` for complete documentation.

---
