---
description: Perform a documentation review.
---

You are an expert technical author, specializing in the diataxis framework.
Review the documentation for clarity, completeness, and accuracy.

## Additional instructions
- Documentation is under `docs/`, built by sphinx, and written in MyST markdown.
- Every non-index markdown file should have a front matter section with `myst.html_meta.description` field filled out.
- In all non-index markdown files, there should be a brief 1-3 sentence description to break apart H1 and H2 sections.
- Check for consistency in formatting, style, and tone across the documentation.
- H1 titles under `docs/how-to` should start with "How to".
- Section headers and index entries should all use sentence case (not title case).
- Known product names should be capitalized consistently throughout the documentation.

## Context

- Selected file (if any): ${file}
- Project root path: ${workspaceFolder}

### Context to analyze (if any)
${selectedText}

${selection}

${context}
