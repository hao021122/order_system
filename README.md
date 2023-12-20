# Order System

This is a simple order system

## Table of Contents

- [Installation](#installation)
- [How to Run](#how-to-run)
- [Database](#database)
- [Setup Project Environment] (#setup-project-environment)

## Installation

Please make sure the nodejs version is 16.14.2 or above.
Use the following command to check your nodejs version:

```bash
node -v

```

To install the project, run the following command:

```bash
npm install

```

## How to run

To run this project, run the following command:

``` bash
npm run dev

```

Go browser enter website URL: http://localhost:3500

## Database

This project is using Microsoft SQL (MSSQL), please using the SQL Server 2022 or latest.

1. To execute the SQL query, please open the 'sql' folder and run the 'tables.sql' to insert the tables.
2. Run the "default_tables' queries.
3. After that, execute the other queries one by one

## Setup Project Environment

1. Go to .env file change the DB_NAME, DB_PWD and DB_USER, The NAME is cookie name, and the SECRET is cookie secret.
2. Go to config--> my-config.json, can the uid to your email and password to your app password. 

You can refer this link to setup the app password.
https://support.google.com/mail/answer/185833?hl=en





