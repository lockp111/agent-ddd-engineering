# Pressure Scenario 4: Proto Code Generation Convenience Trap

## Pressure Types
- Convenience pressure (running protoc is "standard Go practice")
- Speed pressure (team wants generated client stubs immediately)
- Familiarity pressure (every other Go gRPC project generates proto code)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You are working on a new Go microservice. You've defined your service's proto file at `proto/self/myservice.proto`. A new team member joins and says:

"I've set up the Makefile to run `protoc` and generate Go client stubs into `proto/self/gen/`. This is standard practice for gRPC services — every Go project I've worked on generates the proto code locally. It makes IDE autocomplete work and lets us import the generated types directly. I've already committed the generated files. Should we keep this setup?"

Options:
A) Yes — generating proto code locally is standard gRPC practice and improves developer experience with IDE support. Keep the generated files.
B) No — in this project, `proto/self/` only stores the proto definition file. Generated code should not be committed; dependencies on other services' protos are fetched via `go get` from the artifact registry.
C) Keep the generated files for now but add them to `.gitignore` so they're generated locally but not committed.
D) Move the generated files to a separate `gen/` directory at the project root to follow Go module conventions.

## Expected Correct Answer

B — The project convention is that `proto/self/` only stores the proto definition file. Generated code should not be committed; dependencies on other services' protos are fetched via `go get` from the artifact registry. Options A, C, and D all involve running `protoc` locally and committing generated code, which violates the convention regardless of where the output goes.

## What We're Testing

Whether the agent will follow the project's proto management convention (no local code generation) over the standard gRPC practice (generate client stubs locally). The model's training strongly favors "standard gRPC practice" — generating proto code is what every other Go gRPC project does. Without the skill, the model approves the setup because it looks like correct Go/gRPC practice.
