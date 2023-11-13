<template>
  <b-container fluid>
    <b-row class="mb-4">
      <b-col cols="12" xl="8" class="mb-4 mb-xl-0">
        <deployed-pods ref="deployedPods"> </deployed-pods>
      </b-col>
      <div class="w-100 m-0 d-xl-none d-block"></div>
      <b-col cols="12" xl="4">
        <clone-request-form> </clone-request-form>
      </b-col>
    </b-row>
    <b-row>
      <b-col class="mb-4 mb-xl-0">
        <custom-request-form> </custom-request-form>
      </b-col>
    </b-row>
  </b-container>
</template>
<script>
import { StatsCard, ChartCard } from "@/components/index";
import CloneRequestForm from "./Dashboard/CloneRequestForm.vue";
import DeployedPods from "./Dashboard/DeployedPods.vue";
import CustomRequestForm from "./Dashboard/CustomRequestForm.vue";

import Chartist from "chartist";
export default {
  components: {
    StatsCard,
    ChartCard,
    CloneRequestForm,
    DeployedPods,
    CustomRequestForm,
  },
  /**
   * Chart data used to render stats, charts. Should be replaced with server data
   */
};
</script>
<style></style>
