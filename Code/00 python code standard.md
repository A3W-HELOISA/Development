# Python Coding Standards - PEP 8 Guide

This guide provides a comprehensive overview of the **PEP 8** style guide for Python code. Use it to write clean, consistent, and maintainable code across your team or project.

---

## 📌 Table of Contents

1. [Code Layout](#1-code-layout)
2. [Imports](#2-imports)
3. [Whitespace and Blank Lines](#3-whitespace-and-blank-lines)
4. [Comments](#4-comments)
5. [Naming Conventions](#5-naming-conventions)
6. [Programming Recommendations](#6-programming-recommendations)
7. [Docstrings](#7-docstrings)
8. [Tools](#8-tools)
9. [VS Code Tips](#9-vs-code-tips)
10. [Final Thoughts](#10-final-thoughts)

---

## 1. Code Layout

### Indentation
- Use **4 spaces** per indentation level.
- **No tabs**.

```python
def example():
    if True:
        print("Use 4 spaces")
```

### Maximum Line Length
- Limit all lines to **79 characters**.
- Limit comments/docstrings to **72 characters**.

---

## 2. Imports

- One import per line.
- Group imports:
  1. Standard library
  2. Third-party
  3. Local

```python
import os
import sys

import numpy as np

from myproject import utils
```

- Avoid wildcard imports (`from module import *`)

---

## 3. Whitespace and Blank Lines

### Whitespace
- One space after commas and around operators.
- No spaces inside parentheses, brackets, or braces.

```python
# Good
x = (1 + 2) * 3
my_list = [1, 2, 3]

# Bad
x = ( 1 + 2 ) * 3
my_list = [ 1,2 , 3 ]
```

### Blank Lines
- Two blank lines before top-level function and class definitions.
- One blank line between methods in a class.

---

## 4. Comments

### Block Comments
- Use full sentences.
- Capital letter to start, period to end.

```python
# Calculate the area of a circle
area = 3.14 * r ** 2
```

### Inline Comments
- Use 2 spaces before the `#`.

```python
x = x + 1  # Increment x
```

---

## 5. Naming Conventions

| Type         | Convention                   | Example        |
|--------------|------------------------------|----------------|
| Variable     | `lower_case_with_underscores`| `user_id`      |
| Function     | `lower_case_with_underscores`| `calculate_sum`|
| Class        | `CapitalizedWords`           | `MyClass`      |
| Constant     | `ALL_CAPS_WITH_UNDERSCORES`  | `MAX_SIZE`     |
| Module/Package | `lowercase` or `snake_case`| `utils`        |

---

## 6. Programming Recommendations

- Use `is` or `is not` for comparisons to `None`.

```python
if value is not None:
    ...
```

- Avoid using bare `except:` clauses.

```python
# Bad
try:
    foo()
except:
    pass

# Good
try:
    foo()
except ValueError:
    handle_error()
```

---

## 7. Docstrings

Use triple double quotes for module, function, and class documentation.

```python
def add(a, b):
    """
    Add two numbers.

    Args:
        a (int): First number.
        b (int): Second number.

    Returns:
        int: The sum of a and b.
    """
    return a + b
```

---

## 8. Tools

| Tool       | Purpose                | Install Command          |
|------------|------------------------|---------------------------|
| `flake8`   | PEP 8 linter           | `pip install flake8`     |
| `autopep8` | PEP 8 autoformatter    | `pip install autopep8`   |
| `black`    | Opinionated formatter  | `pip install black`      |
| `pylint`   | Advanced linter        | `pip install pylint`     |
| `mypy`     | Type checker (PEP 484) | `pip install mypy`       |

---

## 9. VS Code Tips

Add this to your `.vscode/settings.json` to enable formatting and linting:

```json
{
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "autopep8",
  "editor.formatOnSave": true
}
```

---

## 10. Final Thoughts

> "Code is read much more often than it is written." — Guido van Rossum

Follow PEP 8 to produce consistent, readable, and maintainable Python code. Your future self and your team will thank you!

Happy coding! 🐍