const sql = require("mssql");
const path = require("path");
require("dotenv").config({ path: path.resolve(".env") });

const config = (sqlConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PWD,
  database: process.env.DB_NAME,
  server: "localhost",
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 10000,
  },
  options: {
    enableArithAbort: true,
    encrypt: false,
    // instanceName: 'SQLEXPRESS',
    trustServerCertificate: true, // change to true for local dev / self-signed certs
    cryptoCredentialsDetails: {
      minVersion: "TLSv1",
    },
  },
});

const execStoredProcedure = async (storedProcedure, parameters) => {
  try {
    const pool = await sql.connect(config);
    const request = pool.request();

    if (parameters) {
      Object.keys(parameters).forEach((key) => {
        if (parameters[key] && parameters[key].output) {
          request.output(key, parameters[key].type, parameters[key].value);
        } else {
          request.input(key, parameters[key]);
        }
      });
    }

    const result = await request.execute(storedProcedure);
    const outputParameters = {};

    Object.keys(parameters).forEach((key) => {
      if (parameters[key] && parameters[key].output) {
        outputParameters[key] = result.output[key];
      }
    });

    return { recordsets: result.recordsets, output: outputParameters };
  } catch (err) {
    throw err;
  } finally {
    await sql.close();
  }
};

// const execStoredProcedure = async (storedProcedure, parameters) => {
//   try {
//     const pool = await sql.connect(config);
//     const request = pool.request();

//     if (parameters) {
//       Object.keys(parameters).forEach((key) => {
//         if (parameters[key] && parameters[key].output) {
//           request.output(key, parameters[key].type, parameters[key].value);
//         } else {
//           request.input(key, parameters[key]);
//         }
//       });
//     }

//     const result = await request.execute(storedProcedure);

//     const outputParameters = {};
//     Object.keys(parameters).forEach((key) => {
//       if (parameters[key] && parameters[key].output) {
//         outputParameters[key] = parameters[key].value;
//       }
//     });

//     // console.log("Result:", result);
//     // console.log("Recordsets:", result.recordsets);

//     // Assuming all the tables in the recordsets array are relevant data tables
//     const allRecordsets = result.recordsets;

//     return { recordsets: allRecordsets, output: outputParameters };
//   } catch (err) {
//     throw err;
//   } finally {
//     await sql.close();
//   }
// };

// const executeSelectStatement = async (selectQuery) => {
//   try {
//     const pool = await sql.connect(config);
//     const request = pool.request();

//     const result = await request.query(selectQuery);

//     if (result.recordset.length > 0) {
//       const row = result.recordset[0];
//       const value = Object.values(row);
//       return value;
//     } else {
//       // Handle the case where no results were found
//       return null; // or an appropriate default value
//     }
//   } catch (err) {
//     throw err;
//   } finally {
//     await sql.close();
//   }
// };

const executeSelectStatement = async (selectQuery) => {
  try {
    const pool = await sql.connect(config);
    const request = pool.request();

    const result = await request.query(selectQuery);

    if (result.recordset.length > 0) {
      const rows = result.recordset.map(row => {
        const values = Object.values(row);
        return values;
      });

      return rows;
    } else {
      // Handle the case where no results were found
      return null; // or an appropriate default value
    }
  } catch (err) {
    throw err;
  } finally {
    await sql.close();
  }
};


module.exports = {
  execStoredProcedure,
  executeSelectStatement,
};
