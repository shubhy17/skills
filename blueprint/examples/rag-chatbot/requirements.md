# Requirements

## Overview
A Python RAG (Retrieval-Augmented Generation) chatbot API that lets users upload PDF documents, then ask natural language questions and receive answers grounded in the uploaded content.

## Problem Statement
Users have collections of PDF documents containing important information but no efficient way to query them conversationally. Searching manually through PDFs is slow and unreliable. This API provides a programmatic interface for document ingestion and question-answering.

## Users
Developers integrating document Q&A into their applications via the API. Single-user system — no multi-tenancy.

## Functional Requirements
- FR-01: Accept PDF file uploads via API, extract text content, split into chunks, generate embeddings, and store both chunks and embeddings
- FR-02: Accept a chat message via API, retrieve the most relevant document chunks using vector similarity search, and return an AI-generated answer that references the source chunks
- FR-03: List all uploaded documents with metadata (name, upload time, chunk count)
- FR-04: Delete a document and all associated chunks and embeddings
- FR-05: Chat responses must include source references — the specific chunks used to generate the answer
- FR-06: When no relevant chunks are found for a query, the system returns a response indicating it has no information rather than hallucinating

## Non-Functional Requirements
- NFR-01: PDF processing (upload, chunk, embed) completes within 30 seconds for documents under 50 pages
- NFR-02: Chat responses return within 5 seconds for queries against collections under 1000 chunks
- NFR-03: The system runs locally via Docker Compose with no external dependencies beyond the OpenAI API
- NFR-04: All API responses follow consistent JSON structure with appropriate HTTP status codes

## Out of Scope
- Authentication and authorization
- Multi-user or multi-tenant support
- Conversation history or multi-turn chat
- Non-PDF document formats
- Custom chunking strategies beyond fixed-size with overlap
- Deployment to cloud providers

## Success Metrics
- A PDF can be uploaded and queried within 60 seconds end-to-end
- Chat answers include at least one source reference when relevant chunks exist
- All four CRUD+chat endpoints return correct responses for valid and invalid inputs

## Assumptions
- [ASSUMED] OpenAI API key is provided via environment variable
- [ASSUMED] PostgreSQL with pgvector extension is available via Docker
- [ASSUMED] PDFs contain extractable text (not scanned images)
- [ASSUMED] Chunk size of ~500 tokens with ~50 token overlap is sufficient

## Open Questions
- [TBD] Which OpenAI embedding model to use (text-embedding-3-small vs text-embedding-3-large) — affects vector dimensions and cost
- [TBD] How many chunks to retrieve per query — affects answer quality and latency
