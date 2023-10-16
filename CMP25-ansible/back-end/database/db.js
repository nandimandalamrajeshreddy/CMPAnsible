const sql = require("mssql");

const config = {
  database: 'Persons',
  user: 'cmpadmin',
  password: 'Unisys*12345',
  server: 'cmp-database1.database.windows.net',
  options: {
    trustedConnection: true
  }
} 

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    console.log('Connected to MSSQL')
    return pool
  })
  .catch(err => console.log('Database Connection Failed! Bad Config: ', err))

module.exports = {
  sql, poolPromise
}
