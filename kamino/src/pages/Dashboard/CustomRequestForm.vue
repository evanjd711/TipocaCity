<template>
    <card class="h-100" title="Deploy a Custom Pod">
        <div>
            <div class="text-center">
                <b-button @click="openModal" pill variant="info">Build Your Pod</b-button>
            </div>
        </div>

        <b-modal ref="form-modal" title="Build Your Custom Pod" :no-close-on-backdrop="true" scrollable>
            <div>
                <b-form id="form-custom" @submit="deployCustomPod">
                    <div class="form-group">
                        <label for="pod-name">Pod Name</label>
                        <b-form-input v-model="podName" id="pod-name" placeholder="Enter pod name" required></b-form-input>
                    </div>
                    <div class="form-group">
                        <div class="d-flex flex-row align-items-center">
                            <b-form-checkbox v-model="nat" name="check-button" switch>
                            </b-form-checkbox> 1-1 NAT Setup <b>(Checked: {{ nat }})</b>
                        </div>
                    </div>
                    <div ref="form-modal-vm-section">
                        <div v-for="(vm, index) in customVmCount" :key="index" class="form-group">
                            <label :for="formatId('vm', index)">VM {{ index + 1 }}</label>
                            <b-form-select :id="formatId('vm', index)" :ref="formatId('select', index)"
                                v-model="vmsToCreate[index]" :options="options" required>
                            </b-form-select>
                        </div>
                    </div>
                    <div class="form-group">
                        <b-button variant="info" @click="addVmSelect()">
                            <i class="fa-2xl fa-regular fa-square-plus"></i> Add a VM
                        </b-button>
                    </div>
                </b-form>
            </div>
            <template #modal-footer="{ cancel }">
                <!-- Emulate built in modal footer ok and cancel button actions -->
                <b-button variant="secondary" @click="cancel()">
                    Cancel
                </b-button>
                <b-button type="submit" form="form-custom" variant="primary">
                    Create
                </b-button>
            </template>
        </b-modal>

        <b-modal ref="deploy-modal" :title="modalTitle" :no-close-on-backdrop="true" ok-only>
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
            modalTitle: "",
            modalText: "",
            loading: false,
            loadingTime: 0,
            maxLoadingTime: 78, // magic animation duration
            barColor: "",
            options: [],
            customVmCount: 1,
            vmsToCreate: [],
            nat: false,
            podName: "",
            selected: "",
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
        formatId(prefix, index) {
            return prefix + "-" + index;
        },
        getRandomArbitrary(min, max) {
            return Math.random() * (max - min) + min;
        },
        openModal() {
            this.$refs["form-modal"].show()
        },
        addVmSelect() {
            if (this.customVmCount < 8) {
                this.customVmCount++
            } else {
                this.$notify(
                    {
                        message: "Max number of VMs for this pod reached!",
                        type: 'danger',
                        horizontalAlign: 'center',
                        verticalAlign: 'bottom'
                    })
            }
        },
        loadOptions() {
            axios.get('https://localhost:8080/view/templates/custom')
                .then((response) => {
                    var optionRemap = [];
                    response.data.templates.forEach((subfolder) => {
                        var group = { "label": subfolder.name }
                        group["options"] = []
                        subfolder.vms.forEach((vm) => {
                            group["options"].push({ text: decodeURIComponent(vm), value: decodeURIComponent(vm) })
                        })
                        optionRemap.push(group)
                    })
                    this.options = optionRemap
                })
                .catch((error) => {
                    var errorMsg = ""
                    if (error.response) {
                        errorMsg = error.response.data.error
                    } else {
                        errorMsg = error.toString()
                    }
                    this.$notify(
                        {
                            message: errorMsg,
                            type: 'danger',
                            horizontalAlign: 'center',
                            verticalAlign: 'bottom'
                        })
                });
        },
        deployCustomPod(event) {
            event.preventDefault()
            this.modalTitle = "Deploying Your Pod";
            this.modalText = "Your pod is deploying. Hold tight. This should only take a few minutes...";
            this.$refs["form-modal"].hide()
            this.$refs["deploy-modal"].show()
            this.startLoading()
            axios.post('https://localhost:8080/pod/clone/custom', {
                name: this.podName,
                vmstoclone: this.vmsToCreate,
                nat: this.nat,
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
  