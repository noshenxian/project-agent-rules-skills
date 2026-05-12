# AGENTS.md

This file defines project-level agent rules for the calculator project. Generic agent rules come from the parent project or runtime environment; this file only describes calculator-specific constraints.

<!-- PROJECT_AGENT_RULES_START -->
## Project-Specific Agent Rules

### Project Signals

- Project type: calculator application.
- Runtime shape: unspecified; default to a browser-based or lightweight local app.
- Core domain: expression input, numeric operations, display formatting, error handling, keyboard and button interactions.
- State model: current input, expression history, calculation result, error state, and optional calculation history.
- Main risks: floating-point precision, division by zero, expression parsing errors, chained operation semantics, input boundaries, and mobile layout.
- Delivery target: runnable, testable, clear-interaction minimal calculator.

### Required Routing

- Before adding features, changing the interaction model, or choosing architecture, clarify calculator scope: basic arithmetic, scientific functions, history, keyboard support, and mobile adaptation.
- Use superpowers process skills to constrain the workflow: requirements clarification/planning, test-first work, and verification before completion.
- Use gstack for product scope, interface experience, and implementation completeness: `/office-hours` or `/plan-design-review` during product/UX work, and `/review` or `/qa` during implementation checks.
- If superpowers or gstack is unavailable, stop generating or editing rules and ask for the missing dependency to be installed. Do not pretend that a generic local checklist is equivalent.

### Engineering Rules

- Calculation logic must be separated from UI. Core arithmetic, expression parsing, formatting, and error handling should live in modules that can be tested independently.
- Do not execute user input with `eval`. If expression input is supported, use an explicit parser, a constrained tokenizer, or a button-driven controlled operation state machine.
- Define the numeric precision strategy: native floating point, fixed-point decimal, or a decimal library. For money or high-precision calculations, bare floating point must not be the final result representation.
- Define error semantics: division by zero, invalid expression, overflow, empty input, repeated operators, and repeated decimal point input.
- UI interactions should cover at least: digit input, clear, backspace, chained operations, repeated equals, decimal input, and negative number input.
- Layout should work at common desktop and mobile widths. Button sizes, focus states, and keyboard input must be usable.
- Do not add scientific calculation, unit conversion, themes, accounts, or cloud sync before the requirement is confirmed.

### Verification Gates

- Provide repeatable core calculation tests covering at least:
  - Addition, subtraction, multiplication, and division.
  - Operator precedence, or an explicit statement that precedence is not supported.
  - Decimal calculations.
  - Division by zero and invalid input.
  - Chained operations and clear state.
- For a Web UI, verify button clicks, keyboard input, mobile layout, and error display.
- Before completion, run the project's existing test command. If the project has no test framework, provide manual verification steps with expected results.
- Do not claim that "calculation is correct", "interaction is complete", or "it can be released" without running verification.
<!-- PROJECT_AGENT_RULES_END -->
