<template>
  <card class="h-100" title="Deploy Pod From Template">
    <div>
      <form @submit="deployPod">
        <div class="row">
          <div class="col-md-12">
            <fg-select label="Template Name" placeholder="Select a pod..." ref="templateSelect" :options="options"
              required>
            </fg-select>
          </div>
        </div>

        <div class="text-center">
          <b-button type="submit" pill variant="info">Deploy Pod</b-button>
        </div>
      </form>
    </div>

    <b-modal ref="modal" v-model="modalShow" :title="modalTitle" :no-close-on-backdrop="true" ok-only>
      <div class="text-center">
        <b-spinner v-if="modalTitle.includes('Deploying')" variant="primary" label="Loading..."></b-spinner>
        <div>
          {{ modalText }}
        </div>
        <b-progress class="w-100" :max="maxLoadingTime" height="1.5rem" animated>
          <b-progress-bar :variant="barColor" :value="loadingTime"
            :label="`${((loadingTime / maxLoadingTime) * 100).toFixed(1)}%`"></b-progress-bar>
        </b-progress>
      </div>
    </b-modal>
  </card>
</template>
<script>
import axios from 'axios';
export default {
  data() {
    return {
      modalShow: false,
      modalTitle: "",
      modalText: "",
      password: "",
      options: [],
      loading: false,
      loadingTime: 0,
      maxLoadingTime: 78, // magic animation duration
      barColor: "",
    }
  },
  watch: {
    loading(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.clearLoadingTimeInterval()

        if (newValue) {
          this.$_loadingTimeInterval = setInterval(() => {
            if (this.loadingTime + 1 < this.getRandomArbitrary(0.78, 0.87) * this.maxLoadingTime) {
              this.loadingTime++
            }
          }, 1000)
        }
      }
    },
  },
  created() {
    this.$_loadingTimeInterval = null
  },
  mounted() {
    this.loadOptions()
  },
  methods: {
    getRandomArbitrary(min, max) {
      return Math.random() * (max - min) + min;
    },
    loadOptions() {
      axios.get('https://localhost:8080/view/templates/preset')
        .then((response) => {
          this.options = response.data.templates;
        })
        .catch((error) => {
          this.$notify(
            {
              message: error.response.data.error,
              type: 'danger',
              horizontalAlign: 'center',
              verticalAlign: 'bottom'
            })
        });
    },
    deployPod(event) {
      event.preventDefault()
      this.modalTitle = "Deploying Your Pod";
      this.modalText = "Your pod is deploying. Hold tight. This should only take a few minutes...";
      this.modalShow = true
      this.startLoading()
      axios.post('https://localhost:8080/pod/clone/template', {
        template: this.$refs.templateSelect.selected,
      })
        .then((response) => {
          console.log("success");
          this.barColor = "success"
          this.modalTitle = "Your Pod is Ready";
          this.modalText = "Your Pod is Ready. Check vSphere for your new pod.";
          this.$root.$emit('loadPods');
          this.$notify(
            {
              message: "Pod deployment is ready",
              type: 'success',
              horizontalAlign: 'center',
              verticalAlign: 'bottom'
            })
        })
        .catch((error) => {
          this.barColor = "danger"
          this.modalTitle = "Pod Clone Failed";
          this.modalText = "Uh oh. Something went wrong: " + error.response.data.error;
          console.log("error");
          console.error(error);
          this.$notify(
            {
              message: error.response.data.error,
              type: 'danger',
              horizontalAlign: 'center',
              verticalAlign: 'bottom'
            })
        })
        .finally(() => {
          this.loading = false
          this.loadingTime = this.maxLoadingTime
        });
    },
    clearLoadingTimeInterval() {
      clearInterval(this.$_loadingTimeInterval)
      this.$_loadingTimeInterval = null
    },
    startLoading() {
      this.barColor = "primary"
      this.loading = true
      this.loadingTime = 0
    }
  },
};
</script>
<style></style>
