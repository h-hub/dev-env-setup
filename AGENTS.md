# AGENT GUIDELINES FOR THE `dev-env-setup` REPOSITORY

This document outlines the conventions and practices for automated agents operating within this repository. Adhering to these guidelines ensures consistency, maintainability, and effective collaboration.

## 1. Build, Lint, and Test Commands

### 1.1 Java Projects

*   **Compilation:**
    *   To compile Java source files (e.g., `MyClass.java`):
        ```bash
        javac <path/to/MyClass.java>
        ```
    *   To compile all Java files in a directory:
        ```bash
        find . -name "*.java" -print0 | xargs -0 javac
        ```
*   **Execution:**
    *   To run a compiled Java class:
        ```bash
        java -cp . <com.example.MyClass>
        ```
*   **Testing:**
    *   Without a build system like Maven or Gradle, testing typically involves a test runner. If JUnit is used, you would need to set up the classpath.
    *   **Running a single test (placeholder):**
        ```bash
        # This command is a placeholder. Adapt based on actual test setup (e.g., JUnit, TestNG).
        # You might need to compile test classes and include test libraries in the classpath.
        java -cp .:junit-platform-console-standalone.jar org.junit.platform.console.ConsoleLauncher --scan-classpath --include-classname '.*MyTestClass'
        ```
    *   **General Testing Approach:** If no formal test framework is detected, consider writing small, self-contained test scripts that execute the Java code with various inputs and verify outputs.

### 1.2 Shell Scripts (.sh files)

*   **Linting:**
    *   Use `shellcheck` to lint shell scripts for common issues:
        ```bash
        shellcheck <path/to/script.sh>
        ```
    *   To lint all shell scripts:
        ```bash
        find . -name "*.sh" -print0 | xargs -0 shellcheck
        ```
*   **Execution:**
    *   Scripts are typically executed directly:
        ```bash
        bash <path/to/script.sh>
        # or with appropriate shebang:
        ./<path/to/script.sh>
        ```
*   **Testing:**
    *   Testing shell scripts usually involves running them with different parameters and checking their exit codes and output.
    *   **Running a single test (conceptual):**
        ```bash
        # Execute the script and capture output/exit status
        ./my_script.sh arg1 arg2 > output.txt
        # Then, assert expectations on output.txt and the script's exit code ($?)
        ```

## 2. Code Style Guidelines

### 2.1 Java

*   **Naming Conventions:**
    *   Classes: `PascalCase` (e.g., `MyAwesomeClass`).
    *   Methods: `camelCase` (e.g., `doSomethingUseful()`).
    *   Variables: `camelCase` (e.g., `myLocalVariable`).
    *   Constants: `SCREAMING_SNAKE_CASE` (e.g., `MAX_VALUE`).
    *   Packages: `lowercase.separated.by.dots` (e.g., `com.example.util`).
*   **Formatting:**
    *   Indent with 4 spaces.
    *   Curly braces (`{}`) for blocks should be on the same line as the declaration (K&R style for methods, class declarations).
    *   Maximum line length of 120 characters is a good practice.
*   **Imports:**
    *   Organize imports alphabetically.
    *   Avoid wildcard imports (e.g., `import java.util.*`).
*   **Types:**
    *   Use specific types where possible.
    *   Utilize generics for type safety in collections.
*   **Error Handling:**
    *   Prefer checked exceptions for recoverable errors and unchecked exceptions for programming errors.
    *   Provide meaningful exception messages.
    *   Avoid empty `catch` blocks.
*   **Comments:**
    *   Use Javadoc for public API.
    *   Add inline comments for complex logic or non-obvious code.

### 2.2 Shell Scripts

*   **Naming Conventions:**
    *   Scripts: `snake_case` (e.g., `setup_lazyvim_react.sh`).
    *   Variables: `UPPER_SNAKE_CASE` for environment variables/global constants, `lower_snake_case` for local variables.
    *   Functions: `snake_case` (e.g., `install_dependencies`).
*   **Formatting:**
    *   Indent with 2 or 4 spaces consistently.
    *   Use consistent quoting for strings (`"` or `'`). Prefer double quotes for variables that might contain spaces.
*   **Error Handling:**
    *   Start scripts with `set -euo pipefail` for robust error handling:
        *   `-e`: Exit immediately if a command exits with a non-zero status.
        *   `-u`: Treat unset variables as an error.
        *   `-o pipefail`: The return value of a pipeline is the exit status of the last command that failed.
*   **Readability:**
    *   Use comments to explain complex logic.
    *   Break down complex tasks into functions.
    *   Provide clear `echo` statements for user feedback.

## 3. Cursor/Copilot Rules

No specific `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` files were found in this repository. Agents should infer context and adhere to general best practices and the guidelines outlined above.
