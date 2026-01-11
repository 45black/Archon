"""
Research Agent - Comprehensive AI Assistant with RAG, Code Search, and Web Research

This agent combines multiple capabilities:
- RAG search through Archon knowledge base
- Code example search
- Web search and fetch (via built-in tools)
- General conversation and reasoning
"""

import asyncio
import logging
import os
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any

import httpx
from pydantic import BaseModel, Field
from pydantic_ai import Agent, RunContext

from .base_agent import ArchonDependencies, BaseAgent

logger = logging.getLogger(__name__)

# Archon API base URL
ARCHON_API_URL = os.getenv("ARCHON_API_URL", "http://localhost:8181")


@dataclass
class ResearchDependencies(ArchonDependencies):
    """Dependencies for research operations."""

    source_filter: str | None = None
    match_count: int = 5
    enable_web_search: bool = True
    conversation_history: list[dict[str, str]] = field(default_factory=list)


class ResearchResult(BaseModel):
    """Structured output for research results."""

    query: str = Field(description="The original user query")
    sources_used: list[str] = Field(description="List of sources consulted")
    answer: str = Field(description="The synthesized answer")
    citations: list[dict[str, Any]] = Field(default_factory=list, description="Citations with URLs")
    confidence: str = Field(description="Confidence level: high, medium, low")


class ResearchAgent(BaseAgent[ResearchDependencies, str]):
    """
    Comprehensive research agent with RAG, code search, and web capabilities.

    Capabilities:
    - Search Archon knowledge base (documentation, tutorials, etc.)
    - Find code examples from crawled sources
    - Perform web searches for current information
    - Fetch and analyze web pages
    - Synthesize information from multiple sources
    """

    def __init__(self, model: str | None = None, **kwargs):
        resolved_model = model or os.getenv("RESEARCH_AGENT_MODEL", "openai:gpt-4o-mini")

        super().__init__(
            model=resolved_model,
            name="ResearchAgent",
            retries=3,
            enable_rate_limiting=True,
            **kwargs,
        )

    def _create_agent(self, **kwargs) -> Agent:
        """Create the PydanticAI agent with all tools and prompts."""

        agent = Agent(
            model=self.model,
            deps_type=ResearchDependencies,
            system_prompt=self.get_system_prompt(),
            **kwargs,
        )

        # Register dynamic context
        @agent.system_prompt
        async def add_context(ctx: RunContext[ResearchDependencies]) -> str:
            source_info = (
                f"Source Filter: {ctx.deps.source_filter}"
                if ctx.deps.source_filter
                else "Searching all sources"
            )
            web_info = "Web search enabled" if ctx.deps.enable_web_search else "Web search disabled"
            return f"""
**Current Context:**
- {source_info}
- {web_info}
- Max results per search: {ctx.deps.match_count}
- Timestamp: {datetime.now().isoformat()}
"""

        # RAG Search Tool
        @agent.tool
        async def search_knowledge_base(
            ctx: RunContext[ResearchDependencies],
            query: str,
            source_id: str | None = None,
        ) -> str:
            """
            Search the Archon knowledge base for relevant documentation and content.

            Args:
                query: The search query (natural language)
                source_id: Optional source ID to filter results (use list_sources to see available)

            Returns:
                Formatted search results with content snippets and source URLs
            """
            try:
                async with httpx.AsyncClient(timeout=30.0) as client:
                    payload = {
                        "query": query,
                        "match_count": ctx.deps.match_count,
                    }
                    if source_id or ctx.deps.source_filter:
                        payload["source"] = source_id or ctx.deps.source_filter

                    response = await client.post(
                        f"{ARCHON_API_URL}/api/knowledge-items/search",
                        json=payload,
                    )
                    response.raise_for_status()
                    data = response.json()

                if not data.get("success", True):
                    return f"Search failed: {data.get('error', 'Unknown error')}"

                results = data.get("results", [])
                if not results:
                    return "No results found. Try different search terms or remove source filters."

                formatted = []
                for i, res in enumerate(results[:5], 1):
                    metadata = res.get("metadata", {})
                    url = metadata.get("url", "")
                    title = metadata.get("title", "Untitled")
                    content = res.get("content", "")[:600]
                    score = res.get("rerank_score", res.get("similarity_score", 0))

                    formatted.append(
                        f"**[{i}] {title}**\n"
                        f"URL: {url}\n"
                        f"Relevance: {score:.2f}\n"
                        f"Content: {content}...\n"
                    )

                return f"Found {len(results)} results:\n\n" + "\n---\n".join(formatted)

            except Exception as e:
                logger.error(f"Knowledge base search error: {e}")
                return f"Error searching knowledge base: {str(e)}"

        # Code Examples Search Tool
        @agent.tool
        async def search_code_examples(
            ctx: RunContext[ResearchDependencies],
            query: str,
            source_id: str | None = None,
        ) -> str:
            """
            Search for code examples in the knowledge base.

            Args:
                query: Search query for code (e.g., "FastAPI dependency injection")
                source_id: Optional source ID to filter (e.g., FastAPI docs source)

            Returns:
                Code examples with explanations and source URLs
            """
            try:
                async with httpx.AsyncClient(timeout=30.0) as client:
                    payload = {"query": query, "match_count": ctx.deps.match_count}
                    if source_id or ctx.deps.source_filter:
                        payload["source_id"] = source_id or ctx.deps.source_filter

                    response = await client.post(
                        f"{ARCHON_API_URL}/api/rag/code-examples",
                        json=payload,
                    )
                    response.raise_for_status()
                    data = response.json()

                if not data.get("success", True):
                    return f"Code search failed: {data.get('error', 'Unknown error')}"

                results = data.get("results", [])
                if not results:
                    return "No code examples found. Try different search terms."

                formatted = []
                for i, res in enumerate(results[:5], 1):
                    url = res.get("url", "")
                    code = res.get("code", "")[:800]
                    summary = res.get("summary", "")
                    metadata = res.get("metadata", {})
                    language = metadata.get("language", "")

                    formatted.append(
                        f"**[{i}] {metadata.get('title', 'Code Example')}**\n"
                        f"URL: {url}\n"
                        f"Summary: {summary}\n"
                        f"```{language}\n{code}\n```\n"
                    )

                return f"Found {len(results)} code examples:\n\n" + "\n---\n".join(formatted)

            except Exception as e:
                logger.error(f"Code search error: {e}")
                return f"Error searching code examples: {str(e)}"

        # List Sources Tool
        @agent.tool
        async def list_sources(ctx: RunContext[ResearchDependencies]) -> str:
            """
            List all available knowledge sources that can be searched.

            Returns:
                List of sources with IDs, titles, and word counts
            """
            try:
                async with httpx.AsyncClient(timeout=30.0) as client:
                    response = await client.get(f"{ARCHON_API_URL}/api/rag/sources")
                    response.raise_for_status()
                    data = response.json()

                sources = data.get("sources", [])
                if not sources:
                    return "No sources available. Crawl some documentation first."

                formatted = []
                for src in sources:
                    source_id = src.get("source_id", "")
                    title = src.get("title", "Untitled")
                    words = src.get("total_words", 0)
                    formatted.append(f"- **{source_id}**: {title} ({words:,} words)")

                return f"Available sources ({len(sources)}):\n" + "\n".join(formatted)

            except Exception as e:
                logger.error(f"List sources error: {e}")
                return f"Error listing sources: {str(e)}"

        # Web Fetch Tool
        @agent.tool
        async def fetch_webpage(
            ctx: RunContext[ResearchDependencies],
            url: str,
            extract_prompt: str = "Extract the main content and key information",
        ) -> str:
            """
            Fetch and analyze a webpage.

            Args:
                url: The URL to fetch
                extract_prompt: What to extract from the page

            Returns:
                Extracted content from the webpage
            """
            if not ctx.deps.enable_web_search:
                return "Web fetching is disabled for this session."

            try:
                async with httpx.AsyncClient(timeout=30.0, follow_redirects=True) as client:
                    response = await client.get(url)
                    response.raise_for_status()

                    # Basic HTML to text extraction
                    content = response.text
                    # Remove script and style tags
                    import re

                    content = re.sub(r"<script[^>]*>.*?</script>", "", content, flags=re.DOTALL)
                    content = re.sub(r"<style[^>]*>.*?</style>", "", content, flags=re.DOTALL)
                    content = re.sub(r"<[^>]+>", " ", content)
                    content = re.sub(r"\s+", " ", content).strip()

                    # Truncate if too long
                    if len(content) > 5000:
                        content = content[:5000] + "..."

                    return f"**Content from {url}:**\n\n{content}"

            except Exception as e:
                logger.error(f"Web fetch error: {e}")
                return f"Error fetching {url}: {str(e)}"

        return agent

    def get_system_prompt(self) -> str:
        """Get the system prompt for this agent."""
        return """You are a Research Assistant with access to multiple knowledge sources and tools.

**Your Capabilities:**
1. **Knowledge Base Search** - Search through crawled documentation (FastAPI, PydanticAI, Anthropic, LangChain, Supabase, TanStack, Cole Medin repos, etc.)
2. **Code Examples** - Find relevant code snippets and implementation patterns
3. **Web Fetch** - Retrieve and analyze web pages for current information
4. **Source Discovery** - List available knowledge sources

**Your Approach:**
1. Understand what the user is asking for
2. Choose the appropriate tool(s) to gather information
3. Synthesize information from multiple sources when needed
4. Provide clear, well-structured answers with citations
5. Include code examples when relevant

**Guidelines:**
- Always cite your sources with URLs when available
- If you can't find information, say so clearly
- For code questions, search code examples first
- For conceptual questions, search the knowledge base
- Combine information from multiple searches when needed
- Be concise but thorough

**Available Knowledge Sources:**
Use the `list_sources` tool to see all available documentation that has been indexed."""


