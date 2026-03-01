---
name: extracting-domain-events
description: Use when presented with a new PRD, feature request, or unstructured business requirements before writing any code or architecture plans. Triggers on "PRD", "需求分析", "事件风暴", "领域事件", "event storming", "提取核心模型".
---

# Extracting Domain Events

## Overview
This skill forces text-based EventStorming from PRDs or requirements. It translates unstructured business requirements into structured domain events, commands, and actors before any code is written, preventing premature implementation and monolithic thinking.

## When to Use
- When given a PRD (Product Requirements Document).
- When asked to "design a new feature" or "build a new module".
- When requirements are unstructured or ambiguous.
- **Before** writing any code or proposing an architecture.

## Core Pattern
**Instead of:** Jumping straight to database schemas or REST API endpoints.
**Do this:** Act as a Domain Expert and perform a text-based EventStorming session.

## Implementation

1. **Read and Analyze:** Thoroughly read the provided requirements or PRD.
2. **Identify Elements:** Extract the core components of the domain:
   - **Actor:** Who or what triggers the action (e.g., User, System, External Service).
   - **Command:** The intent or action requested by the Actor (e.g., `SubmitOrder`, `CancelSubscription`).
   - **Domain Event:** A past-tense business fact indicating something significant happened (e.g., `OrderSubmitted`, `SubscriptionCancelled`).
   - **Business Rules / Invariants:** The conditions that must be met for the Command to succeed and the Event to be generated.
3. **Enforce Naming Conventions:** All Domain Events MUST be named as past-tense business facts. Reject imperative or technical naming (e.g., use `PaymentReceived` not `ProcessPayment`).
4. **Include Failure Paths:** You MUST identify and include events for failure scenarios or compensating actions (e.g., `PaymentFailed`, `InventoryShortage`). Do not only map the "happy path".
5. **Output Format:** Output the results as a Markdown table.

### Example Output Table
| Actor           | Command           | Domain Event        | Business Rules / Invariants        |
| :-------------- | :---------------- | :------------------ | :--------------------------------- |
| Customer        | Submit Checkout   | `CartCheckedOut`    | Cart must not be empty.            |
| System          | Reserve Inventory | `InventoryReserved` | Sufficient stock must exist.       |
| System          | Reserve Inventory | `InventoryShortage` | Triggers if stock is insufficient. |
| Payment Gateway | Authorize Payment | `PaymentAuthorized` | Payment details must be valid.     |

## Common Mistakes & Red Flags
- 🚨 **Red Flag:** Starting to write `struct`, `class`, or `interface` definitions.
- 🚨 **Red Flag:** Designing API routes or database schemas at this stage.
- 🚨 **Red Flag:** Missing failure or compensating events in the output table.
- 🚨 **Red Flag:** Using imperative verbs for Domain Events (e.g., `CreateUser` instead of `UserCreated`).

**If any red flags occur: STOP, delete the generated code/schema, and restart the extraction process.**
