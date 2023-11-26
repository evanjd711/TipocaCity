<template>
  <card class="card" title="Register">
    <div>
      <p>
        Try to create a very unique username!
      </p>
      <form @submit.prevent class="p-4">
        <div class="row">
          <div class="col">
            <fg-input
              type="text"
              label="Username"
              placeholder="Username"
              v-model="username"
            >
            </fg-input>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <fg-input
              type="password"
              label="Password"
              placeholder="Password"
              v-model="password"
            >
            </fg-input>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <fg-input
              type="password"
              label="Confirm Password"
              placeholder="Confirm Password"
              v-model="confirmPassword"
            >
            </fg-input>
          </div>
        </div>
        <div class="text-center">
          <p-button type="info" round @click.native.prevent="register">
            Register
          </p-button>
          <p-button type="info" round @click.native.prevent="back">
            Back
          </p-button>
        </div>
      </form>
    </div>
  </card>
</template>
<script>
import axios from 'axios';
export default {
  data() {
    return {
      username: "",
      password: "",
      confirmPassword: "",
    };
  },
  methods: {
    register() {
      if (this.password != this.confirmPassword){
        return;
      }
      axios.post('https://localhost:8080/register', 
          { 
            username: this.username, 
            password: this.password 
          }
        ).then((response) => {
          this.$router.push({ name: 'login' })
      }).catch((error) => {
        console.log(error)
        this.$notify(
          {
            message: error.response.data.error,
            type: 'danger',
            horizontalAlign: 'center',
            verticalAlign: 'bottom'
          })
      });
    },
    back() {
      this.$router.push({ name: 'home' })
    },
  }
};
</script>
