# Godot Tower Defense

> A production-quality, data-driven Tower Defense framework and game built with **Godot 4**.

---

## Project Status

🚧 Active Development

Current Phase:

- Documentation
- Architecture
- Framework Design

---

# Vision

Create a modern, expandable Tower Defense game inspired by classic titles such as Castle TD while remaining completely original in gameplay, architecture and content.

The project is designed around long-term maintainability, modular systems and data-driven gameplay.

---

# Goals

- Professional codebase
- Mobile-first architecture
- Reusable gameplay framework
- Easy content creation
- Clean separation between engine and game content
- AI-friendly project structure
- Commercial quality

---

# Core Principles

- Data Driven
- Component Based
- Godot Native
- Resource Oriented
- Signal Based
- Modular
- Testable
- Scalable

---

# Technology

| Item | Value |
|------|-------|
| Engine | Godot 4.x |
| Language | GDScript 2 |
| Rendering | 2D |
| Platform | Android (Primary) |
| License | MIT |

---

# Repository Structure

```

godot-tower-defense/
│
├── .github/
├── .ai/
├── docs/
├── engine/
├── game/
├── assets/
├── tests/
├── tools/
├── examples/
└── README.md

```

---

# Documentation

Documentation lives inside the `/docs` directory.

Every system is designed before implementation.

No production code should be written without an approved specification.

Documentation hierarchy:

```

Project
Architecture
Game Design
Specifications
API
Testing
Release

```

---

# Development Workflow

Idea

↓

Specification

↓

Architecture

↓

Implementation

↓

Testing

↓

Optimization

↓

Release

---

# Architecture

The project follows a hybrid architecture designed specifically for Godot.

Main concepts:

- Scene Based
- Resource Driven
- Component Based
- Event Driven
- Factory Pattern
- Object Pooling

---

# Design Philosophy

The engine does **not** know what a Goblin, Knight or Dragon is.

The engine only understands:

- Entities
- Components
- Systems
- Resources

Game content is built on top of the framework.

---

# Mobile First

The primary target platform is Android.

Every feature must consider:

- Memory usage
- CPU usage
- Battery consumption
- Touch controls
- Mid-range devices

---

# Performance Targets

Target FPS:

60 FPS

Maximum frame time:

16.6 ms

Support:

100+ active enemies

100+ projectiles

without noticeable frame drops on supported hardware.

---

# Coding Standards

- Typed GDScript only
- One responsibility per class
- No hardcoded gameplay values
- No duplicated logic
- Prefer composition over inheritance
- Use Signals where appropriate
- Keep systems modular

---

# Documentation Rules

Every important feature requires:

- Specification
- Architecture documentation
- Acceptance criteria
- Future extension notes

---

# Current Phase

Phase 0

Project Foundation

Current work:

- Repository
- Documentation
- Engine Architecture

---

# Roadmap

- Documentation
- Framework
- Prototype
- Vertical Slice
- Alpha
- Beta
- Content Complete
- Polish
- Release Candidate
- Release

---

# Contributing

Contribution guidelines will be available after the architecture reaches version 1.0.

---

# License

MIT License

---

This repository is intended to become a professional, production-quality Tower Defense framework and game built with Godot.
