# Market Discount Tracker (ADIS)

This repository contains a complete **Design and Analysis of Information Systems (DAIS)** elaboration for the application **“Market Discount Tracker”** — a system for aggregating supermarket discounts and discounted prices, with support for multiple user roles and an end-to-end data pipeline for analytics and reporting.

The work covers the full lifecycle of information system development: **requirements → modeling/design → data preparation/integration → analytical layer → visualization → documentation**.

## Project Overview

**Market Discount Tracker** is envisioned as a centralized system that:
- maintains an informative catalog of products and prices for registered markets,
- allows markets to define **time-limited discounts** for selected products,
- enables customers to discover discounts, build a list of favorites, and receive notifications,
- supports additional operational roles such as delivery and inspection,
- provides a complete analytical view via a data warehouse and BI dashboards.

This repository focuses on **analysis, design, data modeling, integration, and reporting**, rather than a full production web/mobile implementation.

---

## Problem & Goal

Modern markets often reduce prices for products nearing expiration or due to compliance with official consumer-basket measures. Customers typically learn about these discounts late or inconsistently.

The goal of this system is to provide:
- a **single place** where discounts are visible and searchable,
- consistent tracking of **discount validity periods** and product **status**,
- traceability of changes (who updated what, when, and how),
- an analytics layer for reporting trends, compliance, and performance.

---

## Core Domain (Concept)

At a high level, the system manages:

- **Markets** (stores / chains)
  - name, address, contact info
  - chain membership + number of stores (if applicable)
  - number of employees
  - one or more assigned market admins (but each admin belongs to exactly one market)

- **Products**
  - product name, description
  - production date, expiration date
  - status: **active / expired / discounted**
  - a product can be sold in multiple markets; price and stock are market-specific

- **Discounts**
  - a market selects a product and defines a discount with a **validity end date**
  - discount can be triggered by:
    - approaching expiration, and/or
    - inclusion in a government consumer basket

- **Orders & Delivery (extension)**
  - customer orders products and chooses payment method (card/cash)
  - delivery role manages orders ready for delivery and confirms completion

- **Inspection & Penalties (extension)**
  - inspector monitors whether eligible products are correctly discounted
  - issues penalties linked to a market (amount, serial number, date, inspector)

---

## Roles & Responsibilities

### Market Admin
- manages products, market-specific prices and stock
- defines discounts and validity periods
- ensures expired products are removed
- ensures compliance with consumer basket rules
- all changes are auditable (admin + timestamp + old/new values)

### Customer
- searches markets and products
- filters by status (active / expired / discounted) and availability
- creates **MyFavourite** list
- receives notifications when a favorite product becomes discounted (in-app/email)

### Delivery
- sees orders ready for delivery
- accepts an order and triggers customer notification with estimated delivery time
- confirms payment and closes the order
- tracks monthly delivery count

### Inspector
- verifies compliance regarding expiring goods and consumer basket discounts
- issues penalties when rules are violated

---

## Data & Modeling

This repository includes artifacts for:
- **Relational database modeling** with a **normalized schema**
- **JSON modeling** for exchange/testing and integration scenarios
- **Data warehouse** design to support historical analysis and business intelligence

The intent is to show consistent modeling across:
- operational data (normalized relational model),
- integration/testing formats (JSON),
- analytics/historical storage (data warehouse).

---

## Data Integration & Processing

Automated ingestion/transformation is implemented through **Apache NiFi** configurations, enabling repeatable processing such as:
- loading raw data,
- transformations and enrichment,
- preparation for the relational database and/or the data warehouse,
- producing datasets for reporting.

---

## Analytics & Visualization

The results of the analytical layer are presented via **Power BI**, using interactive reports and dashboards to support:
- discount trends over time,
- product status distribution (active/expired/discounted),
- market-level comparisons,
- compliance-oriented insights.

---

## Repository Structure

> Note: exact folder names may vary depending on the final organization.

Typical contents include:
- `README.md` – repository overview (this file)
- `Seminarska/` – main project deliverables and documentation
- raw data directory – initial datasets used for processing
- database artifacts – normalized schema and related scripts/files
- JSON datasets/models – used for exchange/testing
- data warehouse artifacts – star/snowflake schema, historical layer, etc.
- NiFi configs – flows for processing and transformation
- Power BI reports – `.pbix` files and/or exported resources
- UML diagrams – Macedonian and English versions

---

## How to Use This Repository

1. Start with the **documentation** (requirements and UML) to understand scope and roles.
2. Review the **relational schema** and **JSON model** to see how the domain is represented.
3. Inspect the **data warehouse** artifacts to understand the analytics layer.
4. Open the **Apache NiFi** flows to see how data is ingested/transformed.
5. Open the **Power BI** reports to explore final dashboards and insights.

---

## Deliverables

This repository aims to provide a complete ADIS project package, including:
- formal requirements/specification text
- UML modeling (MK + EN)
- normalized relational database model
- JSON datasets/models for integration/testing
- data warehouse design for analytics
- Apache NiFi configurations for ETL/data prep
- Power BI interactive reporting

---

## Notes

- This is an **analysis/design + data/BI** repository; it is not primarily a web/mobile application codebase.
- If you want to add a “Run locally” section, you can include the exact tools used for the DB/DWH (e.g., SQL Server/PostgreSQL) and how to import data and connect Power BI.

---
