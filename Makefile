.PHONY: all ingest build models figures report test lint

all: ingest build models figures report

ingest:
	uv run python -m pmc.ingest

build:
	uv run python -m pmc.build

models:
	uv run python -m pmc.models

figures:
	uv run python -m pmc.viz

report:
	quarto render report

test:
	uv run pytest -q

lint:
	uv run ruff check src tests
