# Memohook Technical Design

- Version: 1.0
- Status: Draft
- Author: Weifeng Cao
- Last Updated: 2024-10-02

## Table of Contents
- [Executive Summary](#executive-summary)
- [Product Overview](#product-overview)
- [Goals and Scope](#goals-and-scope)
- [Personas and Use Cases](#personas-and-use-cases)
- [Functional Requirements](#functional-requirements)
- [Non-Functional Requirements](#non-functional-requirements)
- [System Architecture](#system-architecture)
- [Data Architecture](#data-architecture)
- [LLM Interaction Model](#llm-interaction-model)
- [Security, Privacy, and Compliance](#security-privacy-and-compliance)
- [Operational Readiness](#operational-readiness)
- [Risks and Mitigations](#risks-and-mitigations)
- [Testing and Validation](#testing-and-validation)
- [Roadmap](#roadmap)
- [Dependencies and Assumptions](#dependencies-and-assumptions)
- [Glossary](#glossary)

## Executive Summary
Memohook is a cross-platform, voice-first memory companion designed to help seniors and caregivers capture and recall daily events without cognitive friction. The system combines Flutter for client experiences, Firebase for backend services, and Google Gemini for language understanding. This design document outlines the product objectives, architecture, and operational plan required to deliver a production-ready MVP with a clear path to future enhancements.

## Product Overview
- **Problem Statement:** Seniors with mild memory challenges struggle to remember routine tasks and find traditional apps overwhelming.
- **Solution:** Provide an intent-less, conversational interface that automatically distinguishes between logging events and querying prior memories.
- **Success Metrics (MVP):**
  - ≥80% of captured logs successfully classified as LOG with no manual correction.
  - Mean response time (speech end → UI response) ≤5 seconds.
  - ≥60% weekly active retention among pilot cohort.

## Goals and Scope

### In-Scope Objectives
- Validate the voice-first, intent-less interaction model across web and mobile targets using a shared Flutter codebase.
- Persist user memory logs securely with reliable retrieval and summarization experiences.
- Provide caregivers with confidence that sensitive data remains private and accessible only to the intended user.

### Out-of-Scope Items (MVP)
- Social or multi-user collaboration features.
- Rich media capture (photos, videos, audio uploads).
- Account management workflows beyond anonymous authentication.

## Personas and Use Cases

### Primary Personas
- **David – Independent Senior:** Needs an effortless way to record daily actions (e.g., medication adherence, home security checks) and confirm completion later.
- **Sarah – Caregiver and Sponsor:** Requires assurance that her father can log and recall activities independently, while she evaluates future storytelling use cases.

### Core Use Cases
1. **Capture Memory:** David opens Memohook, speaks a statement, and the app stores it as a time-stamped memory.
2. **Recall Memory:** David asks a question (e.g., “Did I take my morning pills?”) and receives the most relevant log entry.
3. **Daily Summary:** David requests a summary of today’s activities and gets a concise narrative.
4. **Memory Expansion:** David selects a specific log to generate a richer, story-like version for journaling.

## Functional Requirements

| ID  | Requirement | Priority |
| --- | ----------- | -------- |
| FR1 | Provide a single primary action to initiate voice capture. | Must-have |
| FR2 | Transcribe user speech to text using on-device (where available) or platform speech APIs. | Must-have |
| FR3 | Classify transcriptions into `LOG` or `QUERY` intents using an LLM. | Must-have |
| FR4 | Persist `LOG` entries with server-generated timestamps and optional keywords. | Must-have |
| FR5 | Extract search keywords for `QUERY` intents to retrieve relevant logs. | Must-have |
| FR6 | Display the most recent relevant log entry for a `QUERY`. | Must-have |
| FR7 | Generate a natural-language summary of all logs for the current day. | Should-have |
| FR8 | Expand a selected log entry into a short narrative using the LLM. | Should-have |
| FR9 | Provide basic offline handling (queue logs, warn on query attempts). | Should-have |
| FR10 | Allow manual text entry fallback when voice capture fails. | Could-have |

## Non-Functional Requirements

| ID   | Category | Requirement | Target |
| ---- | -------- | ----------- | ------ |
| NFR1 | Performance | End-to-end latency (speech end → response) | ≤5 s (p95) |
| NFR2 | Reliability | Service uptime | ≥99.9% |
| NFR3 | Usability | WCAG 2.1 AA compliance for contrast and font size; one-tap navigation | 100% of UI |
| NFR4 | Security | Enforce per-user data isolation via Firebase Security Rules | 100% coverage |
| NFR5 | Data Integrity | Server-side timestamp immutability; no client overrides | 100% of writes |
| NFR6 | Observability | Collect structured logs and metrics for speech capture, LLM calls, and Firestore ops | MVP-ready dashboards |

## System Architecture

### High-Level Components
- **Flutter Client:** Cross-platform application responsible for UI rendering, voice capture, optimistic UI updates, and orchestrating API calls.
- **Firebase Backend:** Provides anonymous authentication, Firestore document storage, and Cloud Functions for secure server-side operations.
- **Google Gemini Service:** Handles intent classification, keyword extraction, summarization, and narrative expansion.

### Component Responsibilities
- **Presentation Layer (Flutter):** Implements accessibility-compliant UI, manages voice capture state, and surfaces responses.
- **Application Layer (Flutter):** Manages state (Riverpod/Provider), handles offline queuing, and invokes backend services.
- **Integration Layer:**
  - **Speech-to-Text Adapter:** Wraps native speech APIs via `speech_to_text` package.
  - **LLM Client:** Sends structured prompts to Gemini, enforces JSON responses, applies retry/backoff strategy.
- **Backend Services:**
  - **Auth:** Issues anonymous user IDs; enforces device-level persistence.
  - **Firestore:** Stores logs keyed by user ID with composite indexes for keyword queries.
  - **Cloud Functions (Future):** Optional layer for sensitive operations (e.g., advanced analytics) kept out of the client.

### Sequence Overview (Query Flow)
1. User initiates voice capture.
2. Client records audio and obtains transcription.
3. LLM classifies intent; returns keywords.
4. Client queries Firestore using keywords; applies client-side ranking (recency first).
5. Result displayed with timestamp; optional summarization invoked if no direct match.

## Data Architecture

### Firestore Structure

```
/artifacts/{appId}/users/{userId}/logs/{logId}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `text` | String | User-provided transcription for log entries. |
| `timestamp` | Timestamp | Server-generated creation time. |
| `keywords` | Array<String> | Tokenized keywords extracted during LOG flows. |
| `source` | String | Origin of entry (`speech`, `text`, `import`). |
| `summaries.daily` | Map | Cached daily summaries keyed by ISO date. |

### Indexing Strategy
- Composite index on `keywords` + `timestamp` descending to support keyword searches.
- TTL-like cleanup handled via scheduled Cloud Function for stale summaries (Phase 2).

### Data Lifecycle
- **Retention:** Logs retained indefinitely unless future retention policies are introduced.
- **Backup & Restore:** Rely on Firebase-managed backups; document recovery procedures in runbook.

## LLM Interaction Model

### Prompt Catalog

| Flow | System Prompt (Summary) | Output Contract |
| ---- | ----------------------- | --------------- |
| Intent Classification | Classify user text as `LOG` or `QUERY`; emit keywords. | `{ "intent": "LOG" | "QUERY", "keywords": [string] }` |
| Daily Summary | Convert list of logs into a friendly paragraph. | `{ "summary": string }` |
| Memory Expansion | Expand a log into first-person narrative. | `{ "story": string }` |

### Guardrails
- Enforce JSON-only responses by validating payloads client-side.
- Apply retry with exponential backoff (3 attempts) for transient failures; fall back to cached results when available.
- Log latency and error rates per LLM call for monitoring.

## Security, Privacy, and Compliance
- **Authentication:** Anonymous Firebase Auth with device-bound UID; future enhancement to support caregiver-linked accounts.
- **Authorization:** Firestore Security Rules restrict reads/writes to the authenticated user’s path.
- **Data in Transit:** All calls to Firebase and Gemini performed over HTTPS; enforce TLS 1.2+.
- **PII Handling:** No explicit PII collected; treat log content as sensitive. Future work may include configurable redaction.
- **Compliance Considerations:** Review against HIPAA if used for medical reminders; currently targeting consumer use without PHI commitments.

## Operational Readiness
- **Deployment:**
  - Web: Firebase Hosting with CI/CD pipeline (GitHub Actions) for automated builds.
  - Mobile: Manual store submissions for MVP; plan Fastlane automation in Phase 2.
- **Monitoring:**
  - Use Firebase Analytics for user flows.
  - Leverage Cloud Logging for Firestore and Gemini interactions.
  - Establish alert thresholds for LLM failure rate (>5%) and Firestore error spikes.
- **Runbooks:** Document incident response for LLM outages (fallback messaging) and Firestore read quota exhaustion.

## Risks and Mitigations

| Risk | Impact | Mitigation |
| ---- | ------ | ---------- |
| LLM misclassification of queries | Incorrect responses reduce trust. | Add manual correction option; monitor misclassification feedback. |
| Speech recognition inaccuracies | Logs become unusable. | Provide manual text entry fallback; consider per-device calibration tips. |
| LLM latency spikes | Exceeds 5-second SLA. | Cache previous summaries; parallelize Firestore query while awaiting LLM response. |
| User privacy concerns | Adoption barrier. | Clear privacy messaging; ensure at-rest encryption and transparent policies. |
| Vendor lock-in (Gemini) | Future cost or availability issues. | Abstract LLM client; evaluate OpenAI/AWS Bedrock alternatives in Phase 3. |

## Testing and Validation
- **Automated:** Widget and integration tests for critical flows (voice capture mocked, log persistence, query responses).
- **Manual:** Accessibility audits (screen reader, high-contrast mode), exploratory testing for edge speech inputs.
- **Monitoring Validation:** Synthetic canary tests hitting Gemini and Firestore endpoints hourly.
- **User Research:** Conduct usability sessions with seniors to validate voice-first UX and error recovery.

## Roadmap
- **Phase 0 – Setup:** Configure Firebase project, authentication, security rules, and Gemini API keys. Establish CI/CD.
- **Phase 1 – MVP:** Deliver core voice logging and querying across web, iOS, and Android; onboard pilot cohort.
- **Phase 2 – Platform Enhancements:** Add platform-specific affordances (widgets, Wear OS companion), automate mobile deployments.
- **Phase 3 – Conversational Enrichment:** Introduce text-to-speech feedback and optional caregiver dashboards.
- **Phase 4 – Rich Media:** Enable multimedia attachments stored in Firebase Storage and linked to logs.

## Dependencies and Assumptions
- Stable access to Google Gemini with sufficient quota for target user volume.
- User devices support required speech APIs; fallback text input available otherwise.
- Firebase project configured with billing to unlock necessary quotas (Firestore, Functions, Hosting).
- Pilot users consent to anonymized telemetry for performance tuning.

## Glossary
- **Intent-less UI:** Interface pattern where the system infers user intent without explicit user selection.
- **LLM:** Large Language Model providing natural-language understanding and generation.
- **MVP:** Minimum Viable Product delivering core value with limited scope.
- **WCAG:** Web Content Accessibility Guidelines, version 2.1 AA compliance level.
