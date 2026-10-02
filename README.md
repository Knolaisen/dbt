# dbt Customer Analytics

A dbt project that transforms the Snowflake sample `CUSTOMER` and `ORDERS` tables into staging models and a customer-level order summary. It also includes data quality tests for customer identifiers and phone numbers.

## Requirements

- dbt Core with the Snowflake adapter (`dbt-snowflake`)
- Access to `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER` and `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS`
- A dbt profile named `default` configured in your local `profiles.yml`

The project does not contain database credentials. Configure the `default` profile for your Snowflake account before running dbt.

## Getting started

Run these commands from the project root:

```bash
# Check that dbt and the Snowflake connection are configured
dbt debug

# Build models and run their tests
dbt build
```

To build the customer summary and its upstream models:

```bash
dbt build --select +int_customer_orders
```

To run tests separately:

```bash
dbt test
```

## Models and lineage

The project follows a staging-to-intermediate model flow:

```text
SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER ──> stg__customers ──┐
                                                             ├──> int_customer_orders
SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS   ──> stg__orders ─────┘
```

- **`stg__customers`** (`models/staging/stg__customers.sql`) selects customer data and aliases `C_CUSTKEY`, `C_NAME`, `C_NATIONKEY`, and `C_PHONE` as `customer_id`, `first_name`, `last_name`, and `phone_number`, respectively. In particular, `C_NATIONKEY` is currently aliased as `last_name`; verify that mapping before interpreting the field as a person's surname.
- **`stg__orders`** (`models/staging/stg__orders.sql`) selects order data and aliases `O_ORDERKEY`, `O_CUSTKEY`, `O_ORDERDATE`, and `O_ORDERSTATUS` as `order_id`, `customer_id`, `order_date`, and `status`.
- **`int_customer_orders`** (`models/intermediate/int_customer_orders.sql`) produces one row per customer, including first and most recent order dates and an order count. Customers without orders remain in the result with `number_of_orders` set to `0`.

Staging models are materialized as views; intermediate models are materialized as tables. These defaults are configured in `dbt_project.yml`.

## Data quality tests

The declared tests in `models/schema.yml` check that `stg__customers.customer_id` is non-null and unique, and that non-null phone numbers pass the `valid_phone_number` custom test. The custom test is defined in `tests/generic/valid_phone_number.sql`; it accepts an optional leading `+`, digits, spaces, parentheses, and hyphens, and requires 7–15 digits.

## Project layout

```text
models/
  staging/       Source-level customer and order models
  intermediate/  Customer-level order summary
  sources.yml    Snowflake source declarations
  schema.yml     Model documentation and data tests
tests/
  generic/       Custom generic dbt tests
```
