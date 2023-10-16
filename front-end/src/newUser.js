import React, {Component} from 'react';
import Validation from 'react-validation';
//import "../validation.js";

export default class Registration extends Component {
    constructor(props) {
        super(props)
        this.state = {
            id: '',
            lastname: '',
            firstname: '',
            address: '',
            city: ''
        }
        this.handleSubmit = this.handleSubmit.bind(this)
    }

    handleSubmit(event) {
        event.preventDefault()
        var data = {
            id: this.state.id,
            lastname: this.state.lastname,
            firstname: this.state.firstname,
            address: this.state.address,
            city: this.state.city
        }
        console.log(data)
        fetch("http://localhost:5000/api/addNewData", {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        }).then(function(response) {
            if (response.status >= 400) {
              throw new Error("Bad response from server");
            }
            return response.json();
        }).then(function(data) {
            console.log(data)    
            if(data == "success"){
               this.setState({msg: "Thanks for registering"});  
            }
        }).catch(function(err) {
            console.log(err)
        });
    }

    logChange(e) {
        this.setState({[e.target.name]: e.target.value});  
    }

    render() {
        return (
            <div className="container register-form">
                <Validation.components.Form onSubmit={this.handleSubmit} method="POST">
                    <label>ID</label>
                    <Validation.components.Input onChange={this.logChange} className="form-control" value='' placeholder='John' name='name' validations={['required']}/>
                    <label>Email</label>
                    <Validation.components.Input onChange={this.logChange} className="form-control" value='' placeholder='email@email.com' name='email' validations={['required', 'email']}/>
                    <div className="submit-section">
                        <Validation.components.Button className="btn btn-uth-submit">Submit</Validation.components.Button>
                    </div>
                </Validation.components.Form>
            </div>
        );
    }
}
