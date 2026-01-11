"""
Research Agent MCP Tools

Provides AI-powered research capabilities via the ResearchAgent.
Uses HTTP calls to the server's /api/research endpoint.
"""

import json
import logging
import os
from urllib.parse import urljoin

import httpx
from mcp.server.fastmcp import Context, FastMCP

from src.server.config.service_discovery import get_api_url

logger = logging.getLogger(__name__)


def register_research_tools(mcp: FastMCP):
    """Register research agent tools with the MCP server."""

    @mcp.tool()
    async def research_query(
        ctx: Context,
        query: str,
        source_filter: str | None = None,
        match_count: int = 5,
        enable_web_search: bool = False,
    ) -> str:
        """
        Execute an AI-powered research query using the ResearchAgent.

        The agent intelligently:
        - Searches the Archon knowledge base for relevant documentation
        - Finds code examples when applicable
        - Optionally fetches web pages for additional context
        - Synthesizes a comprehensive, cited answer

        This is MORE POWERFUL than raw rag_search_knowledge_base because it:
        - Uses AI reasoning to decide which tools to use
        - Combines multiple searches automatically
        - Provides synthesized answers, not just raw results

        Args:
            query: Your research question (natural language, can be detailed)
                   Example: "How do I implement authentication in FastAPI with JWT tokens?"
            source_filter: Optional source ID to focus search (from rag_get_available_sources)
            match_count: Max results per internal search (default: 5)
            enable_web_search: Allow fetching external web pages (default: False)

        Returns:
            JSON string with structure:
            - success: bool - Operation success status
            - query: str - The original query
            - answer: str - The synthesized research answer
            - error: str|null - Error description if success=false

        Example usage:
            research_query("How do I create a PydanticAI agent with custom tools?")
            research_query("FastAPI dependency injection patterns", source_filter="src_fastapi")
        """
        try:
            api_url = get_api_url()
            timeout = httpx.Timeout(120.0, connect=10.0)  # Longer timeout for AI processing

            async with httpx.AsyncClient(timeout=timeout) as client:
                request_data = {
                    "query": query,
                    "match_count": match_count,
                    "enable_web_search": enable_web_search,
                }
                if source_filter:
                    request_data["source_filter"] = source_filter

                response = await client.post(
                    urljoin(api_url, "/api/research/query"),
                    json=request_data,
                )

                if response.status_code == 200:
                    result = response.json()
                    return json.dumps(
                        {
                            "success": result.get("success", True),
                            "query": result.get("query", query),
                            "answer": result.get("answer", ""),
                            "error": result.get("error"),
                        },
                        indent=2,
                    )
                elif response.status_code == 503:
                    return json.dumps(
                        {
                            "success": False,
                            "query": query,
                            "answer": "",
                            "error": "Research agent unavailable - OpenAI API key not configured",
                        },
                        indent=2,
                    )
                else:
                    error_detail = response.text
                    return json.dumps(
                        {
                            "success": False,
                            "query": query,
                            "answer": "",
                            "error": f"HTTP {response.status_code}: {error_detail}",
                        },
                        indent=2,
                    )

        except httpx.TimeoutException:
            return json.dumps(
                {
                    "success": False,
                    "query": query,
                    "answer": "",
                    "error": "Request timed out - the query may be too complex",
                },
                indent=2,
            )
        except Exception as e:
            logger.error(f"Research query error: {e}")
            return json.dumps(
                {
                    "success": False,
                    "query": query,
                    "answer": "",
                    "error": str(e),
                },
                indent=2,
            )

    @mcp.tool()
    async def research_health(ctx: Context) -> str:
        """
        Check if the research agent is available and properly configured.

        Returns:
            JSON with availability status and configuration details
        """
        try:
            api_url = get_api_url()
            timeout = httpx.Timeout(10.0, connect=5.0)

            async with httpx.AsyncClient(timeout=timeout) as client:
                response = await client.get(urljoin(api_url, "/api/research/health"))

                if response.status_code == 200:
                    result = response.json()
                    return json.dumps(
                        {
                            "success": True,
                            "available": result.get("available", False),
                            "openai_configured": result.get("openai_key_configured", False),
                            "agent_ready": result.get("agent_importable", False),
                        },
                        indent=2,
                    )
                else:
                    return json.dumps(
                        {
                            "success": False,
                            "available": False,
                            "error": f"HTTP {response.status_code}",
                        },
                        indent=2,
                    )

        except Exception as e:
            logger.error(f"Research health check error: {e}")
            return json.dumps(
                {
                    "success": False,
                    "available": False,
                    "error": str(e),
                },
                indent=2,
            )

    logger.info("✓ Research tools registered (HTTP-based)")
