<template>
  <h1>LOGGING OUT</h1>
</template>
<script>
import axios from 'axios';
export default {
  mounted() {
    this.logout()
  },
  methods: {
    logout() {
      axios.get('https://localhost:8080/logout'
        ).then((response) => {
          this.$router.push({ name: 'home' })
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
  }
};
</script>