# Standalone CLI for testing
async def main():
    """Simple CLI for testing the research agent."""
    print("=" * 60)
    print("Research Agent - Interactive Mode")
    print("=" * 60)
    print("\nCommands:")
    print("  /sources - List available knowledge sources")
    print("  /quit    - Exit the agent")
    print("  /help    - Show this help message")
    print("\nAsk any question about the indexed documentation!\n")

    agent = ResearchAgent()
    deps = ResearchDependencies(
        match_count=5,
        enable_web_search=True,
    )

    while True:
        try:
            user_input = input("\nYou: ").strip()

            if not user_input:
                continue

            if user_input.lower() in ["/quit", "/exit", "/q"]:
                print("Goodbye!")
                break

            if user_input.lower() == "/help":
                print("\nCommands:")
                print("  /sources - List available knowledge sources")
                print("  /quit    - Exit the agent")
                print("  /help    - Show this help message")
                continue

            if user_input.lower() == "/sources":
                user_input = "List all available knowledge sources"

            print("\nAssistant: Thinking...")

            result = await agent.run(user_input, deps)
            print(f"\nAssistant: {result}")

        except KeyboardInterrupt:
            print("\n\nGoodbye!")
            break
        except Exception as e:
            print(f"\nError: {str(e)}")


if __name__ == "__main__":
    asyncio.run(main())
