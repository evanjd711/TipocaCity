<template>
  <b-card class="h-100">
    <template #header>
      <div class="d-flex justify-content-between">
        <b-card-title>
          Your Deployed Pods
        </b-card-title>
        <b-button @click="loadPods()"><i class="fa-solid fa-arrow-rotate-right"></i></b-button>
      </div>
    </template>
    <div>
      <p v-if="pods == null">
        You don't have any pods yet.
      </p>

      <b-tabs v-else pills vertical>
        <b-tab class="flex-nowrap" v-for="i in pods" :key="i.Name" :title="i.Name">
          <b-card-text>
            <div class="d-flex flex-column">
              <b-row class="text-center">
                <b-col cols="12" class="mb-3">
                  <a class="btn btn-primary" target="_blank" v-bind:href="getPodLink(i)">
                    Open pod on elsa.sdc.cpp
                  </a>
                </b-col>
                <b-col cols="12">
                  <b-button variant="danger" pill @click="openModal(i)">Delete {{ i.Name }}</b-button>
                </b-col>
              </b-row>
            </div>
          </b-card-text>
        </b-tab>
      </b-tabs>
    </div>
    <b-modal id="delete-modal" ref="delete-modal" title="Delete Pod" :no-close-on-backdrop="true">
      <div class="text-center">
        <div>
          Are you sure you want to delete:
          <pre>{{ podToDelete.Name }}</pre>
        </div>
      </div>
      <template #modal-footer="{ cancel }">
        <!-- Emulate built in modal footer ok and cancel button actions -->
        <b-button variant="secondary" @click="cancel()">
          Cancel
        </b-button>
        <b-button variant="danger" @click="deletePod(podToDelete)">
          Delete
        </b-button>
      </template>
    </b-modal>
  </b-card>
</template>
<script>
import axios from 'axios';

export default {
  data() {
    return {
      pods: null,
      podToDelete: "",
    };
  },
  mounted() {
    this.loadPods()
    this.$root.$on('loadPods', () => {
      this.loadPods()
    })
  },
  methods: {
    loadPods() {
      axios.get('https://localhost:8080/view/pods')
        .then((response) => {
          console.log(response)
          this.pods = response.data.pods;
        }).catch((error) => {
          console.log(error)
        });
    },
    deletePod(pod) {
      axios.delete('https://localhost:8080/pod/delete/' + pod.Name)
        .then((response) => {
          this.loadPods();
        });
      this.$refs["delete-modal"].hide()
    },
    getPodLink(pod) {
      return "https://elsa.sdc.cpp/ui/app/vapp;nav=h/urn:vmomi:VirtualApp:" + pod.ResourceGroup + ":" + pod.ServerGUID + "/summary"
    },
    openModal(pod) {
      this.podToDelete = pod
      this.$refs["delete-modal"].show()
    },
  },
};
</script>
<style></style>
