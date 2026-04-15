# Implementation Plan

## Summary
- Total phases: 4
- Total tasks: 8
- Estimated complexity: Medium

## Dependencies
1 → 2 → 3, 1 → 4, 3 → 5, 4 → 5, 5 → 6 → 7 → 8
Tasks 2 and 4 can run in parallel after Task 1.

---

## Phase 1: Project Skeleton
**Goal**: A FastAPI app that starts, connects to PostgreSQL with pgvector, and responds to a health check.

### Task 1: Project setup and database connection

**Context:** This is a Python RAG chatbot API built with FastAPI and PostgreSQL (pgvector). The project uses UV for package management. This task sets up the foundation — a running FastAPI app with an async database connection and the pgvector extension enabled.

**Build:**
1. Initialize the project with UV and add core dependencies: fastapi, uvicorn, sqlalchemy (async), asyncpg, pgvector, pydantic-settings
2. Create the FastAPI app with a health check endpoint that confirms the database connection is alive
3. Set up SQLAlchemy async engine and session factory, configured via environment variables
4. Create a Docker Compose file with the API service and a PostgreSQL container with the pgvector extension
5. Ensure the app starts and the health check returns 200

**Verify:** Run `docker compose up`, then `curl http://localhost:8000/health` returns `{"status": "ok"}`.

---

## Phase 2: Document Ingestion
**Goal**: PDFs can be uploaded, chunked, embedded, and stored. Documents can be listed and deleted.

### Task 2: Document and chunk database models

**Context:** This is a RAG chatbot API that stores PDF documents and their text chunks with vector embeddings. The app uses SQLAlchemy async with PostgreSQL and pgvector. This task creates the database models that all subsequent features depend on.

**Build:**
1. Create a Document model with fields: id, filename, upload timestamp, chunk count
2. Create a Chunk model with fields: id, document_id (foreign key), content (text), embedding (pgvector vector of 1536 dimensions), chunk index
3. Add Alembic or auto-create tables on startup

**Verify:** `docker compose exec db psql -U postgres -c "\dt"` shows `documents` and `chunks` tables. `docker compose exec db psql -U postgres -c "\d chunks"` shows a `vector(1536)` column.

### Task 3: PDF upload and ingestion endpoint

**Context:** This is a RAG chatbot API. Users upload PDFs, and the system needs to extract the text, split it into chunks, generate embeddings, and store everything. The app uses FastAPI with async SQLAlchemy and calls the OpenAI embeddings API (text-embedding-3-small, 1536 dimensions). Chunks should be ~500 tokens with ~50 token overlap.

**Build:**
1. Create POST `/api/v1/documents` that accepts a PDF file upload
2. Extract text from the PDF
3. Split extracted text into fixed-size chunks (~500 tokens, ~50 token overlap)
4. Generate embeddings for each chunk via the OpenAI embeddings API
5. Store the document record and all chunks with their embeddings in a single transaction

**Verify:** Upload a sample PDF via `curl -F "file=@test.pdf" http://localhost:8000/api/v1/documents`. Confirm the response includes the document ID and chunk count, and that chunks with embeddings exist in the database.

### Task 4: Document list and delete endpoints

**Context:** This is a RAG chatbot API with a documents table and a chunks table. Users need to see what documents they've uploaded and remove documents they no longer need. Deleting a document must also remove all associated chunks and embeddings.

**Build:**
1. Create GET `/api/v1/documents` that returns all documents with metadata (id, filename, upload time, chunk count)
2. Create DELETE `/api/v1/documents/{id}` that removes the document and all associated chunks
3. Return 404 for delete requests on non-existent documents

**Verify:** Upload a document, list documents (confirm it appears), delete it (confirm 200), list again (confirm it's gone). Delete a non-existent ID (confirm 404).

---

## Phase 3: Chat and Retrieval
**Goal**: Users can ask questions and get answers grounded in their uploaded documents.

### Task 5: Retrieval service — vector similarity search

**Context:** This is a RAG chatbot API. Documents have been chunked and embedded (1536-dimension vectors stored in pgvector). The retrieval service needs to take a user's question, embed it, and find the most relevant chunks using vector similarity search. This service is used by the chat endpoint to ground answers in document content.

**Build:**
1. Create a retrieval service that accepts a query string
2. Embed the query using the OpenAI embeddings API (same model used for document chunks)
3. Perform a cosine similarity search against the chunks table using pgvector, returning the top 5 chunks
4. Return the chunks with their content, document ID, and similarity score

**Verify:** With a document uploaded, `curl -X POST http://localhost:8000/api/v1/chat -H "Content-Type: application/json" -d '{"message": "test query"}'` returns a response with a non-empty `sources` array, each containing `content`, `document_id`, and `score` sorted by descending score.

### Task 6: Chat endpoint

**Context:** This is a RAG chatbot API. The retrieval service (already built) finds relevant document chunks for a query. The chat endpoint needs to use those chunks to generate a grounded answer via OpenAI's chat completion API. Answers must include source references — the specific chunks used. When no relevant chunks are found, the response should indicate the system has no information rather than hallucinating.

**Build:**
1. Create POST `/api/v1/chat` that accepts a JSON body with a `message` field
2. Call the retrieval service to get relevant chunks
3. Build a prompt that includes the retrieved chunks as context and instructs the model to answer based only on the provided context
4. Call OpenAI chat completion and return the answer with source references (chunk content and document ID)
5. When no relevant chunks are found, return a response indicating no information is available

**Verify:** Upload a document, then `curl -X POST http://localhost:8000/api/v1/chat -H "Content-Type: application/json" -d '{"message": "..."}'` with a question relevant to the document. Confirm the response includes an answer and source references. Send an unrelated question and confirm the response indicates no information.

---

## Phase 4: Polish
**Goal**: Consistent error handling, response schemas, and tests.

### Task 7: Consistent response schemas and error handling

**Context:** This is a RAG chatbot API with endpoints for document upload, listing, deletion, and chat. All API responses need to follow a consistent JSON structure with appropriate HTTP status codes. This task standardizes the response format across all endpoints and adds proper error handling for edge cases (invalid files, missing documents, OpenAI API errors).

**Build:**
1. Define Pydantic response schemas for all endpoints
2. Add error handling for: non-PDF uploads (400), oversized files (400), missing documents (404), OpenAI API failures (502)
3. Ensure all success and error responses follow the same envelope structure

**Verify:** `curl -F "file=@test.txt" http://localhost:8000/api/v1/documents` returns 400. `curl -X DELETE http://localhost:8000/api/v1/documents/99999` returns 404. `pytest tests/test_schemas.py` passes.

### Task 8: Integration tests

**Context:** This is a RAG chatbot API built with FastAPI, PostgreSQL/pgvector, and the OpenAI API. The API has four endpoints: document upload, list, delete, and chat. This task adds integration tests that verify the full request-response cycle for each endpoint, using a test database and mocked OpenAI calls.

**Build:**
1. Set up a pytest fixture that creates a test database with pgvector and provides an httpx AsyncClient
2. Mock the OpenAI API calls (embeddings and chat completion) to return deterministic responses
3. Write tests covering: upload a PDF and verify chunks are created, list documents, delete a document, chat with relevant chunks, chat with no relevant chunks

**Verify:** Run `pytest` — all tests pass.
