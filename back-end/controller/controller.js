const { sql,poolPromise } = require('../database/db')
const fs = require('fs');
var rawdata = fs.readFileSync('./query/queries.json');
var queries = JSON.parse(rawdata);

class MainController {

    async getAllData(req , res){
      try {
        const pool = await poolPromise
          const result = await pool.request()
          .query(queries.getAllData)
          res.json(result.recordset)
      } catch (error) {
        res.status(500)
        res.send(error.message)
      }
    }
    async addNewData(req , res){
      try {
        if(req.body.PersonID != null && req.body.LastName != null && req.body.FirstName != null && req.body.Address != null && req.body.City != null) {
	  console.log("inside add new data");
          const pool = await poolPromise
          const result = await pool.request()
          .input('id',sql.Int , req.body.PersonID)
          .input('lastname',sql.VarChar , req.body.LastName)
          .input('firstname',sql.VarChar , req.body.FirstName)
          .input('address',sql.VarChar , req.body.Address)
          .input('city',sql.VarChar , req.body.City)
          .query(queries.addNewUser)
          res.json(result)
        } else {
          res.send('Please fill all the details!')
        }
      } catch (error) {
        res.status(500)
        res.send(error.message)
    }
    }
    async updateData(req , res){
      try {
        if(req.body.PersonID != null && req.body.LastName != null && req.body.FirstName != null && req.body.Address != null && req.body.City != null) {
        const pool = await poolPromise
          const result = await pool.request()
          .input('id',sql.Int , req.body.PersonID)
          .input('lastname',sql.VarChar , req.body.LastName)
          .input('firstname',sql.VarChar , req.body.FirstName)
          .input('address',sql.VarChar , req.body.Address)
          .input('city',sql.VarChar , req.body.City)
          .query(queries.updateUserDetails)
          res.json(result)
        } else {
          res.send('All fields are required!')
        }
      } catch (error) {
        res.status(500)
        res.send(error.message)
      }
    }
    async deleteData(req , res){
      try {
        if(req.body.PersonID != null ) {
          const pool = await poolPromise
            const result = await pool.request()
            .input('id',sql.VarChar,req.body.PersonID)
            .query(queries.deleteUser)
            res.json(result)
          } else {
            res.send('Please fill all the details!')
          }
      } catch (error) {
        res.status(500)
        res.send(error.message)
      }
    }
}

const controller = new MainController()
module.exports = controller;
