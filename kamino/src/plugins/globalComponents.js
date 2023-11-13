import { FormGroupSelect, FormGroupInput, Card, DropDown, Button, Content, Footer } from "../components/index";
import vSelect from "vue-select";
/**
 * You can register global components here and use them as a plugin in your main Vue instance
 */

const GlobalComponents = {
  install(Vue) {
    Vue.component("fg-input", FormGroupInput);
    Vue.component("fg-select", FormGroupSelect);
    Vue.component("drop-down", DropDown);
    Vue.component("main-content", Content)
    Vue.component("content-footer", Footer);
    Vue.component("card", Card);
    Vue.component("p-button", Button);
    Vue.component("v-select", vSelect);
  },
};

export default GlobalComponents;