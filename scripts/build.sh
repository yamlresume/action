#!/usr/bin/env bash
#
# YAMLResume GitHub Action - Build Script
# Builds resume YAML files to PDF/LaTeX using the yamlresume Docker image
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration from environment variables
RESUMES="${INPUT_RESUMES:-}"
NO_VALIDATE="${INPUT_NO_VALIDATE:-false}"
NO_PDF="${INPUT_NO_PDF:-false}"
VERBOSE="${INPUT_VERBOSE:-false}"
VERSION="${INPUT_VERSION:-v0.12.1}"

# Working directory (GITHUB_WORKSPACE in CI, current directory locally)
WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"

# Output file for GitHub Actions
GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/null}"

# Arrays to collect output files
PDF_FILES=()
TEX_FILES=()
HTML_FILES=()
MD_FILES=()

# Track build failures
BUILD_FAILED=0

# Build a single resume
build_resume() {
    local resume="$1"
    local resume_path="${WORKSPACE}/${resume}"
    
    # Check if file exists
    if [ ! -f "$resume_path" ]; then
        log_error "Resume file not found: $resume"
        return 1
    fi
    
    log_info "Building resume: $resume"
    
    # Build docker command as array for safe argument handling
    local cmd=(docker run --rm -u root
        -v "${WORKSPACE}:/home/yamlresume"
        -w "/home/yamlresume"
        "ghcr.io/yamlresume/yamlresume:${VERSION}")
    
    # -v (verbose) must come BEFORE the subcommand
    if [ "$VERBOSE" = "true" ]; then
        cmd+=(-v)
    fi
    
    cmd+=(build)
    
    if [ "$NO_VALIDATE" = "true" ]; then
        cmd+=(--no-validate)
    fi
    
    if [ "$NO_PDF" = "true" ]; then
        cmd+=(--no-pdf)
    fi
    
    cmd+=("$resume")
    
    # Run yamlresume build in Docker
    # Note: Using /home/yamlresume as mount point per official docs
    # Note: Using -u root for GitHub Actions compatibility
    if "${cmd[@]}"; then
        
        log_info "Successfully built: $resume"
        
        # Collect output files
        local base_name="${resume%.yml}"
        base_name="${base_name%.yaml}"
        
        if [ -f "${WORKSPACE}/${base_name}.pdf" ]; then
            PDF_FILES+=("${base_name}.pdf")
        fi
        
        if [ -f "${WORKSPACE}/${base_name}.tex" ]; then
            TEX_FILES+=("${base_name}.tex")
        fi
        
        if [ -f "${WORKSPACE}/${base_name}.html" ]; then
            HTML_FILES+=("${base_name}.html")
        fi
        
        if [ -f "${WORKSPACE}/${base_name}.md" ]; then
            MD_FILES+=("${base_name}.md")
        fi
        
        return 0
    else
        log_error "Failed to build: $resume"
        return 1
    fi
}

# Main execution
main() {
    log_info "YAMLResume GitHub Action"
    log_info "Version: $VERSION"
    
    # Validate inputs
    if [ -z "$RESUMES" ]; then
        log_error "No resume files specified"
        exit 1
    fi
    
    # Parse resume list (newline-separated)
    local resume_list=()
    while IFS= read -r line; do
        # Skip empty lines and trim whitespace
        line=$(echo "$line" | xargs)
        if [ -n "$line" ]; then
            resume_list+=("$line")
        fi
    done <<< "$RESUMES"
    
    if [ ${#resume_list[@]} -eq 0 ]; then
        log_error "No valid resume files found in input"
        exit 1
    fi
    
    log_info "Found ${#resume_list[@]} resume(s) to build"
    
    # Build resumes sequentially
    for resume in "${resume_list[@]}"; do
        if ! build_resume "$resume"; then
            BUILD_FAILED=1
            # Continue building other resumes even if one fails
        fi
    done
    
    # Set outputs for GitHub Actions
    if [ -n "${GITHUB_OUTPUT:-}" ] && [ "$GITHUB_OUTPUT" != "/dev/null" ]; then
        # Output PDF files (newline-separated)
        {
            echo "pdf-files<<EOF"
            printf '%s\n' "${PDF_FILES[@]:-}"
            echo "EOF"
        } >> "$GITHUB_OUTPUT"
        
        # Output TeX files (newline-separated)
        {
            echo "tex-files<<EOF"
            printf '%s\n' "${TEX_FILES[@]:-}"
            echo "EOF"
        } >> "$GITHUB_OUTPUT"
        
        # Output HTML files (newline-separated)
        {
            echo "html-files<<EOF"
            printf '%s\n' "${HTML_FILES[@]:-}"
            echo "EOF"
        } >> "$GITHUB_OUTPUT"
        
        # Output Markdown files (newline-separated)
        {
            echo "md-files<<EOF"
            printf '%s\n' "${MD_FILES[@]:-}"
            echo "EOF"
        } >> "$GITHUB_OUTPUT"
    fi
    
    # Summary
    echo ""
    log_info "Build Summary:"
    log_info "  PDF files: ${#PDF_FILES[@]}"
    for f in "${PDF_FILES[@]:-}"; do
        echo "    - $f"
    done
    log_info "  TeX files: ${#TEX_FILES[@]}"
    for f in "${TEX_FILES[@]:-}"; do
        echo "    - $f"
    done
    log_info "  HTML files: ${#HTML_FILES[@]}"
    for f in "${HTML_FILES[@]:-}"; do
        echo "    - $f"
    done
    log_info "  Markdown files: ${#MD_FILES[@]}"
    for f in "${MD_FILES[@]:-}"; do
        echo "    - $f"
    done
    
    # Exit with failure if any build failed
    if [ "$BUILD_FAILED" -eq 1 ]; then
        log_error "One or more builds failed"
        exit 1
    fi
    
    log_info "All builds completed successfully!"
}

# Run main
main "$@"
