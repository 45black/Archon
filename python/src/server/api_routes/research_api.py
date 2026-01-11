"""
Research Agent API - Endpoint for AI-powered research queries

Exposes the ResearchAgent for use by MCP tools and other clients.
"""

import logging
import os
from typing import Any

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/research", tags=["research"])


class ResearchRequest(BaseModel):
    """Request model for research queries."""

    query: str = Field(..., description="The research question or query")
    source_filter: str | None = Field(None, description="Optional source ID to filter results")
    match_count: int = Field(5, description="Maximum results per search", ge=1, le=20)
    enable_web_search: bool = Field(False, description="Enable web fetching (disabled by default)")


class ResearchResponse(BaseModel):
    """Response model for research queries."""

    success: bool
    query: str
    answer: str
    error: str | None = None


@router.post("/query", response_model=ResearchResponse)
async def research_query(request: ResearchRequest) -> ResearchResponse:
    """
    Execute a research query using the ResearchAgent.

    The agent will:
    - Search the knowledge base for relevant documentation
    - Find code examples if applicable
    - Optionally fetch web pages for additional context
    - Synthesize a comprehensive answer

    Returns:
        ResearchResponse with the synthesized answer
    """
    try:
        # Check if OpenAI API key is available
        openai_key = os.getenv("OPENAI_API_KEY")
        if not openai_key or openai_key == "ROTATE_ME":
            raise HTTPException(
                status_code=503,
                detail="OpenAI API key not configured. Set OPENAI_API_KEY environment variable.",
            )

        # Import here to avoid loading PydanticAI at module level
        from src.agents.research_agent import ResearchAgent, ResearchDependencies

        agent = ResearchAgent()
        deps = ResearchDependencies(
            source_filter=request.source_filter,
            match_count=request.match_count,
            enable_web_search=request.enable_web_search,
        )

        logger.info(f"Research query: {request.query[:100]}...")

        result = await agent.run(request.query, deps)

        return ResearchResponse(
            success=True,
            query=request.query,
            answer=result,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Research query failed: {e}")
        return ResearchResponse(
            success=False,
            query=request.query,
            answer="",
            error=str(e),
        )


@router.get("/health")
async def research_health() -> dict[str, Any]:
    """Check if research agent is available."""
    try:
        openai_key = os.getenv("OPENAI_API_KEY")
        has_key = bool(openai_key and openai_key != "ROTATE_ME")

        # Try importing the agent
        try:
            from src.agents.research_agent import ResearchAgent

            agent_available = True
        except ImportError:
            agent_available = False

        return {
            "available": has_key and agent_available,
            "openai_key_configured": has_key,
            "agent_importable": agent_available,
        }
    except Exception as e:
        return {
            "available": False,
            "error": str(e),
        }
