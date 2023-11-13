<template>
  <div class="wrapper">
    <side-bar title="Kamino">
      <template slot="links">
        <sidebar-link :to="{ name: 'dashboard' }" name="Dashboard" icon="ti-panel" />
        <!-- <sidebar-link :to="{ name: 'profile' }" name="Profile" icon="ti-user" /> -->
        <sidebar-link :to="{ name: 'logout' }" name="Logout" icon="ti-share-alt" />
      </template>
      <mobile-menu>
      </mobile-menu>
    </side-bar>
    <div class="main-panel">
      <top-navbar></top-navbar>

      <main-content @click.native="toggleSidebar"> </main-content>

      <content-footer></content-footer>
    </div>
  </div>
</template>
<style lang="scss"></style>
<script>
import TopNavbar from "./TopNavbar.vue";
import MobileMenu from "./MobileMenu";

export default {
  components: {
    TopNavbar,
    MobileMenu,
  },
  methods: {
    toggleSidebar() {
      if (this.$sidebar.showSidebar) {
        this.$sidebar.displaySidebar(false);
      }
    },
  },
};
</script>
