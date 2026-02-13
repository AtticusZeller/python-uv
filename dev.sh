#!/usr/bin/env bash
set -e

# Help function
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  format   Run code formatting (Ruff)"
    echo "  lint     Run linters and type checking (Ruff, MyPy)"
    echo "  test     Run tests with coverage (Pytest)"
    echo "  docs     Manage documentation (dev, build, deploy)"
    echo "  bump     Bump version and update changelog"
    echo "  check    Run full pre-commit pipeline (Format, Lint, Tests, pre-commit)"
    echo ""
}

# 1. Format Function
run_format() {
    echo "running formatter..."
    set -x
    ruff check src tests --fix
    ruff format src tests
    set +x
    echo "format complete."
}

# 2. Lint Function
run_lint() {
    echo "running linter..."
    set -x
    mypy src                # type check
    ruff check src          # linter
    ruff format src --check # formatter check
    set +x
    echo "lint complete."
}

# 3. Test Function
run_test() {
    echo "running tests..."
    set -x
    coverage run --source=src -m pytest "$@"
    coverage report --show-missing
    coverage html --title "python-uv-coverage"
    set +x
    echo "tests complete."
}

# 4. Docs Function
run_docs() {
    local cmd=$1
    shift
    
    run_uvx() {
        uvx --with mkdocs-material \
            --with mkdocs-git-revision-date-localized-plugin \
            --with mkdocs-glightbox \
            --with mkdocs-obsidian-bridge \
            --with pymdown-extensions \
            "$@"
    }

    case "$cmd" in
        dev)
            run_uvx mkdocs serve "$@"
            ;;
        deploy)
            run_uvx mkdocs gh-deploy --force "$@"
            ;;
        build)
            run_uvx mkdocs build "$@"
            ;;
        *)
            echo "usage: $0 docs {dev|deploy|build}"
            exit 1
            ;;
    esac
}

# 5. Bump Function
run_bump() {
    echo "bumping version..."
    set -x
    # update CHANGELOG.md use GITHUB_REPO ENV as github token
    git-cliff -o -v --github-repo "atticuszeller/python-uv"
    # bump version and commit with tags
    bump-my-version bump patch
    # push remote
    git push origin main --tags
    set +x
    echo "bump complete."
}

# 6. Pre-commit/Check Function
run_check() {
    echo "running pre-commit pipeline..."
    run_format
    run_lint
    run_test
    set -x
    pre-commit run --all-files
    set +x
    echo "all checks passed."
}

# Main Dispatcher
case "$1" in
    format)
        run_format
        ;;
    lint)
        shift
        run_test "$@"
        ;;
    docs)
        shift
        run_docs "$@"
        ;;
    bump)
        run_bump
        ;;
    check)
        run_check
        ;;
    *)
        show_help
        exit 1
        ;;
esac
