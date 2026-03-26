# YAMLResume GitHub Action

Build professional resumes from YAML files using
[YAMLResume](https://yamlresume.dev) CLI.

[![Test YAMLResume Action](https://github.com/yamlresume/action/actions/workflows/test.yml/badge.svg)](https://github.com/yamlresume/action/actions/workflows/test.yml)

## Features

- Build multiple resumes in a single workflow step
- Customizable build options (skip validation, skip PDF)
- Outputs generated file paths for use in subsequent steps
- Works seamlessly with `actions/upload-artifact`

## Usage

### Basic Usage

Build a single resume:

```yaml
- uses: yamlresume/action@v1
  with:
    resumes: resume.yml
```

### Multiple Resumes

Build multiple resumes using newline-separated list:

```yaml
- uses: yamlresume/action@v1
  with:
    resumes: |
      resume-en.yml
      resume-zh.yml
      resume-fr.yml
```

### Skip PDF Generation

Generate only LaTeX files (useful for custom PDF pipelines):

```yaml
- uses: yamlresume/action@v1
  with:
    resumes: resume.yml
    no-pdf: true
```

### Skip Validation

Skip schema validation during build:

```yaml
- uses: yamlresume/action@v1
  with:
    resumes: resume.yml
    no-validate: true
```

### Upload Artifacts

Use with `actions/upload-artifact` to save generated files:

```yaml
- uses: yamlresume/action@v1
  id: build
  with:
    resumes: resume.yml

- uses: actions/upload-artifact@v4
  with:
    name: resume-pdf
    path: resume.pdf
```

### Complete Workflow Example

```yaml
name: Build Resume

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build resumes
        id: build
        uses: yamlresume/action@v1
        with:
          resumes: |
            resume-en.yml
            resume-zh.yml
          verbose: true

      - name: Upload PDF artifacts
        uses: actions/upload-artifact@v4
        with:
          name: resumes
          path: |
            *.pdf
            *.tex
```

## Inputs

| Input         | Description                                          | Required | Default   |
| ------------- | ---------------------------------------------------- | -------- | --------- |
| `resumes`     | Newline-separated list of resume YAML files to build | Yes      | -         |
| `no-validate` | Skip schema validation                               | No       | `false`   |
| `no-pdf`      | Skip PDF generation (generate only LaTeX)            | No       | `false`   |
| `verbose`     | Enable verbose output                                | No       | `false`   |
| `version`     | YAMLResume Docker image version                      | No       | `v0.12.1` |

## Outputs

| Output       | Description                                      |
| ------------ | ------------------------------------------------ |
| `pdf-files`  | Newline-separated list of generated PDF files    |
| `tex-files`  | Newline-separated list of generated LaTeX files  |
| `html-files` | Newline-separated list of generated HTML files   |
| `md-files`   | Newline-separated list of generated Markdown files |

### Using Outputs

```yaml
- uses: yamlresume/action@v1
  id: build
  with:
    resumes: resume.yml

- run: |
    echo "Generated PDFs:"
    echo "${{ steps.build.outputs.pdf-files }}"

    echo "Generated TeX files:"
    echo "${{ steps.build.outputs.tex-files }}"

    echo "Generated HTML files:"
    echo "${{ steps.build.outputs.html-files }}"

    echo "Generated Markdown files:"
    echo "${{ steps.build.outputs.md-files }}"
```

## Requirements

- **Runner**: Linux (Ubuntu recommended) - Docker is required
- **Docker**: Must be available on the runner (GitHub-hosted Ubuntu runners
  include Docker)

## Example Resume

Create a `resume.yml` file in your repository:

```yaml
# yaml-language-server: $schema=https://yamlresume.dev/schema.json
---
content:
  basics:
    name: Your Name
    headline: Your Title
    email: your@email.com
    summary: |
      - Your professional summary
      - Key achievements and skills

  education:
    - institution: University Name
      degree: Bachelor
      area: Computer Science
      startDate: Sep 2016
      endDate: Jul 2020

  work:
    - name: Company Name
      position: Software Engineer
      startDate: Aug 2020
      endDate:
      summary: |
        - Achievement 1
        - Achievement 2

  skills:
    - name: Programming
      level: Expert
      keywords:
        - JavaScript
        - Python
        - TypeScript

locale:
  language: en

layouts:
  - engine: latex
    template: moderncv-banking
    typography:
      fontSize: 11pt
```

See the [YAMLResume documentation](https://yamlresume.dev/docs) for the complete
schema and available templates.

## Troubleshooting

### Docker not available

This action requires Docker to run the YAMLResume CLI. GitHub-hosted Ubuntu
runners include Docker by default. If using self-hosted runners, ensure Docker
is installed and available.

### Permission issues

The action runs Docker containers with root privileges (`-u root`) to ensure
compatibility with GitHub Actions runners. This is required because GitHub
Actions runners expect root access to the workspace.

### Build failures

Enable verbose output to see detailed build logs:

```yaml
- uses: yamlresume/action@v1
  with:
    resumes: resume.yml
    verbose: true
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- [YAMLResume Website](https://yamlresume.dev)
- [YAMLResume Documentation](https://yamlresume.dev/docs)
- [YAMLResume CLI](https://github.com/yamlresume/yamlresume)
- Docker Image
  - https://ghcr.io/yamlresume/yamlresume 
  - https://hub.docker.com/r/yamlresume/yamlresume
