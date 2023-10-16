import React, { Component } from 'react';
import './App.css';
import axios from 'axios';
//import './newUser.js'
class App extends Component {

  state = {
    data: [],
    person:{
      id: 100,
      lastname: 'lastname',
      firstname: 'firstname',
      address: 'address',
      city: 'city'
    },
    success: false
  }

  componentDidMount() {
    this.getUsers()
  }

  
  getUsers = () => {
    axios.get('http://localhost:5000/api/getAllData')
      .then(response => {console.log(response.data); this.setState({ data: response.data, success: true })})
      .catch(err => console.log(err))
  }
  // getUsuarios = () => {
  //   fetch('http://localhost:5000')
  //     .then(response => response.json())
  //     .then(response => {console.log(response.data); this.setState({ data: response.data, success: true })})
  //     .catch(err => console.log(err))
  // }

  
  addUser = _ => {
  var data = JSON.stringify({"PersonID":this.state.person.id,"LastName":this.state.person.lastname,"FirstName":this.state.person.firstname,"Address":this.state.person.address,"City":this.state.person.city});
    console.log(this.state.person.id,this.state.person.firstname)
  var config = {
    method: 'post',
    url: 'http://localhost:5000/api/addNewData',
    headers: { 
      'Content-Type': 'application/json'
    },
    data : data
};

axios(config)
.then(this.getUsers)
.catch(function (error) {
  console.log(error);
});

     
  }
  getKeys = () => {
    return Object.keys(this.state.data[0]);
  }

  getHeader = () => {
    const keys = this.getKeys();
    return keys.map((key, index) => {
      return <th key={key}>{key.toUpperCase()}</th>
    })
  }

  getRowsData = () => {
    var items = this.state.data;
    var keys = this.getKeys();
    return items.map((row, index) => {
      return <tr key={index}><RenderRow key={index} data={row} keys={keys} /></tr>
    })
  }

  showData = () => {
    if (this.state.success) {
      return (
        <table id="users" align="center">
          <thead>
            <tr>{this.getHeader()}</tr>
          </thead>
          <tbody>
            {this.getRowsData()}
          </tbody>
        </table>
      )
    }
  }

  // renderUser = ({ id, name, age, gender }) => <div key={id}>{name} | {age} | {gender}</div>

  render() {
    const { data, person } = this.state
    return (
      <div className="App">
        {/* {this.state.data.map((item, index) => <div key={index}>{item.LastName}</div>)} */}
        { this.showData() }
        <div>
          
          <input 
            value={person.id}
            onChange={e => this.setState({person: { ...person, id: e.target.value}})}/>
            
          <input 
             value={person.firstname}
             onChange={e => this.setState({person: { ...person, firstname: e.target.value}})}/>

          <input 
              value={person.lastname}
              onChange={e => this.setState({person: { ...person, lastname: e.target.value}})}/>
          <input 
              value={person.address}
              onChange={e => this.setState({person: { ...person, address: e.target.value}})}/>
          <input 
              value={person.city}
              onChange={e => this.setState({person: { ...person, city: e.target.value}})}/>
              <button id="createBtn" onClick= {this.addUser}>Add User</button>
        </div>
      </div>
    );
  }
}

const RenderRow = (props) => {
  return props.keys.map((key, index) => {
    return <td key={props.data[key]}>{props.data[key]}</td>
  })
}

export default App;
