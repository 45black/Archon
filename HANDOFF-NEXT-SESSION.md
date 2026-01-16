# Session Handover: Archon - 2026-01-11

## What Was Done
- Created ResearchAgent with PydanticAI (RAG, code search, web fetch)
- Configured Doppler integration for API keys
- Crawled snarktank GitHub (103k words indexed)
- Discovered Docker env override issue

## What's Next
- [ ] Fix Docker startup (unset OPENAI_API_KEY=ROTATE_ME from shell)
- [ ] Crawl specific snarktank repos (ai-dev-tasks, amp-skills, code-editing-agent, context7)
- [ ] Integrate ResearchAgent into MCP server as `research_agent_query` tool
- [ ] Wire up Agent Chat API to use ResearchAgent

## Key Learnings
- **Docker Env Override**: Shell vars override .env in Docker Compose. Use `env -u VAR docker compose up`
- **Doppler Suffix Pattern**: Doppler has `OPENAI_API_KEY_MAIN` not `OPENAI_API_KEY` - added alias

## Files Modified
- `python/src/agents/research_agent.py` - NEW: Full PydanticAI agent
- `python/src/agents/__init__.py` - Added ResearchAgent export
- `python/.doppler.yaml` - NEW: Links to shared/dev

## Commands to Resume
```bash
cd /Users/willscrump/Projects/infrastructure/archon

# Fix Docker startup
unset OPENAI_API_KEY
docker compose up -d

# Test ResearchAgent locally
cd python
doppler run -- uv run python -m src.agents.research_agent

# Crawl snarktank repos
for repo in ai-dev-tasks amp-skills code-editing-agent context7; do
  curl -X POST "http://localhost:8181/api/knowledge-items/crawl" \
    -H "Content-Type: application/json" \
    -d "{\"url\":\"https://github.com/snarktank/$repo\",\"max_depth\":2}"
done
```

## Open Questions
- Which skill integration for ResearchAgent? (MCP tool recommended)
- Should snarktank be a dedicated knowledge source or merged?
