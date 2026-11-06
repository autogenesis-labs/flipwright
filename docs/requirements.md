# FlipWright Requirements

Status: source of truth for product and process requirements. Changes require human review.

## Product

- **R1. Genre.** A hybrid-casual game built on classic pinball mechanics.
- **R2. Differentiation.** The game must be clearly distinct from existing pinball games on the market.
- **R3. Engagement.** Strong player immersion and high player retention.
- **R4. Platforms.** iOS is the primary target. Web and Android are also targets.
- **R5. Performance.** Performance is the top technical priority, especially on iOS.

## Process

- **R6. Fully AI-developed.** AI writes all code. Humans do not write or review code. Humans review only the requirements, the architecture, and the final output (builds, gameplay).
- **R7. Iterative development.** Ship in small, playable increments.
- **R8. Testing.**
  - Core logic: 100% unit test coverage.
  - Main user flows: end-to-end UI tests.
- **R9. No over-engineering.** You Aren't Gonna Need It (YAGNI). Build only what the current iteration needs.

## Engine

- **R13. Separable engine.** When development is complete, the in-house engine must be extractable into its own repository and usable without any FlipWright code.

## Assets

- **R10. Code-drawn assets.** Draw as many assets as possible in code.
- **R11. Generated images.** Where an image is truly needed, AI writes the prompt and a human generates it with GPT Image.

## Language

- **R12. English.** All documents and code are in English.

## Related documents

- [Game design](game-design.md)
- [Architecture](architecture.md)
- [Development plan](dev-plan.md)
- [Development process](dev-process.md)
