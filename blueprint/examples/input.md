# Project Notes

Build a Python RAG chatbot API. Users upload PDF documents, the system chunks and embeds them, then users can ask questions and get answers grounded in their documents.

Stack: FastAPI, PostgreSQL with pgvector for embeddings, OpenAI API for embeddings and chat completion. Use UV for package management.

Endpoints:
- POST /api/v1/documents - upload a PDF, chunk it, embed it, store it
- POST /api/v1/chat - send a message, retrieve relevant chunks, return an AI-generated answer with source references
- GET /api/v1/documents - list uploaded documents
- DELETE /api/v1/documents/{id} - remove a document and its embeddings

Keep it simple. Single user, no auth for now. The chunking strategy doesn't need to be fancy — fixed-size chunks with overlap is fine.

Should be deployable with Docker Compose (API + Postgres).
