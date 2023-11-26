import Vue from "vue";
import VueRouter from "vue-router";
import routes from "./routes";
import axios from 'axios';
Vue.use(VueRouter);

// configure router
const router = new VueRouter({
  routes, // short for routes: routes
  linkActiveClass: "active",
});

router.beforeResolve((to, from, next) => {
  if (to.matched.some(record => record.meta.authRequired)) {
    // this route requires auth, check if logged in
    // if not, redirect to login page.
    axios.get('https://localhost:8080/view/templates/preset')
      .then(response => {
        next();
      }).catch(error => {
        next("login");
      })
  } else {
    axios.get('https://localhost:8080/view/templates/preset')
      .then(response => {
        next("dashboard");
      }).catch(error => {
        next();
      })
  }
})

export default router;
