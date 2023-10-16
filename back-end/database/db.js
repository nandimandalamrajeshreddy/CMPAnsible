const sql = require("mssql");

const config = {
  database: 'Persons',
  user: 'xxxxx',
  password: 'xxxxx',
  server: 'xxxxxxxx',
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
